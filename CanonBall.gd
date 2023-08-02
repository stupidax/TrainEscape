extends Area2D

var dir
var bulletSpeed = 300

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	if dir == "up":
		position.y -= bulletSpeed * delta 
	elif dir == "down":
		position.y += bulletSpeed * delta 
	elif dir == "right":
		position.x += bulletSpeed * delta 
	elif dir == "left":
		position.x -= bulletSpeed * delta 

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_CanonBall_area_entered(_area):
	queue_free()
