extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position.y -= delta *10

func _on_Smoke_animation_finished():
	queue_free()
