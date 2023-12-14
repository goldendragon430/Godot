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
var starting_position: Vector3
var health: float = 50
var speed: float = 30		# normal speed	
var max_speed: float = 120	# max speed 
var direction: Vector3		# current moving direction
var damage = 10				# weapon damage

#-------------Device Variable------------------#
var weapon_type = "Kinetic"
var weapon_range: float = 350   # Weanpon Range
var weapon_cooldown: float = 1 

var bullet_cooldown: float = .05
var bullet_scene = preload("res://scenes/bullet_laser.tscn")
var bullet_count = 5	# count of bullet at once
var BULLET_SPEED = 300

#-------------Behaviour Variable------------------#
var first_attack_flag = 0   # First attack flage
var x_evalde_direction = cos(randf_range(0,PI))
var y_evalde_direction = cos(randf_range(0,PI))
var z_evalde_direction = cos(randf_range(0,PI))

var angle = 0 # current player's angle
var unit_rotate_angle = PI/80
var moving_state : FigherState = FigherState.SEEK # moving mode
var impact_hit_scene = preload("res://scenes/explosion_particles.tscn")
var ship_size = 1
var count = 0
var timer: Timer
var timer2: Timer
var timer3: Timer

var is_shooting = false
var stop_shooting = false

#-------------Target Variable------------------#
var target: Node3D # handle of target
var target_weapon_range: float = 250 # target's weanpon range
var closest_enemy

@onready var enemies = get_tree().get_root().get_node("Main/World/Scene/Enemies").get_children()
@onready var camera = get_tree().get_root().get_node("Main/Camera3D")
@onready var camera_shadow = get_tree().get_root().get_node("Main/World/Scene/Player/fighter/camera")
# if target and player is in the same direction ?
func _is_same_direction(a,b):
	var c = a.x * b.x + a.y * b.y + a.z * b.z 
	return c > 0
	
func _ready():
	target = searchtarget()
	if target != null:
		direction = global_position.direction_to(target.global_position)
	starting_position = global_position
func _get_distance(a,b):
	return (a-b).length()
# Collision avoidance	

func _detect_collision():
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, global_position + velocity.normalized() * 100)
	var result = space_state.intersect_ray(query)
	if result : # if there are something in front of me around 100m
		var position = result.position
		moving_state = FigherState.WANDER
		x_evalde_direction = cos(randf_range(0,PI))
		y_evalde_direction = cos(randf_range(0,PI))			
		z_evalde_direction = 0
		move_and_slide()
		look_at(global_transform.origin + velocity, Vector3.UP)
		return true
	return false
		
func _physics_process(delta):
	if _detect_collision() == true:
		return 
	if target == null:
		target = searchtarget()
	move_and_slide()
	if target != null:
		if global_position.distance_to(target.global_position) > weapon_range * 2 /3: # if player is out of weapon_range => seek
			_rotate()
			moving_state = FigherState.SEEK
			if first_attack_flag == 1:
				first_attack_flag = 2
							
		elif global_position.distance_to(target.global_position) > target_weapon_range: # if player is out of target weapon_range => fire!
			if moving_state != FigherState.WANDER:
				_rotate()
				moving_state = FigherState.PERSUIT			
		else:  # if player is in  wepaon range of target, it will evade
			var target_direction =  target.get('velocity')
			if target_direction != null:
				if _is_same_direction(direction.normalized(),target_direction.normalized()) == false and get_angle_vectors(direction.normalized(),target_direction.normalized()) < PI/10:
					if moving_state != FigherState.WANDER:
						x_evalde_direction = cos(randf_range(0,PI))
						y_evalde_direction = cos(randf_range(0,PI))			
						z_evalde_direction = cos(randf_range(0,PI))
						moving_state = FigherState.WANDER
				else :			
					_rotate()
					moving_state = FigherState.PERSUIT
				
		look_at(global_transform.origin + velocity, Vector3.UP)
		
func survey(): # servey if our station is distroyed
	var station = get_tree().get_root().get_node("Main/World/Scene/Player/Flagship")
	if station == null: # our statino is destroyed
		if self.visible == false: # start seeking for battle
			self.visible = true
			speed = 50
			max_speed = 70
			damage = 50
			moving_state = FigherState.SEEK
		return true
	return false

func move():
	velocity = direction.normalized() * speed

func _rotate():
	var distance = (target.global_position - global_position).length()
	#predict the position of target in next moment
	var target_pos = (distance / BULLET_SPEED )  * target.get('velocity') + target.global_position
	var delta_angle = global_position.direction_to(target_pos) - direction
	#if delta angle is smaller than unit angle =>
	if delta_angle.length() < unit_rotate_angle:
			direction = global_position.direction_to(target_pos) 
	else: # if delta angle is bigger then rotate unit angle
		direction += delta_angle.normalized() * unit_rotate_angle
func seek(target):
	if is_instance_valid(target) == true:
		velocity = direction.normalized() * speed
	angle += PI/30
	if angle > 2 * PI:
		angle = angle - 2 * PI

func pursuit(target):
	if is_instance_valid(target):
		#if player and target are comming in face => 
		if _is_same_direction(velocity, target.get('velocity')) == false:
			velocity = direction.normalized() * max_speed/2
		else : # player is catching the target
			velocity = direction.normalized() * max_speed 
		# rotate player's fly
		angle += PI/30
		if angle > 2 * PI:
			angle = angle - 2 * PI
		rotate(velocity.normalized(),angle)	
		# if difference is smaller than 3 degree => fire!
		if get_angle_vectors(velocity,target.get('velocity')) < PI / 50 :
			shoot()
func get_angle_vectors(a,b):
		var c = a.x * b.x + a.y * b.y + a.z * b.z 
		var angle = acos(c/a.length()/b.length())
		if angle > PI/2:
			angle = PI - angle
		return angle
func wander():
	if first_attack_flag == 0:
		velocity = direction.normalized() * (1.5 * max_speed)
		first_attack_flag == 1
	elif first_attack_flag == 2: 
		direction = Vector3(x_evalde_direction,y_evalde_direction,z_evalde_direction)
		velocity = direction.normalized() * (max_speed)


func _process(_delta):
	#camera.set_position( camera_shadow.global_position)
	if survey() == false:
		return
	var distance = 0
	if moving_state == FigherState.SEEK:
		seek(target)
	elif moving_state == FigherState.PERSUIT:
		pursuit(target) 
	elif moving_state == FigherState.WANDER:
		wander()

func reset():
	stop_shooting = true
	target = self
	rotation_degrees = Vector3(0,0,0)
	var resettimer = Timer.new()
	add_child(resettimer)
	resettimer.wait_time = 0.5
	resettimer.one_shot = true
	resettimer.start()
	await resettimer.timeout
	global_position = starting_position

func searchtarget():
	enemies = get_tree().get_root().get_node("Main/World/Scene/Enemies").get_children()
	#enemies = get_tree().get_root().get_node("Main/World/Scene/Player/Flagship")
	#return enemies
	for enemy in enemies:
		if enemy != null:
			if closest_enemy == null:
				if enemy.name != "Destroyer":
					closest_enemy = enemy
			else:
				if global_position.distance_to(enemy.global_position) < global_position.distance_to(closest_enemy.global_position):
					closest_enemy = enemy
	if closest_enemy != null:
		return closest_enemy

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
	var scene_root = get_tree().get_root().get_node("Main/World/Scene/Bullets").get_children()[0]
	scene_root.add_child(clone)

	clone.global_transform = self.global_transform 
	clone.scale = Vector3(4, 4, 4)
	clone.BULLET_DAMAGE = damage
	if count == 0:
		clone.target = target
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
