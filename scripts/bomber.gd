extends CharacterBody3D

const damage = 3
var ship_size = 2

const IDLE_ANIM_NAME = "Pistol_idle"
const FIRE_ANIM_NAME = "Pistol_fire"

var is_weapon_enabled = false
var bullet_scene = preload("res://scenes/bullet_laser.tscn")
var impact_hit_scene = preload("res://scenes/explosion_particles.tscn")
var bullet_cooldown = .5
var weapon_cooldown = 2.5
var bullet_count = 3
var is_shooting = false

var player_node = null

const MAXSPEED = 30
const ACCELERATION = 0.75

var InputVector = Vector3()
var target: Node3D
var target_position: Vector3
var targetinfo = 0
var speed: float = 12
var direction: Vector3
var weapon_range = 550
var health: float = 100

var count = 0
var timer: Timer
var timer2: Timer
var timer3: Timer
var stop_shooting = false

var starting_position: Vector3

@onready var enemies = get_tree().get_root().get_node("Main/World/Scene/Enemies").get_children()
var closest_enemy

func _ready():
	target = searchtarget()
	targetinfo = 0
	if target != null:
		direction = global_position.direction_to(target.global_position)
	starting_position = global_position
	
func _physics_process(delta):
	if stop_shooting != true:
		if target != null:
			direction = global_position.direction_to(target.global_position)
	
		if target != null:
			if global_position.distance_to(target.global_position) > weapon_range:
				velocity = direction.normalized() * speed
			if global_position.distance_to(target.global_position) > 100 && global_position.distance_to(target.global_position) < weapon_range:
				velocity = direction.normalized() * (speed/4)
			if global_position.distance_to(target.global_position) > 50 && global_position.distance_to(target.global_position) < 100:
				velocity = direction.normalized() * (speed/12)
			if global_position.distance_to(target.global_position) > 30 && global_position.distance_to(target.global_position) < 50:
				velocity = direction.normalized() * (speed/24)
			if global_position.distance_to(target.global_position) < 30:
				velocity = direction.normalized() * 0
	
		rotation_degrees.z = velocity.x * -2
		rotation_degrees.x = velocity.y / 2
		rotation_degrees.y = velocity.x / 2
	
		if target != null:
			look_at(target.global_position)
	
		move_and_slide()

func _process(_delta):
	if target != null:
		if global_position.distance_to(target.global_position) <weapon_range:
			if stop_shooting != true:
				shoot()
	else:
		target = searchtarget()
		if target == null:
			target = get_tree().get_root().get_node("Main/World/Scene/Enemies").get_child(0)
			reset()
	if target == null:
		reset()

func reset():
	stop_shooting = true
	targetinfo = 1
	target = self
	var resettimer = Timer.new()
	add_child(resettimer)
	resettimer.wait_time = 0.5
	resettimer.one_shot = true
	resettimer.start()
	await resettimer.timeout
	global_position = starting_position

func searchtarget():
	enemies = get_tree().get_root().get_node("Main/World/Scene/Enemies").get_children()
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

func _checkinput():
	if Input.is_action_pressed("shoot"):
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
	print(clone)
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
