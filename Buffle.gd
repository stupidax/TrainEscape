extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func change_dir(dir):
	play(dir)
	if dir == "up":
		position.x = 0
		position.y = -7
	elif dir == "down":
		position.x = 0
		position.y = -2
	elif dir == "left":
		position.x = -4
		position.y = -2
	elif dir == "right":
		position.x = 5
		position.y = -2
