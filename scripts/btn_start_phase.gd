extends Button

@onready var enemies = get_tree().get_root().get_node("Main/World/Scene/Enemies").get_children()
@onready var player = get_tree().get_root().get_node("Main/World/Scene/Player/fighter")
 

func _pressed():
	Global.wave += 1
	enemies = get_tree().get_root().get_node("Main/World/Scene/Enemies").get_children()
	for enemy in enemies:
		if is_instance_valid(enemy):
			if enemy.name != "Destroyer":
				enemy.target = null
				enemy.stop_shooting = false
	player.health = 300 + Global.wave * 50
 
			
	get_tree().paused = false
	$"../label_phase_title".visible = false
	$"../btn_buyfighter".visible = false
	$"../btn_buybomber".visible = false
	visible = false
