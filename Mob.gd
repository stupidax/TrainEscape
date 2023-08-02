extends KinematicBody2D


#Stats
var speed = 1800
var velocity = Vector2()
var direction = "right"
var turning = false
var canTurn = true
var wagon_num = 0

signal mobCollided


# Called when the node enters the scene tree for the first time.
func _ready():
	assert(!connect("mobCollided",get_node('/root/Game'),"_on_Mob_collided"))

func _physics_process(delta):
	#motion on rails
	if direction  == 'right':
		velocity.x = speed * delta
	if direction == 'left':
		velocity.x = -speed * delta
	if direction == 'up':
		velocity.y = -speed * delta
	if direction == 'down':
		velocity.y = speed * delta
	
	#collide
	velocity = move_and_slide(velocity, Vector2(0,1))
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision:
			emit_signal('mobCollided', collision,self)

	#explosion

func mobTurn(pDir):
	if pDir == "up":
		velocity.x = 0
		$Wagon.play("up")
		$CollisionShape2D.position.x = 1
		$CollisionShape2D.position.y = -2
		direction = "up"
	elif pDir == "down":
		velocity.x = 0
		$Wagon.play("down")
		$CollisionShape2D.position.x = -1
		$CollisionShape2D.position.y = 2
		direction = "down"
	elif pDir == "left":
		velocity.y = 0
		$Wagon.play("left")
		$CollisionShape2D.position.x = -2
		$CollisionShape2D.position.y = -1
		direction = "left"
	elif pDir == "right":
		velocity.y = 0
		$Wagon.play("right")
		$CollisionShape2D.position.x = 2
		$CollisionShape2D.position.y = 1
		direction = "right"

func _on_Character_animation_finished():
	if $Character.animation == "pick":
		$Character.play("idle")


func _on_ExplosionContact_area_entered(_area):
	get_node("/root/Game").explode(self)
	print("dead")
