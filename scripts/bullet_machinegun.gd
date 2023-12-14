extends Node3D

var BULLET_SPEED = 300
var BULLET_DAMAGE = 0.1

const KILL_TIMER = 4
var timer = 0

var hit_something = false

func _ready():
	$Area3D.body_entered.connect(collided)
	#pass

func _physics_process(delta):
	var forward_dir = global_transform.basis.z.normalized() * -1
	
	global_translate(forward_dir * BULLET_SPEED * delta)

	timer += delta
	if timer >= KILL_TIMER:
		queue_free()
		pass

func collided(body):
	if hit_something == false:
		if body.has_method("bullet_hit"):
			body.bullet_hit(BULLET_DAMAGE, global_transform)
			#print(BULLET_DAMAGE)

	hit_something = true
	queue_free()
