extends Button

var scene
var world = Node3D
var sceneposition = Vector3(0,0,0) 
var units: float
var offset = 20
var squad_offset = 80
var playerscene = Node3D
var playerscenecount: int
var begplayerscenecount: int
var deltabegplayerscenecount: int
var offsetdir = 1
var squad_offsetdir = 1
var costs = 50
var unitcount = 3
var raiseoffset = false

func _process(_delta):
	if Global.coins < costs:
		disabled = true
	else:
		disabled = false
		

func _pressed():
	Global.coins -= costs
	unitcount = 3
	playerscene = get_tree().get_root().get_node("Main/World/Scene/Player/Fighter")
	begplayerscenecount = playerscene.get_child_count()
	deltabegplayerscenecount = 0
	squad_offset = 80
	raiseoffset = false
	
	if begplayerscenecount == 0:
		deltabegplayerscenecount = unitcount
	else:
		deltabegplayerscenecount = begplayerscenecount % 3
	
	if deltabegplayerscenecount == 0:
		deltabegplayerscenecount = unitcount
	
	for x in unitcount:
		playerscene = get_tree().get_root().get_node("Main/World/Scene/Player/Fighter")
		playerscenecount = (playerscene.get_child_count())+(unitcount-deltabegplayerscenecount)
	
		scene = ResourceLoader.load("res://scenes/fighter_backup.tscn").instantiate()
		
		if playerscenecount % 2 == 0:
			offsetdir = 1
		else:
			offsetdir = -1
		
		if playerscenecount % unitcount == 0:
			if playerscenecount % 2 == 0:
				squad_offsetdir = 1
			else:
				squad_offsetdir = -1
			offsetdir = 0
			
			if playerscenecount >= (unitcount*3):
				squad_offset = (ceil(((playerscenecount-(unitcount))/(unitcount*2)))+1) * 80
			else:
				squad_offset = 80
		
		if playerscenecount == 0:
			squad_offsetdir = 0
			offsetdir = 0
	
		scene.position.x = (squad_offset*squad_offsetdir)+(offset*offsetdir)
		#scene.global_position.y = 0
		#scene.global_position.z = 0
		scene.scale = Vector3(.01,.01,.01)
		playerscene.add_child(scene)
