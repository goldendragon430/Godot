extends Button

var scene
var world = Node3D
var sceneposition = Vector3(0,0,0) 
var units: float
var offset = 100
var squad_offset = 100
var playerscene = Node3D
var playerscenecount: int
var begplayerscenecount: int
var deltabegplayerscenecount: int
var offsetdir = 1
var squad_offsetdir = 1
var costs = 100
var unitcount = 1
var raiseoffset = false

func _process(_delta):
	if Global.coins < costs:
		disabled = true
	else:
		disabled = false
		

func _pressed():
	Global.coins -= costs
	unitcount = 1
	playerscene = get_tree().get_root().get_node("Main/World/Scene/Player/Bomber")
	begplayerscenecount = playerscene.get_child_count()
	deltabegplayerscenecount = 0
	squad_offset = 100
	raiseoffset = false
	
	if begplayerscenecount == 0:
		deltabegplayerscenecount = unitcount
	else:
		deltabegplayerscenecount = begplayerscenecount % unitcount
	
	if deltabegplayerscenecount == 0:
		deltabegplayerscenecount = unitcount
	
	print(unitcount)
	print(begplayerscenecount)
	print(deltabegplayerscenecount)
	
	for x in unitcount:
		playerscene = get_tree().get_root().get_node("Main/World/Scene/Player/Bomber")
		playerscenecount = (playerscene.get_child_count())+(unitcount-deltabegplayerscenecount)
	
		scene = ResourceLoader.load("res://scenes/bomber.tscn").instantiate()
		#unitcount -= 1
		
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
				squad_offset = (ceil(((playerscenecount-(unitcount))/(unitcount*2)))+1) * 100
			else:
				squad_offset = 100
		
		#if playerscenecount > (unitcount) && playerscenecount % unitcount == 0:
		#	squad_offset = ((playerscenecount-(unitcount))/(unitcount*2)) * 80
			
		if playerscenecount == 0:
			squad_offsetdir = 0
			offsetdir = 0
		
		print("Bomber Count: " + str(playerscenecount))
		print("Unit Count: " + str(unitcount))
		print("Modulo: " + str(playerscenecount % unitcount))
		print("Divide: " + str(playerscenecount / unitcount))
		print("SO Calc: " + str(ceil(((playerscenecount-unitcount)/(unitcount*2)))+1))
		print("Squad Offset: " + str(squad_offset))
		print("Squad Offset Dir: " + str(squad_offsetdir))
		print("Offset: " + str(offset))
		print("Offset Dir: " + str(offsetdir))
	
		scene.position.x = (squad_offset*squad_offsetdir)+(offset*offsetdir)
		scene.position.y = 100
		scene.position.z = 100
		scene.scale = Vector3(.05,.05,.05)
		playerscene.add_child(scene)
