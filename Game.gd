extends Node2D

export(PackedScene) var Loot
export(PackedScene) var Mob
export(PackedScene) var Explode

#var
var control_direction = "right"
var levelNumber = 1
var aimMode = false #false = move mode
var buildMode = false #false = pick mode
var dropMode = false
var pickPos = Vector2(0,0)
var startPos = Vector2(0,0)

#ressources
var goldR = 0
var ironR = 0
var woodR = 0
var coalR = 0
var frog = false
var stock = 0
var stockMax = 0
var fuelSpeed = 1

var startChecked = true
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	loadLevel("level1")
	loadItems()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#quick Quit
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	playerPosition()
	$PlayerVelocityLabel.text = "velo.x : "+str(floor($Player.velocity.x))+" ; velo.y : "+str(floor($Player.velocity.y))
	$speed.text = str($Player.speed)
	checkPlayerTurning()

	#fuel gestion
	consume_fuel(delta)
	weightCalculator()

	#control move mode
	if !aimMode :
		if !$Player.canTurn:
			if Input.is_action_pressed("ui_up"):
				$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/HBoxContainer/joystick.set_frame(1)
				playerControlTurn("up")
			elif Input.is_action_pressed("ui_down"):
				$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/HBoxContainer/joystick.set_frame(2)
				playerControlTurn("down")
			elif Input.is_action_pressed("ui_left"):
				$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/HBoxContainer/joystick.set_frame(3)
				playerControlTurn("left")
			elif Input.is_action_pressed("ui_right"):
				$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/HBoxContainer/joystick.set_frame(4)
				playerControlTurn("right")
			elif Input.is_action_just_released("ui_right") or Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_up") or Input.is_action_just_released("ui_down"):
				$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/HBoxContainer/joystick.set_frame(0)
				control_direction = "neutral"
				$ControlDirection.text = "c_"+control_direction
		#on release
		if Input.is_action_just_released("ui_up") or Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_down") or Input.is_action_just_released("ui_right"):
			$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/HBoxContainer/joystick.set_frame(0)		
			clearTurningTile()
		#add fuel
		if (woodR > 0 or coalR > 0) and Input.is_action_just_pressed("ui_LT"):
			add_fuel()
	#control aim mode
	elif aimMode:
		if $Player.canShoot > 0:
			if Input.is_action_pressed("ui_up"):
				change_aim_direction("up")
				$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/HBoxContainer/joystick.set_frame(1)
			elif Input.is_action_pressed("ui_down"):
				change_aim_direction("down")
				$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/HBoxContainer/joystick.set_frame(2)
			elif Input.is_action_pressed("ui_left"):
				change_aim_direction("left")
				$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/HBoxContainer/joystick.set_frame(3)
			elif Input.is_action_pressed("ui_right"):
				change_aim_direction("right")
				$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/HBoxContainer/joystick.set_frame(4)
			elif Input.is_action_just_released("ui_right") or Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_up") or Input.is_action_just_released("ui_down"):
				$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/HBoxContainer/joystick.set_frame(0)
			if Input.is_action_just_pressed("ui_LT"):
				fullShoot()
	#control pick mode
	if !buildMode and !dropMode:
		if $Player/Character.animation != "pick":
			#up
			if Input.is_action_just_pressed("ui_Y"):
				pickPos = $Player.pick_up("up")
				$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_Y/anim_Y.set_frame(2)
				pick_up_items()
			#left
			elif Input.is_action_just_pressed("ui_X"):
				pickPos = $Player.pick_up("left")
				$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer/but_X/anim_X.set_frame(2)
				pick_up_items()
			#right
			elif Input.is_action_just_pressed("ui_B"):
				pickPos = $Player.pick_up("right")
				$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer3/but_B/anim_B.set_frame(2)
				pick_up_items()
			#down
			elif Input.is_action_just_pressed("ui_A"):
				pickPos = $Player.pick_up("down")
				$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_A/anim_A.set_frame(2)
				pick_up_items()
	if Input.is_action_just_released("ui_Y") or Input.is_action_just_released("ui_X") or Input.is_action_just_released("ui_A") or Input.is_action_just_released("ui_B"):
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_Y/anim_Y.set_frame(1)
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer/but_X/anim_X.set_frame(1)
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_A/anim_A.set_frame(1)
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer3/but_B/anim_B.set_frame(1)
	#build
	elif buildMode and !dropMode:
		#build buffle
		if Input.is_action_just_pressed("ui_Y"):
			build_wag("buffle")
			$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_Y/anim_Y.set_frame(2)
		#build stock
		elif Input.is_action_just_pressed("ui_X"):
			build_wag("stock")
			$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer/but_X/anim_X.set_frame(2)
		#build loco
		elif Input.is_action_just_pressed("ui_B"):
			build_wag("loco")
			$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer3/but_B/anim_B.set_frame(2)
		#build canon
		elif Input.is_action_just_pressed("ui_A"):
			build_wag("canon")
			$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_A/anim_A.set_frame(2)
	elif dropMode:
		if Input.is_action_just_pressed("ui_Y"):
			drop("iron")
		elif Input.is_action_just_pressed("ui_X"):
			drop("gold")
		elif Input.is_action_just_pressed("ui_B"):
			drop("coal")
		elif Input.is_action_just_pressed("ui_A"):
			drop("wood")
	button_UI()

func pick_up_items():
	for i in $level/layer2.get_children():
		if $level/layer2.world_to_map(i.position) == pickPos and stock < stockMax:
			print("pick ",i.type," :", i)
			#pick Gold
			if i.type == "gold":
				goldR += 1
				$UI/Full/HBoxContainer/VBoxContainer4/Label_gold.text = str(goldR)
				countRessourcesGain("gold")
				i.queue_free()
			elif i.type == "iron":
				ironR += 1
				$UI/Full/HBoxContainer/VBoxContainer3/Label_iron.text = str(ironR)
				countRessourcesGain("iron")
				i.queue_free()
			elif i.type == "coal":
				coalR += 1
				$UI/Full/HBoxContainer/VBoxContainer2/Label_coal.text = str(coalR)
				countRessourcesGain("coal")
				i.queue_free()
			elif i.type == "wood":
				woodR += 1
				$UI/Full/HBoxContainer/VBoxContainer/label_wood.text = str(woodR)
				countRessourcesGain("wood")
				i.queue_free()
			elif i.type == "frog":
				frog = true
				$UI/Full/HBoxContainer/Bonus.visible = true
			stock += 1
			$UI/Full/HBoxContainer/VBoxContainer5/Label_stock.text = str(stock)+"/"+str(stockMax)
			
func playerControlTurn(pdir):
	control_direction = pdir
	$ControlDirection.text = "c_"+pdir
	setTurningTile(pdir)

#collision with rails
func _on_Character_collided(collision):
	# KinematicCollision2D object emitted by character
	if collision.collider is TileMap and !$Player.turning:
		var tile_pos = collision.collider.world_to_map($Player.position)
		var cell = $level/collision.get_cell_autotile_coord(tile_pos.x,tile_pos.y)
		checkTileDirection(cell)

func playerPosition():
	#player position
	var cpos = $level/collision.world_to_map($Player.position)
	#mouse position
	var mpos = $level/collision.world_to_map(get_global_mouse_position())
	$PlayerPositionLabel.text = "player:"+str(cpos)+" ; mouse:"+str(mpos)+" ; tile:"+str($level/collision.get_cell_autotile_coord(mpos.x,mpos.y))


func checkTileDirection(pcell):
	$Tile.text = str(pcell)
	var pDirection = $Player.direction
	#moving right
	if pDirection == "right":
		#left-up
		if pcell.x == 2 and pcell.y == 2:
			$Player.playerTurn("up")
		#left-down
		elif pcell.x == 2 and pcell.y == 0:
			$Player.playerTurn("down")
		#left-up-down
		elif pcell.x == 2 and pcell.y == 1:
			if control_direction == "up":
				$Player.playerTurn("up")
			else:
				$Player.playerTurn("down")
		#left-up-right
		elif pcell.x == 1 and pcell.y == 2:
			if control_direction == "up":
				$Player.playerTurn("up")
		#left-down-right
		elif pcell.x == 1 and pcell.y == 0:
			if control_direction == "down":
				$Player.playerTurn("down")
	#moving up
	elif pDirection == "up":
		#down-right
		if pcell.x == 0 and pcell.y == 0:
			$Player.playerTurn("right")
		#left-down
		elif pcell.x == 2 and pcell.y == 0:
			$Player.playerTurn("left")
		#left-down-right
		elif pcell.x == 1 and pcell.y == 0:
			if control_direction == "left":
				$Player.playerTurn("left")
			else:
				$Player.playerTurn("right")
		#left-down-up
		elif pcell.x == 2 and pcell.y == 1:
			if control_direction == "left":
				$Player.playerTurn("left")
		#down-up-right
		elif pcell.x == 0 and pcell.y == 1:
			if control_direction == "right":
				$Player.playerTurn("right")
	#moving left
	elif pDirection == "left":
		#down-right
		if pcell.x == 0 and pcell.y == 0:
			$Player.playerTurn("down")
		#up-right
		elif pcell.x == 0 and pcell.y == 2:
			$Player.playerTurn("up")
		#left-down-right
		elif pcell.x == 1 and pcell.y == 0:
			if control_direction == "down":
				$Player.playerTurn("down")
		#left-up-right
		elif pcell.x == 1 and pcell.y == 2:
			if control_direction == "up":
				$Player.playerTurn("up")
		#down-up-right
		elif pcell.x == 0 and pcell.y == 1:
			if control_direction == "up":
				$Player.playerTurn("up")
			else:
				$Player.playerTurn("down")
	#moving down
	elif pDirection == "down":
		#up-right
		if pcell.x == 0 and pcell.y == 2:
			$Player.playerTurn("right")
		#up-left
		elif pcell.x == 2 and pcell.y == 2:
			$Player.playerTurn("left")
		#left-up-down
		elif pcell.x == 2 and pcell.y == 1:
			if control_direction == "left":
				$Player.playerTurn("left")
		#left-up-right
		elif pcell.x == 1 and pcell.y == 2:
			if control_direction == "right":
				$Player.playerTurn("right")
			else:
				$Player.playerTurn("left")
		#down-up-right
		elif pcell.x == 0 and pcell.y == 1:
			if control_direction == "right":
				$Player.playerTurn("right")
	#turning
	$Direction.text = $Player.direction
	clearTurningTile()

func checkPlayerTurning():
	var playerCollisionPos = $level/collision.world_to_map($Player.position)
	var playerCollisionCell = $level/collision.get_cell_autotile_coord(playerCollisionPos.x,playerCollisionPos.y)
	$playerTileInCollision.text = str(playerCollisionCell)
	if playerCollisionCell.x == 2 and playerCollisionCell.y == 1 or playerCollisionCell.x == 0 and playerCollisionCell.y == 1 or playerCollisionCell.x == 1 and playerCollisionCell.y == 2 or playerCollisionCell.x == 1 and playerCollisionCell.y == 0:
		$Player.canTurn = true
	else:
		$Player.canTurn = false

func setTurningTile(pdir):
	var dir = $Player.direction
	#move up
	if pdir == "up":
		for i in $level/collision.get_used_cells():
			var j = $level/collision.get_cell_autotile_coord(i.x,i.y)
			if j.x == 1 and j.y == 2:
				if dir == "right":
					$level/sub_collision.set_cell(i.x,i.y,0,false,false,false,Vector2(2,2))
				else:
					$level/sub_collision.set_cell(i.x,i.y,0,false,false,false,Vector2(0,2))
	#move down
	elif pdir == "down":
		for i in $level/collision.get_used_cells():
			var j = $level/collision.get_cell_autotile_coord(i.x,i.y)
			if j.x == 1 and j.y == 0:
				if dir == "right":
					$level/sub_collision.set_cell(i.x,i.y,0,false,false,false,Vector2(2,0))
				else:
					$level/sub_collision.set_cell(i.x,i.y,0,false,false,false,Vector2(0,0))
	#move left
	if pdir == "left":
		for i in $level/collision.get_used_cells():
			var j = $level/collision.get_cell_autotile_coord(i.x,i.y)
			if j.x == 2 and j.y == 1:
				if dir == "up":
					$level/sub_collision.set_cell(i.x,i.y,0,false,false,false,Vector2(2,0))
				else:
					$level/sub_collision.set_cell(i.x,i.y,0,false,false,false,Vector2(2,2))
	#move right
	if pdir == "right":
		for i in $level/collision.get_used_cells():
			var j = $level/collision.get_cell_autotile_coord(i.x,i.y)
			if j.x == 0 and j.y == 1:
				if dir == "up":
					$level/sub_collision.set_cell(i.x,i.y,0,false,false,false,Vector2(0,0))
				else:
					$level/sub_collision.set_cell(i.x,i.y,0,false,false,false,Vector2(0,2))

func clearTurningTile():
#	var pPos = $level/collision.world_to_map($Player.position)
	for i in $level/sub_collision.get_used_cells():
#		var j = $level/collision.get_cell_autotile_coord(i.x,i.y)
		$level/sub_collision.set_cell(i.x,i.y,-1)

func _on_turning_Order(posV,dir):
	var first_wag = $wagons.get_child(0)
	if first_wag != null:
		if first_wag.lastOrder != []:
			first_wag.directionOrder.push_back([posV.x,posV.y,dir])
		else:
			first_wag.lastOrder = [posV.x,posV.y,dir]

func _on_Mob_collided(collision,pMob):
	# KinematicCollision2D object emitted by character
	if collision.collider is TileMap:
		var tile_pos = collision.collider.world_to_map(pMob.position)
		var cell = $level/collision.get_cell_autotile_coord(tile_pos.x,tile_pos.y)
		checkTileDirectionMob(cell,pMob)

func checkTileDirectionMob(pcell,pMob):
	$Tile.text = str(pcell)
	var pDirection = pMob.direction
	var rand_mob = randi() % 2
	#moving right
	if pDirection == "right":
		#left-up
		if pcell.x == 2 and pcell.y == 2:
			pMob.mobTurn("up")
		#left-down
		elif pcell.x == 2 and pcell.y == 0:
			pMob.mobTurn("down")
		#left-up-down
		elif pcell.x == 2 and pcell.y == 1:
			if rand_mob == 0:
				pMob.mobTurn("down")
			else:
				pMob.mobTurn("up")
	#moving up
	elif pDirection == "up":
		#down-right
		if pcell.x == 0 and pcell.y == 0:
			pMob.mobTurn("right")
		#left-down
		elif pcell.x == 2 and pcell.y == 0:
			pMob.mobTurn("left")
		#left-down-right
		elif pcell.x == 1 and pcell.y == 0:
			if rand_mob == 0:
				pMob.mobTurn("left")
			else:
				pMob.mobTurn("right")
			
	#moving left
	elif pDirection == "left":
		#down-right
		if pcell.x == 0 and pcell.y == 0:
			pMob.mobTurn("down")
		#up-right
		elif pcell.x == 0 and pcell.y == 2:
			pMob.mobTurn("up")
		#down-up-right
		elif pcell.x == 0 and pcell.y == 1:
			if rand_mob == 0:
				pMob.mobTurn("down")
			else:
				pMob.mobTurn("up")
	#moving down
	elif pDirection == "down":
		#up-right
		if pcell.x == 0 and pcell.y == 2:
			pMob.mobTurn("right")
		#up-left
		elif pcell.x == 2 and pcell.y == 2:
			pMob.mobTurn("left")
		#left-up-right
		elif pcell.x == 1 and pcell.y == 2:
			if rand_mob == 0:
				pMob.mobTurn("left")
			else:
				pMob.mobTurn("right")
#	clearTurningTile()

func loadItems():
	for cell in $level/items.get_used_cells():
		var item = Loot.instance()
		var j = $level/items.get_cell_autotile_coord(cell.x,cell.y)
		#wood
		if j.x == 2 and j.y == 0:
			item.type = "wood"
			item.position.x = cell.x * 13 + 7
			item.position.y = cell.y * 13 + 7
#			print("wood : ",item.position)
			$level/layer2.add_child(item)
		#gold
		if j.x == 0 and j.y == 0:
			item.type = "gold"
			item.position.x = cell.x * 13 + 7
			item.position.y = cell.y * 13 + 7
#			print("gold : ",item.position)
			$level/layer2.add_child(item)
		#iron
		if j.x == 3 and j.y == 0:
			item.type = "iron"
			item.position.x = cell.x * 13 + 7
			item.position.y = cell.y * 13 + 7
#			print("iron : ",item.position)
			$level/layer2.add_child(item)
		#coal
		if j.x == 1 and j.y == 0:
			item.type = "coal"
			item.position.x = cell.x * 13 + 7
			item.position.y = cell.y * 13 + 7
#			print("coal : ",item.position)
			$level/layer2.add_child(item)
		#frog
		if j.x == 4 and j.y == 0:
			item.type = "frog"
			item.position.x = cell.x * 13 + 7
			item.position.y = cell.y * 13 + 7
#			print("frog : ",item.position)
			$level/layer2.add_child(item)
	#stock
	$UI/Full/HBoxContainer/VBoxContainer5/Label_stock.text = str(stock)+"/"+str(stockMax)

func button_UI():
	#change mode
	#build mode
	if Input.is_action_pressed("ui_RB"):
		if !buildMode:
			buildMode = true
			$UI/Prices.set_visible(true)
			$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer/but_RB/anim_RB.play("build")
			$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer/but_RB/anim_RB.stop()
			$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer/but_RB/anim_RB.set_frame(2)
		switch_mode()
	if Input.is_action_just_released("ui_RB"):
		if buildMode:
			buildMode = false
			$UI/Prices.set_visible(false)
			$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer/but_RB/anim_RB.play("pick")
			$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer/but_RB/anim_RB.stop()
			$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer/but_RB/anim_RB.set_frame(1)
		switch_mode()
	#aim mode (if wag_canon present)
	if Input.is_action_pressed("ui_LB") and $Player.canShoot > 0:
		if !aimMode:
			aimMode = true
			$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/but_LT/anim_LT.play("aim")
			$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/but_LT/anim_LT.stop()
			$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/but_LT/anim_LT.set_frame(2)
		switch_mode()
	if Input.is_action_just_pressed("ui_LB") and $Player.canShoot > 0:
		if aimMode:
			$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/HBoxContainer/joystick.play("aim")
			$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/HBoxContainer/joystick.stop()
	if Input.is_action_just_released("ui_LB"):
		if aimMode:
			aimMode = false
			$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/but_LT/anim_LT.play("move")
			$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/but_LT/anim_LT.stop()
			$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/but_LT/anim_LT.set_frame(1)
			$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/HBoxContainer/joystick.play("move")
			$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/HBoxContainer/joystick.stop()
		switch_mode()
	#drop mode
	if Input.is_action_pressed("ui_RT"):
		if !dropMode:
			dropMode = true
			$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer3/but_RT/anim_RT.play("drop")
			$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer3/but_RT/anim_RT.stop()
			$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer3/but_RT/anim_RT.set_frame(2)
		switch_mode()
	if Input.is_action_just_released("ui_RT"):
		if dropMode:
			dropMode = false
			$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer3/but_RT/anim_RT.play("pick")
			$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer3/but_RT/anim_RT.stop()
			$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer3/but_RT/anim_RT.set_frame(1)
		switch_mode()

func switch_mode():
	if buildMode:
		#A
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_A/anim_A.play("build")
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_A/anim_A.stop()
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_A/anim_A.set_frame(1)
		#B
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer3/but_B/anim_B.play("build")
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer3/but_B/anim_B.stop()
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer3/but_B/anim_B.set_frame(1)
		#X
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer/but_X/anim_X.play("build")
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer/but_X/anim_X.stop()
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer/but_X/anim_X.set_frame(1)
		#Y
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_Y/anim_Y.play("build")
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_Y/anim_Y.stop()
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_Y/anim_Y.set_frame(1)
	elif !dropMode and !buildMode:
		#A
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_A/anim_A.play("pick")
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_A/anim_A.stop()
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_A/anim_A.set_frame(1)
		#B
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer3/but_B/anim_B.play("pick")
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer3/but_B/anim_B.stop()
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer3/but_B/anim_B.set_frame(1)
		#X
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer/but_X/anim_X.play("pick")
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer/but_X/anim_X.stop()
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer/but_X/anim_X.set_frame(1)
		#Y
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_Y/anim_Y.play("pick")
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_Y/anim_Y.stop()
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_Y/anim_Y.set_frame(1)
	if aimMode:
		$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/Fire/anim_LB.play("aim")
		$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/Fire/anim_LB.stop()
		$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/Fire/anim_LB.set_frame(1)
	else:
		$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/Fire/anim_LB.play("move")
		$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/Fire/anim_LB.stop()
		if woodR == 0 and coalR == 0:
			$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/Fire/anim_LB.set_frame(0)
		else:
			$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/Fire/anim_LB.set_frame(1)
	if dropMode:
		#A
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_A/anim_A.play("drop")
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_A/anim_A.stop()
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_A/anim_A.set_frame(1)
		#B
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer3/but_B/anim_B.play("drop")
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer3/but_B/anim_B.stop()
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer3/but_B/anim_B.set_frame(1)
		#X
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer/but_X/anim_X.play("drop")
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer/but_X/anim_X.stop()
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer/but_X/anim_X.set_frame(1)
		#Y
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_Y/anim_Y.play("drop")
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_Y/anim_Y.stop()
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_Y/anim_Y.set_frame(1)
	elif !dropMode and !buildMode:
		#A
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_A/anim_A.play("pick")
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_A/anim_A.stop()
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_A/anim_A.set_frame(1)
		#B
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer3/but_B/anim_B.play("pick")
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer3/but_B/anim_B.stop()
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer3/but_B/anim_B.set_frame(1)
		#X
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer/but_X/anim_X.play("pick")
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer/but_X/anim_X.stop()
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer/but_X/anim_X.set_frame(1)
		#Y
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_Y/anim_Y.play("pick")
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_Y/anim_Y.stop()
		$UI/Full/HBoxContainer2/control/VBoxContainer/VBoxContainer/VBoxContainer2/but_Y/anim_Y.set_frame(1)

func consume_fuel(delta):
	if $UI/Full/HBoxContainer2/control/fuel/bar.value >= 70:
		$UI/Full/HBoxContainer2/control/fuel/bar.value -= fuelSpeed * delta * 3
		if $UI/fuel_fire.animation != "strong":
			$UI/fuel_fire.play("strong")
			$Player.boost = 1.20
	elif $UI/Full/HBoxContainer2/control/fuel/bar.value >= 15:
		$UI/Full/HBoxContainer2/control/fuel/bar.value -= fuelSpeed * delta * 2
		if $UI/fuel_fire.animation != "medium":
			$UI/fuel_fire.play("medium")
			$Player.boost = 1
	elif $UI/Full/HBoxContainer2/control/fuel/bar.value < 15 and $UI/Full/HBoxContainer2/control/fuel/bar.value > 1:
		$UI/Full/HBoxContainer2/control/fuel/bar.value -= fuelSpeed * delta
		if $UI/fuel_fire.animation != "low":
			$UI/fuel_fire.play("low")
			$Player.boost = 0.75
	elif $UI/Full/HBoxContainer2/control/fuel/bar.value <= 1:
		if $UI/fuel_fire.animation != "down":
			$UI/fuel_fire.play("down")
			$Player.boost = 0.1

func add_fuel():
	#code stat
	if coalR > 0:
		countFuelUse("coal")
		$UI/Full/HBoxContainer/VBoxContainer5/Label_stock.text = str(stock)+"/"+str(stockMax)
		$UI/Full/HBoxContainer/VBoxContainer2/Label_coal.text = str(coalR)
		$UI/Full/HBoxContainer2/control/fuel/bar.value += 60
	elif woodR > 0:
		countFuelUse("wood")
		$UI/Full/HBoxContainer/VBoxContainer5/Label_stock.text = str(stock)+"/"+str(stockMax)
		$UI/Full/HBoxContainer/VBoxContainer/label_wood.text = str(woodR)
		$UI/Full/HBoxContainer2/control/fuel/bar.value += 20
	if woodR == 0 and coalR == 0:
		$UI/Full/HBoxContainer2/control/VBoxContainer/HBoxContainer3/HBoxContainer2/Fire/anim_LB.set_frame(0)

func weightCalculator():
	#speed = (1800 + 800 * loco - 30*iron - 50*gold - 10*wood - 5*coal - 20 * stock - 50*buffle - 200*canon) * boost
	var vSpeed = (1800 + 800*$Player.w_loco - 30*ironR - 50*goldR - 10*woodR - 5*coalR - 20*$Player.w_stock - 50*$Player.w_buffle - 200*$Player.w_canon) * $Player.boost
	$Player.speed = vSpeed
	for c in $wagons.get_children():
		if c.start:
			c.speed = vSpeed

func controlRessource(type):
	if type == "stock":
		if woodR >= 2:
			woodR -= 2
			stock -= 2
			$UI/Full/HBoxContainer/VBoxContainer3/Label_iron.text = str(ironR)
			$UI/Full/HBoxContainer/VBoxContainer/label_wood.text = str(woodR)
			$UI/Full/HBoxContainer/VBoxContainer5/Label_stock.text = str(stock)+"/"+str(stockMax)
			return true
	elif type == "loco":
		if ironR >= 2:
			ironR -= 2
			stock -= 2
			$UI/Full/HBoxContainer/VBoxContainer3/Label_iron.text = str(ironR)
			$UI/Full/HBoxContainer/VBoxContainer/label_wood.text = str(woodR)
			$UI/Full/HBoxContainer/VBoxContainer5/Label_stock.text = str(stock)+"/"+str(stockMax)
			return true
	elif type == "canon":
		if ironR >= 5 and woodR >= 5:
			ironR -= 5
			woodR -= 5
			stock -= 10
			$UI/Full/HBoxContainer/VBoxContainer3/Label_iron.text = str(ironR)
			$UI/Full/HBoxContainer/VBoxContainer/label_wood.text = str(woodR)
			$UI/Full/HBoxContainer/VBoxContainer5/Label_stock.text = str(stock)+"/"+str(stockMax)
			return true
	elif type == "buffle":
		if ironR >= 1:
			ironR -= 1
			stock -= 1
			$UI/Full/HBoxContainer/VBoxContainer3/Label_iron.text = str(ironR)
			$UI/Full/HBoxContainer/VBoxContainer/label_wood.text = str(woodR)
			$UI/Full/HBoxContainer/VBoxContainer5/Label_stock.text = str(stock)+"/"+str(stockMax)
			return true
	return false

	


func build_wag(type):
#	if controlRessource(type):
		startChecked = false
		$Player.add_more_wagon(type)

func _on_move_start():
	var last_wag = $wagons.get_child($Player.wagon_num-1)
	if !last_wag.start:
		var wag_before
		if last_wag.wagonNumber == 1:
			wag_before = $Player
		else:
			wag_before = $wagons.get_child($Player.wagon_num-2)
		#check position on world
		if $level/collision.world_to_map(wag_before.position) != $level/collision.world_to_map(last_wag.position):
#			print("before: ",$level/collision.world_to_map(wag_before.position)," last : ",$level/collision.world_to_map(last_wag.position))
			var last_vPos = $level/collision.world_to_map(last_wag.position)
			var before_vPos = $level/collision.world_to_map(wag_before.position)
			if last_wag.direction == "up":
				if before_vPos.y < last_vPos.y -1:
					last_wag.start = true
					startChecked = true
					last_wag.speed = wag_before.speed
					last_wag.direction = wag_before.direction
					print("pos: ",before_vPos)
			elif last_wag.direction == "down":
					last_wag.start = true
					startChecked = true
					last_wag.speed = wag_before.speed
					last_wag.direction = wag_before.direction
					print("pos: ",before_vPos)
			elif last_wag.direction == "left":
				if before_vPos.x < last_vPos.x -1:
					last_wag.start = true
					startChecked = true
					last_wag.speed = wag_before.speed
					last_wag.direction = wag_before.direction
					print("pos: ",before_vPos)
			elif last_wag.direction == "right":
					last_wag.start = true
					startChecked = true
					last_wag.speed = wag_before.speed
					last_wag.direction = wag_before.direction
					print("pos: ",before_vPos)
#			last_wag.start = true
#			startChecked = true
#			last_wag.speed = wag_before.speed
#			last_wag.direction = wag_before.direction


func _on_mobTimer_timeout():
	add_mob()
	var wait_rand = randi() % 5 + 5
	$mobTimer.set_wait_time(wait_rand)

func add_mob():
	var mob = Mob.instance()
	mob.position.x = -40
	mob.position.y = 110
	$mobs.add_child(mob)

func drop(p_res):
	if p_res == "gold" and goldR > 0:
		goldR -= 1
		$UI/Full/HBoxContainer/VBoxContainer4/Label_gold.text = str(goldR)
	elif p_res == "iron" and ironR > 0:
		ironR -= 1
		$UI/Full/HBoxContainer/VBoxContainer3/Label_iron.text = str(ironR)
	elif p_res == "coal" and coalR > 0:
		coalR -= 1
		$UI/Full/HBoxContainer/VBoxContainer2/Label_coal.text = str(coalR)
	elif p_res == "wood" and woodR > 0:
		woodR -= 1
		$UI/Full/HBoxContainer/VBoxContainer/label_wood.text = str(woodR)
	stock -= 1
	$UI/Full/HBoxContainer/VBoxContainer5/Label_stock.text = str(stock)+"/"+str(stockMax)

func explode(pMob):
	var explo = Explode.instance()
	explo.position.x = pMob.position.x
	explo.position.y = pMob.position.y
	pMob.queue_free()
	add_child(explo)

func _on_train_explode(p_wag):
	for c in $wagons.get_children():
		if c.wagonNumber >= p_wag.wagonNumber:
			if $Player.wagon_num > 0:
				if p_wag.type == "loco":
					$Player.w_loco -= 1
				elif p_wag.type == "stock":
					print(p_wag.type)
					$Player.w_stock -= 1
					c.lossStorage()
					countRessourcesLost(c.storage)
				elif p_wag.type == "canon":
					$Player.w_canon -= 1
					$Player.canShoot -= 1
				$UI/Full/HBoxContainer/VBoxContainer5/Label_stock.text = str(stock)+"/"+str(stockMax)
				$Player.wagon_list.remove(p_wag.wagonNumber)
				$Player.wagon_num -= 1
				c.queue_free()
			var explo = Explode.instance()
			explo.position.x = c.position.x
			explo.position.y = c.position.y
			add_child(explo)

func countRessourcesLost(storage):
	for i in storage:
		lostRessource(storage,i)

func countFuelUse(fuel):
	for c in $wagons.get_children():
		if c.type == "stock":
			for i in c.storage:
				if i == fuel:
					lostRessource(c.storage,i)

func lostRessource(wag_storage,res):
	if res == "gold":
		if goldR > 0:
			goldR -= 1
			$UI/Full/HBoxContainer/VBoxContainer4/Label_gold.text = str(goldR)
	elif res == "wood":
		if woodR > 0:
			woodR -= 1
			$UI/Full/HBoxContainer/VBoxContainer/label_wood.text = str(woodR)
	elif res == "iron":
		if ironR > 0:
			ironR -= 1
			$UI/Full/HBoxContainer/VBoxContainer3/Label_iron.text = str(ironR)
	elif res == "coal":
		if coalR > 0:
			coalR -= 1
			$UI/Full/HBoxContainer/VBoxContainer2/Label_coal.text = str(coalR)
	wag_storage.pop_back()
	stock -= 1
	$UI/Full/HBoxContainer/VBoxContainer5/Label_stock.text = str(stock)+"/"+str(stockMax)

func countRessourcesGain(res):
	for i in $wagons.get_children():
		if i.type == "stock":
			if i.storage.size() < 4:
				i.storage.push_back(res)
				i.loadStorage()

func change_aim_direction(dir):
	for c in $wagons.get_children():
		if c.type == "canon":
			c.aim_direction = dir
			c.get_node("AnimatedSprite/canon").play(dir)

func fullShoot():
	for c in $wagons.get_children():
		if c.type == "canon":
			c.shootCanon()

func loadLevel(level):
	var resLevel = load("res://"+level+".tscn")
	var newLevel = resLevel.instance()
	add_child_below_node($levelPos,newLevel)
	print("load level :", level)
	playerStartPosition()

func playerStartPosition():
	var cells = $level/items.get_used_cells()
	for c in cells:
		if $level/items.get_cellv(c) == 1:
			$Player.position.x = c.x * 13 + 0
			$Player.position.y = c.y * 13 + 6
	$Player.add_wagon($Player.direction)
