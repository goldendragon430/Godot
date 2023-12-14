extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	self.text = "State: " + str(Global.state)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	self.text = "State: " + str(Global.state)
