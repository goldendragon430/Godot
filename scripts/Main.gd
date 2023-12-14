extends Node3D

var timer: Timer

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
var cam

func _ready():
	get_tree().paused = true
	get_node("UI/label_phase_title").visible = true
	get_node("UI/btn_buyfighter").visible = true
	get_node("UI/btn_buybomber").visible = true
	get_node("UI/btn_start_phase").visible = true
	cam = get_tree().get_root().get_node("Main/Camera3D")

func _process(_delta):
	if get_tree().get_root().get_node("Main/World/Scene/Enemies").get_child_count() == 1:
		if !is_instance_valid(timer):
			timer = Timer.new()
			add_child(timer)
			timer.wait_time = 1.5
			timer.one_shot = true
			timer.timeout.connect(_on_timer_timeout)
			timer.start()

func _physics_process(_delta):
	if Input.is_action_pressed("select"):
		var mouse_position = get_viewport().get_mouse_position()
		var selectednode = raycast_from_mouse(mouse_position, 1)
		select_node(selectednode)
	if Input.is_action_pressed("deselect"):
		deselectall()
		
func raycast_from_mouse(m_pos, collision_mask):
		var ray_length = 1000
		var ray_start = cam.project_ray_origin(m_pos)
		var ray_end = ray_start + cam.project_ray_normal(m_pos) * ray_length
		var world3d : World3D = get_world_3d()
		var space_state = world3d.direct_space_state
	
		if space_state == null:
			return
	
		var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, collision_mask)
		query.collide_with_areas = true
	
		return space_state.intersect_ray(query)

func select_node(node):
	deselectall()
	if node:
		node.collider.select()

func deselectall():
	for x in Global.selectedunits:
		if is_instance_valid(x):
			x.deselect()
	Global.selectedunits.clear()

func _on_timer_timeout():
	for x in get_tree().get_root().get_node("Main/World/Scene/Bullets").get_children():
		for i in x.get_children():
			i.queue_free()
	buildwave()
	get_tree().paused = true
	get_node("UI/label_phase_title").text = "Wave completed"
	get_node("UI/label_phase_title").visible = true
	get_node("UI/btn_buyfighter").visible = true
	get_node("UI/btn_buybomber").visible = true
	get_node("UI/btn_start_phase").visible = true
	
	if is_instance_valid(timer):
		timer.queue_free()

func buildwave():
	if Global.wave <= 2:
		setupfighters(4)
	elif Global.wave > 2 && Global.wave < 5:
		setupfighters(6)
	else:
		setupfighters(10)

func setupfighters(x):
	for i in x:
		spawnfighters()
		
func spawnfighters():
	unitcount = 3
	playerscene = get_tree().get_root().get_node("Main/World/Scene/Enemies")
	begplayerscenecount = playerscene.get_child_count()-1
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
		playerscene = get_tree().get_root().get_node("Main/World/Scene/Enemies")
		playerscenecount = (playerscene.get_child_count()-1)+(unitcount-deltabegplayerscenecount)
	
		scene = ResourceLoader.load("res://scenes/fighter_enemy_backup.tscn").instantiate()
		
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
