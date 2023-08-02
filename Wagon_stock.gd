extends KinematicBody2D

var directionOrder = []
var type = "stock"
var direction = "right"
var velocity = Vector2()
var speed = 0
var lastOrder = []
var wagonNumber = 0
var storage = []
var quantityView = 0
var start = false

signal explodingTrain(wag)
signal startLast()

func _ready():
	assert(!connect("explodingTrain",get_node('/root/Game'),"_on_train_explode"))
	assert(!connect("startLast",get_node('/root/Game'),"_on_move_start"))

func _process(_delta):
	#start
	if !get_node("/root/Game").startChecked:
		if get_node("/root/Game/level/collision").world_to_map(position) != get_node("/root/Game").startPos:
			emit_signal("startLast")
	#order
	if lastOrder != []:
		var vPos = get_node("/root/Game/level/collision").world_to_map(position)
		if vPos.x == lastOrder[0] and vPos.y == lastOrder[1]:
			if lastOrder[2] == "up":
				if direction == "left":
					get_node("/root/Game/level/wag_collision").set_cell(vPos.x,vPos.y,0,false,false,false,Vector2(0,2))
				elif direction == "right":
					get_node("/root/Game/level/wag_collision").set_cell(vPos.x,vPos.y,0,false,false,false,Vector2(2,2))
			elif lastOrder[2] == "down":
				if direction == "left":
					get_node("/root/Game/level/wag_collision").set_cell(vPos.x,vPos.y,0,false,false,false,Vector2(0,0))
				elif direction == "right":
					get_node("/root/Game/level/wag_collision").set_cell(vPos.x,vPos.y,0,false,false,false,Vector2(2,0))
			elif lastOrder[2] == "left":
				if direction == "up":
					get_node("/root/Game/level/wag_collision").set_cell(vPos.x,vPos.y,0,false,false,false,Vector2(2,0))
				elif direction == "down":
					get_node("/root/Game/level/wag_collision").set_cell(vPos.x,vPos.y,0,false,false,false,Vector2(2,2))
			elif lastOrder[2] == "right":
				if direction == "up":
					get_node("/root/Game/level/wag_collision").set_cell(vPos.x,vPos.y,0,false,false,false,Vector2(0,0))
				elif direction == "down":
					get_node("/root/Game/level/wag_collision").set_cell(vPos.x,vPos.y,0,false,false,false,Vector2(0,2))

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
			if lastOrder != []:
				turnWagon(lastOrder[2])
			elif directionOrder != []:
				lastOrder = directionOrder[0]
				directionOrder.pop_front()
				turnWagon(lastOrder[2])

func send_order(vPos,dir):
	if wagonNumber < get_node("/root/Game/Player").wagon_num:
		get_node("/root/Game/wagons").get_child(wagonNumber).new_order(vPos,dir)

func turnWagon(pDir):
	if pDir == "up":
		velocity.x = 0
		$AnimatedSprite.play("up_"+str(quantityView))
		$CollisionShape2D.position.x = 1
		$CollisionShape2D.position.y = -2
		direction = "up"
	elif pDir == "down":
		velocity.x = 0
		$AnimatedSprite.play("down_"+str(quantityView))
		$CollisionShape2D.position.x = -1
		$CollisionShape2D.position.y = 2
		direction = "down"
	elif pDir == "left":
		velocity.y = 0
		$AnimatedSprite.play("left_"+str(quantityView))
		$CollisionShape2D.position.x = -2
		$CollisionShape2D.position.y = -1
		direction = "left"
	elif pDir == "right":
		velocity.y = 0
		$AnimatedSprite.play("right_"+str(quantityView))
		$CollisionShape2D.position.x = 2
		$CollisionShape2D.position.y = 1
		direction = "right"
	#clean order
#	print(wagonNumber, " - turn : ",direction)
	lastOrder = []
#	print(wagonNumber, " - order list : ", directionOrder)
	if directionOrder != []:
		lastOrder = directionOrder[0]
#		print(wagonNumber," - next order :", directionOrder[0])
		directionOrder.pop_front()
	send_order(get_node("/root/Game/level/collision").world_to_map(position),direction)
	#clean tile
	for i in get_node("/root/Game/level/wag_collision").get_used_cells():
		if i.x == get_node("/root/Game/level/collision").world_to_map(position).x and i.y == get_node("/root/Game/level/collision").world_to_map(position).y and wagonNumber == get_node("/root/Game/Player").wagon_num:
			get_node("/root/Game/level/wag_collision").set_cell(i.x,i.y,-1)
#			print("clear2 : ", wagonNumber," - ",get_node("/root/Game/Player").wagon_num, " Lo: ", lastOrder)

func loadStorage():
	quantityView += 1
	$AnimatedSprite.play(direction+"_"+str(quantityView))

func lossStorage():
	quantityView -= 1
	$AnimatedSprite.play(direction+"_"+str(quantityView))

#func checkStart():
#	var last_wag = get_node("/root/Game/wagons").get_child(get_node("/root/Game/Player").wagon_num-1)
#	if !get_node("/root/Game/wagons").get_child(wagonNumber-1).start:
#		var last_wag = get_node("/root/Game/wagons").get_child(wagonNumber-2)
#		if last_wag.direction == "up":
#			if last_wag.position.y > position.y-14:
#				start = true
#				speed = last_wag.speed
#		elif last_wag.direction == "down":
#			if last_wag.position.y < position.y+14:
#				start = true
#				speed = last_wag.speed
#		elif last_wag.direction == "right":
#			if last_wag.position.x > position.x+14:
#				start = true
#				speed = last_wag.speed
#		elif last_wag.direction == "left":
#			if last_wag.position.x < position.x-14:
#				start = true
#				speed = last_wag.speed
#		direction = last_wag.direction

func new_order(posV,dir):
	#check new Order
	if lastOrder != []:
		directionOrder.push_back([posV.x,posV.y,dir])
	else:
		lastOrder = [posV.x,posV.y,dir]
#	if order != []:
#		if order[0] == [] and order[1] == []:
#			pass
#		elif order[0] == [] and order[1] != []:
#			directionOrder = order[1]
#		else:
#			lastOrder = order[0]
#			directionOrder = order[1]
#	## Order gestion
#	if lastOrder == [] and directionOrder == []:
#		lastOrder = [posV.x,posV.y,dir]
#		print(wagonNumber," - direct ",lastOrder, " ",directionOrder)
#	elif lastOrder == [] and directionOrder != []:
#		lastOrder = directionOrder[0]
#		print(wagonNumber," - in queue ",lastOrder, " ",directionOrder)
#	else:
#		directionOrder.push_back([posV.x,posV.y,dir])
#		print(wagonNumber," - delay ",lastOrder, " ",directionOrder)



func _on_ExplosionContact2_area_entered(_area):
	emit_signal("explodingTrain",self)
