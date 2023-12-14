extends CharacterBody3D

var rng = RandomNumberGenerator.new()
var rng_nr = 0.0
var rng_nr2 = 0.0
var rng_nr3 = 0.0

func _ready():
	rng.randomize()

func _physics_process(delta):
	rng_nr = rng.randf_range(0.0, 0.5)
	rng_nr2 = rng.randf_range(0.0, 0.2)
	rng_nr3 = rng.randf_range(0.0, 0.1)
	
	#velocity.z = move_toward(velocity.z, rng_nr, rng_nr/3)
	
	rotation_degrees.z += rng_nr
	rotation_degrees.x += rng_nr2
	rotation_degrees.y += rng_nr3
	
	move_and_slide()


	
