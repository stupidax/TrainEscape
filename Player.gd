extends KinematicBody2D

export(PackedScene) var Loco
export(PackedScene) var Stock
export(PackedScene) var Canon
export(PackedScene) var Tail


#Stats
var speed = 1800
var velocity = Vector2()
var direction = "right"
var turning = false
var canTurn = true
var canShoot = 0
var wagon_num = 0
var buffle = false
var start = true

#weight
var w_loco = 0
var w_stock = 0
var w_canon = 0
var w_buffle = 0
var boost = 1


signal collided
signal turningOrder(posV,dir)
signal startLast()

#game Stats
var wagon_list = ["loco","stock"]


# Called when the node enters the scene tree for the first time.
func _ready():
	assert(!connect("collided",get_node('/root/Game'),"_on_Character_collided"))
	assert(!connect("turningOrder",get_node('/root/Game'),"_on_turning_Order"))
	assert(!connect("startLast",get_node('/root/Game'),"_on_move_start"))

func _process(_delta):
	#start
	if !get_node("/root/Game").startChecked:
		if get_node("/root/Game/level/collision").world_to_map(position) != get_node("/root/Game").startPos:
			emit_signal("startLast")

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
#			print("player collide")
			emit_signal('collided', collision)

func playerTurn(pDir):
	if pDir == "up":
		velocity.x = 0
		$CollisionShape2D.position.x = 1
		$CollisionShape2D.position.y = -2
	elif pDir == "down":
		velocity.x = 0
		$CollisionShape2D.position.x = -1
		$CollisionShape2D.position.y = 2
	elif pDir == "left":
		velocity.y = 0
		$CollisionShape2D.position.x = -2
		$CollisionShape2D.position.y = -1
	elif pDir == "right":
		velocity.y = 0
		$CollisionShape2D.position.x = 2
		$CollisionShape2D.position.y = 1
	direction = pDir
	$Wagon.play(pDir)
	$Buffle.change_dir(pDir)
#	print("x: ",get_node("/root/Game/level/collision").world_to_map(position),"y :", get_node("/root/Game/level/collision").world_to_map(position))
	emit_signal("turningOrder",get_node("/root/Game/level/collision").world_to_map(position),direction)


func add_wagon(pDir):
	var offset_y = 0
	var offset_x = 0
	if pDir == "up":
		offset_y = 14
	elif pDir == "down":
		offset_y = -14
	elif pDir == "right":
		offset_x = -14
	elif pDir == "left":
		offset_x = 14
	for i in wagon_list:
		if i == "loco":
			var wagon_loco = Loco.instance()
			wagon_num += 1
			w_loco += 1
			wagon_loco.start = true
			wagon_loco.wagonNumber = wagon_num
			wagon_loco.position.x = get_node("/root/Game/Player").position.x + offset_x * wagon_num
			wagon_loco.position.y = get_node("/root/Game/Player").position.y + offset_y * wagon_num
			get_node("/root/Game/wagons").add_child(wagon_loco)
		elif i == "stock":
			var wagon_stock = Stock.instance()
			wagon_num += 1
			w_stock += 1
			wagon_stock.start = true
			get_node("/root/Game").stockMax += 5
			get_node("/root/Game/UI/Full/HBoxContainer/VBoxContainer5/Label_stock").text = str(get_node("/root/Game").stock)+"/"+str(get_node("/root/Game").stockMax)
			wagon_stock.wagonNumber = wagon_num
			wagon_stock.position.x = get_node("/root/Game/Player").position.x + offset_x * wagon_num
			wagon_stock.position.y = get_node("/root/Game/Player").position.y + offset_y * wagon_num
			get_node("/root/Game/wagons").add_child(wagon_stock)
		elif i == "canon":
			var wagon_canon = Canon.instance()
			wagon_num += 1
			w_canon += 1
			wagon_canon.start = true
			wagon_canon.wagonNumber = wagon_num
			wagon_canon.position.x = get_node("/root/Game/Player").position.x + offset_x * wagon_num
			wagon_canon.position.y = get_node("/root/Game/Player").position.y + offset_y * wagon_num
			get_node("/root/Game/wagons").add_child(wagon_canon)

func add_more_wagon(type):
	if type == "buffle":
		buffle = true
		$Buffle.set_visible(true)
		print("buffle ok")
		return
	var last_wag
	if wagon_num > 0:
		last_wag = get_node("/root/Game/wagons").get_child(wagon_num-1)
	else:
		last_wag = self
	if !check_last_wag_turning(last_wag) and last_wag.start:
		wagon_list.push_back(type)
		if type == "loco":
			var wagon_loco = Loco.instance()
			wagon_num += 1
			w_loco += 1
			wagon_loco.wagonNumber = wagon_num
			var last_pos = get_last_wagon_position(wagon_num)
			var last_dir = get_last_wagon_direction(wagon_num)
			var tile_pos = get_node("/root/Game/level/collision").world_to_map(last_pos)
#			print("tile_pos : ",tile_pos)
			var new_ori = orientate_wag(last_dir,wagon_loco)
			wagon_loco.get_child(0).play(new_ori[0])
			wagon_loco.get_child(1).position.x = new_ori[1].x
			wagon_loco.get_child(1).position.y = new_ori[1].y
			wagon_loco.direction = new_ori[2]
			var new_pos = new_wag_pos(wagon_loco,tile_pos)
			wagon_loco.position.x = new_pos[0]
			wagon_loco.position.y = new_pos[1]
			get_node("/root/Game/wagons").add_child(wagon_loco)
			get_node("/root/Game").startPos = get_node("/root/Game/level/collision").world_to_map(last_wag.position)
			print("start: ", get_node("/root/Game").startPos)
		elif type == "stock":
			var wagon_stock = Stock.instance()
			wagon_num += 1
			w_stock += 1
			get_node("/root/Game").stockMax += 5
			get_node("/root/Game/UI/Full/HBoxContainer/VBoxContainer5/Label_stock").text = str(get_node("/root/Game").stock)+"/"+str(get_node("/root/Game").stockMax)
			wagon_stock.wagonNumber = wagon_num
			var last_pos = get_last_wagon_position(wagon_num)
			var last_dir = get_last_wagon_direction(wagon_num)
			var tile_pos = get_node("/root/Game/level/collision").world_to_map(last_pos)
#			print("tile_pos : ",tile_pos)
			var new_ori = orientate_wag(last_dir,wagon_stock)
			wagon_stock.get_child(0).play(new_ori[0])
			wagon_stock.get_child(1).position.x = new_ori[1].x
			wagon_stock.get_child(1).position.y = new_ori[1].y
			wagon_stock.direction = new_ori[2]
			var new_pos = new_wag_pos(wagon_stock,tile_pos)
			wagon_stock.position.x = new_pos[0]
			wagon_stock.position.y = new_pos[1]
			get_node("/root/Game/wagons").add_child(wagon_stock)
			get_node("/root/Game").startPos = get_node("/root/Game/level/collision").world_to_map(last_wag.position)
			print("start: ", get_node("/root/Game").startPos)
		elif type == "canon":
			var wagon_canon = Canon.instance()
			wagon_num += 1
			w_canon += 1
			canShoot += 1
			wagon_canon.wagonNumber = wagon_num
			var last_pos = get_last_wagon_position(wagon_num)
			var last_dir = get_last_wagon_direction(wagon_num)
			var tile_pos = get_node("/root/Game/level/collision").world_to_map(last_pos)
#			print("tile_pos : ",tile_pos)
			var new_ori = orientate_wag(last_dir,wagon_canon)
			wagon_canon.get_child(0).play(new_ori[0])
			wagon_canon.get_child(1).position.x = new_ori[1].x
			wagon_canon.get_child(1).position.y = new_ori[1].y
			wagon_canon.direction = new_ori[2]
			var new_pos = new_wag_pos(wagon_canon,tile_pos)
			wagon_canon.position.x = new_pos[0]
			wagon_canon.position.y = new_pos[1]
			get_node("/root/Game/wagons").add_child(wagon_canon)
			get_node("/root/Game").startPos = get_node("/root/Game/level/collision").world_to_map(last_wag.position)
			print("start: ", get_node("/root/Game").startPos)
	else:
		print("turning can't build")

func new_wag_pos(p_wag,t_pos):
	if p_wag.direction == "up":
		p_wag.position.x = t_pos.x * 13 + 7
		p_wag.position.y = t_pos.y * 13 + 0
	elif p_wag.direction == "down":
		p_wag.position.x = t_pos.x * 13 + 7
		p_wag.position.y = t_pos.y * 13 + 0
	elif p_wag.direction == "left":
		p_wag.position.x = t_pos.x * 13 + 0
		p_wag.position.y = t_pos.y * 13 + 6
	elif p_wag.direction == "right":
		p_wag.position.x = t_pos.x * 13 + 0
		p_wag.position.y = t_pos.y * 13 + 6
	return [p_wag.position.x,p_wag.position.y]

func orientate_wag(pDir,p_wag):
	var anim = ""
	var coll = Vector2(0,0)
	var dir = Vector2(0,0)
	if pDir == "up":
		if p_wag.type == "stock":
			anim = "up_"+str(p_wag.quantityView)
		else:
			anim = "up"
		coll.x = 1
		coll.y = -2
		dir = "up"
	elif pDir == "down":
		if p_wag.type == "stock":
			anim = "down_"+str(p_wag.quantityView)
		else:
			anim = "down"
		coll.x = -1
		coll.y = 2
		dir = "down"
	elif pDir == "left":
		if p_wag.type == "stock":
			anim = "left_"+str(p_wag.quantityView)
		else:
			anim = "left"
		coll.x = -2
		coll.y = -1
		dir = "left"
	elif pDir == "right":
		if p_wag.type == "stock":
			anim = "right_"+str(p_wag.quantityView)
		else:
			anim = "right"
		coll.x = 2
		coll.y = 1
		dir = "right"
	return [anim,coll,dir]

func check_last_wag_turning(wag):
	for i in get_node("/root/Game/level/wag_collision").get_used_cells():
		if i == get_node("/root/Game/level/wag_collision").world_to_map(wag.position):
			return true
	for i in get_node("/root/Game/level/sub_collision").get_used_cells():
		if i == get_node("/root/Game/level/sub_collision").world_to_map(wag.position):
				return true
	for i in get_node("/root/Game/level/collision").get_used_cells():
		if i == get_node("/root/Game/level/collision").world_to_map(wag.position):
				return true
	return false

func get_last_wagon_position(p_wagNum):
	if wagon_num <= 1 :
		return position
	else:
		return get_node("/root/Game/wagons").get_child(p_wagNum-2).position

func get_last_wagon_direction(p_wagNum):
	if wagon_num <= 1 :
		return direction
	else:
		return get_node("/root/Game/wagons").get_child(p_wagNum-2).direction

func pick_up(pDir):
	var tail = Tail.instance()
	if pDir == "up":
		tail.position.x = 0
		tail.position.y = -16
		tail.play("pick-up")
		$Character.play("pick")
		add_child(tail)
	if pDir == "down":
		tail.position.x = 0
		tail.position.y = 8
		tail.rotate(PI)
		tail.flip_h = true
		tail.play("pick-up")
		$Character.play("pick")
		add_child(tail)
	if pDir == "right":
		tail.position.x = 13
		tail.position.y = 0
		tail.rotate(PI/2)
		tail.play("pick-up")
		$Character.play("pick")
		add_child(tail)
	if pDir == "left":
		tail.position.x = -13
		tail.position.y = 0
		tail.rotate(-PI/2)
		tail.flip_h = true
		tail.play("pick-up")
		$Character.play("pick")
		add_child(tail)
#	print("tail position : ", get_node("/root/Game/level/items").world_to_map(position+tail.position))
	return get_node("/root/Game/level/items").world_to_map(position+tail.position)

func _on_Character_animation_finished():
	if $Character.animation == "pick":
		$Character.play("idle")


func _on_ExplosionContact2_area_entered(_area):
	if buffle:
		buffle = false
		$Buffle.set_visible(false)
		print("lose buffle")
	else:
		print("game over")
