extends ColorRect

func _ready():
	visible = false

func _process(_delta):
	if !Global.selectedunits.is_empty():
		get_child(0).text = str(Global.selectedunits[0].name)
		get_child(1).text = "HP: " + str(Global.selectedunits[0].health)
		get_child(2).text = "Type: " + str(Global.selectedunits[0].weapon_type)
		get_child(3).text = "Damage: " + str(Global.selectedunits[0].damage)
		get_child(4).text = "Range: " + str(Global.selectedunits[0].weapon_range)
		visible = true
	else:
		visible = false
