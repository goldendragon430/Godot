extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	self.text = "Wave: " + str(Global.wave)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	self.text = "Wave: " + str(Global.wave)
