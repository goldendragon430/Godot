extends CharacterBody3D

#---------------------Start of Variable Initialization------------------------#

# Name  : Imai Jiro
# Date  : 16-5-2023
# Title : Battle AI implementation

enum FigherState {
		SEEK,
		PERSUIT,
		FLEE,
		EVADE,
		WANDER,
		ABORT
}

#-------------Physical Variable------------------#

var ship_size = 1
var health: float = 50
var speed: float = 125
var max_speed: float = 25
var direction: Vector3
var moving_state : FigherState = FigherState.SEEK

var x_evalde_direction = cos(randf_range(0,PI))
var y_evalde_direction = cos(randf_range(0,PI))
var z_evalde_direction = cos(randf_range(0,PI))
var unit_rotate_angle = PI/360

#-------------Device Variable------------------#
var damage = 30
var weapon_range: float = 200
var weapon_cooldown: float = 2

var bullet_cooldown: float = .15
var bullet_count = 3

#-------------Target Variable------------------#
var target: Node3D
var target_position: Vector3
var targetinfo = 0
var closest_enemy


var is_shooting = false
var stop_shooting = false
var is_destroyed = false

#-------------Behaviour Variable------------------#
var bullet_scene = preload("res://scenes/bullet_machinegun.tscn")
var impact_hit_scene = preload("res://scenes/explosion_particles.tscn")
var count = 0

var timer: Timer
var timer2: Timer
var timer3: Timer
var timer4: Timer



func _ready():
	searchtarget()
	if target == null:
		target = searchtarget()
		targetinfo = 0
	if target != null:
		direction = global_position.direction_to(target.global_position)
func _detect_collision():
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, global_position + velocity.normalized() * 100)
	var result = space_state.intersect_ray(query)
	if result :
		var position = result.position
		moving_state = FigherState.WANDER
		x_evalde_direction = cos(randf_range(0,PI))
		y_evalde_direction = cos(randf_range(0,PI))			
		z_evalde_direction = 0
		move_and_slide()
		look_at(global_transform.origin + velocity, Vector3.UP)
		return true
	return false
func _physics_process(_delta):
	if is_destroyed == true:
		return
	if _detect_collision() == true:
		return 
	if target == null:
		target = searchtarget()
	move_and_slide()
	if target != null:
		if global_position.distance_to(target.global_position) > weapon_range:
			_rotate()
			moving_state = FigherState.SEEK 
		elif global_position.distance_to(target.global_position) > weapon_range/3:
			if moving_state != FigherState.WANDER:
				_rotate()
				moving_state = FigherState.PERSUIT			
		else:
			if moving_state != FigherState.WANDER:
				x_evalde_direction = cos(randf_range(0,PI))
				y_evalde_direction = cos(randf_range(0,PI))			
				z_evalde_direction = cos(randf_range(0,PI))
			moving_state = FigherState.WANDER
		look_at(global_transform.origin + velocity, Vector3.UP)

func _process(_delta):
	if moving_state == FigherState.SEEK:
		seek(target)
	elif moving_state == FigherState.PERSUIT:
		pursuit(target)
	elif moving_state == FigherState.WANDER:
		wander()
func get_angle_vectors(a,b):
		var c = a.x * b.x + a.y * b.y + a.z * b.z 
		var angle = acos(c/a.length()/b.length())
		if angle > PI/2:
			angle = PI - angle
		return angle
		
func searchtarget():
	target = get_tree().get_root().get_node("Main/World/Scene/Player/Flagship")
	if target == null:		 
		target = get_tree().get_root().get_node("Main/World/Scene/Player/fighter")
		speed = 40
		max_speed = 60
		damage = 10
		weapon_range = 250
	return target
func _rotate():
	var delta_angle = global_position.direction_to(target.global_position) - direction
	if delta_angle.length() < unit_rotate_angle:
		direction = global_position.direction_to(target.global_position)
	else:
		direction += delta_angle.normalized() * unit_rotate_angle
		
func seek(target):
	if is_instance_valid(target) == true:
		velocity = direction.normalized() * speed
 
func pursuit(target):
	if is_instance_valid(target):
		velocity = direction.normalized() * max_speed/2
	shoot()

func shoot():
	if is_shooting == false:
		timer = Timer.new()
		add_child(timer)
		is_shooting = true
		fire_weapon()
		timer.wait_time = weapon_cooldown
		timer.one_shot = true
		timer.timeout.connect(_on_timer_timeout)
		timer.start()
		await timer.timeout
		if is_instance_valid(timer):
			timer.queue_free()
func wander():
	direction = Vector3(x_evalde_direction,y_evalde_direction,z_evalde_direction)
	velocity = direction.normalized() * (1.5 * max_speed)
func fire_weapon():
 
	timer2 = Timer.new()
	add_child(timer2)
	timer2.wait_time = bullet_cooldown
	timer2.timeout.connect(_on_timer_timeout2)
	
	if count == 0:
		_on_timer_timeout2()
		timer2.start()

func _on_timer_timeout():
	is_shooting = false
	#queue_free()
	
func _on_timer_timeout2():
	var clone = bullet_scene.instantiate()
	var scene_root = get_tree().get_root().get_node("Main/World/Scene/Bullets").get_children()[2]
	scene_root.add_child(clone)

	clone.global_transform = self.global_transform 
	clone.scale = Vector3(4, 4, 4)
	clone.BULLET_DAMAGE = damage
	count = count + 1
	if count == bullet_count:
		count = 0
		if is_instance_valid(timer2):
			timer2.queue_free()
	
func bullet_hit(damage, hit_global_transform):
	health = health - damage
	var explode = impact_hit_scene.instantiate()
	var scene_root = get_tree().get_root().get_node("Main/World/Scene/VFX")
	explode.get_node("AnimationPlayer").autoplay = "explosion"
	scene_root.add_child(explode)
	
	if health <= 0:
		health = 0
		explode.global_transform = self.global_transform
		explode.scale = Vector3(ship_size*5, ship_size*5, ship_size*5)
		explode.get_node("GPUParticles3D").draw_pass_1.radius = ship_size*3
		explode.get_node("GPUParticles3D").draw_pass_1.height = ship_size*6
	else:
		explode.global_transform = hit_global_transform
		explode.scale = Vector3(damage, damage, damage)
		explode.get_node("GPUParticles3D").draw_pass_1.radius = damage/2
		explode.get_node("GPUParticles3D").draw_pass_1.height = damage
	
	timer3 = Timer.new()
	add_child(timer3)
	timer3.wait_time = 1
	timer3.one_shot = true
	timer3.start()
	
	await timer3.timeout
	
	if is_instance_valid(timer3):
		timer3.queue_free()
	if is_instance_valid(explode):
		scene_root.remove_child(explode)
		explode.queue_free()
	if health <= 0:
		queue_free()
		if is_destroyed != true:
			Global.coins += 20
		is_destroyed = true
