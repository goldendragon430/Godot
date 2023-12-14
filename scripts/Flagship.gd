extends Node3D

var health = 500.0
var impact_hit_scene = preload("res://scenes/explosion_particles.tscn")
var timer3 : Timer

var ship_size = 4

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
	timer3.timeout.connect(_on_timer_timeout3)
	timer3.start()
	await timer3.timeout
	if is_instance_valid(timer3):
		timer3.queue_free()
	if is_instance_valid(explode):
		scene_root.remove_child(explode)
		explode.queue_free()
	if health <= 0:
		queue_free()
		
func _on_timer_timeout3():
	var _node = get_tree().get_root().get_node("Main/World/Scene/VFX")
	#for n in node.get_children():
	#	node.remove_child(n)
	#	n.queue_free()
