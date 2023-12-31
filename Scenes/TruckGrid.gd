extends Node2D
class_name TruckGrid

signal object_placed
signal game_over_time_remaining
signal game_over

const CELL_SIZE = 16
const TRUCK_SIZE: Vector2 = Vector2(10, 16)

export(float, EXP, 0.1, 10, 0.1) var TIMER_INTERVAL = 1.0

enum MOVE {left, right, down, up, check}
enum MOVERESULT {ok, collision, leftbounds, rightbounds}

var GRIDOBJECT = load("res://Objects/GridObject.tscn")
var GRIDOBJECT_I = GRIDOBJECT.instance()
var rng = RandomNumberGenerator.new()

var _gridobjects = []

const variations = [
	["sofa", "l_chair", "l_chair", "macuphin", "chair", "sofa", "stick_1", "stick_2", "stick_1", "macuphin", "l_chair", "chair", "sofa"],
	["sofa", "chair", "macuphin", "coffee_or_cryogen", "stick_2", "chair", "chair", "sofa", "sofa", "l_chair", "l_chair", "sofa"],
	["stick_1", "coffee_or_cryogen", "coffee_or_cryogen", "stick_1", "coffee_or_cryogen", "stick_1", "coffee_or_cryogen", "sofa", "chair", "sofa", "stick_1", "stick_2", "coffee_or_cryogen"],
	["stick_1", "l_chair", "l_chair", "stick_1", "stick_1", "sofa", "l_chair", "stick_2", "chair", "l_chair", "coffee_or_cryogen", "l_chair", "sofa", "chair"],
]

var object_queue = ["sofa", "l_chair"]
var score: int = 0

var GAME_OVER = false

func game_over(win: bool = false):
	$Timer.stop()
	GAME_OVER = true

	if not win:
		Audio.play("GameOver.wav")

	emit_signal("game_over_time_remaining") # (Currently also generates scoreboard via function called in `Game)`

	_gridobjects.pop_back().queue_free()

	object_queue = []
	emit_signal("game_over")

func set_wait_time(time: float):
	$Timer.wait_time = time

func get_cell_rpos(pos, y: int=0):
	if pos is int:
		pos = Vector2(pos, y)

	return pos * CELL_SIZE

func add_object():
	var newobject = GRIDOBJECT.instance()

	self.add_child(newobject)

	if object_queue.size() > 0:
		newobject.set_object_type(object_queue.front())
	else:
		newobject.set_object_type("random")

	newobject.object_pos = Vector2(TRUCK_SIZE.x/2 - newobject.get_object_size().x/2, -newobject.get_object_size().y - 3).round()
	newobject.position = get_cell_rpos(newobject.object_pos)

	_gridobjects.append(newobject)

	newobject.visible = false

	if move_object(newobject, MOVE.check) == MOVERESULT.ok:
		newobject.visible = true

func move_object(obj, side = MOVE.down):
	var pos = obj.object_pos
	var size = obj.get_object_size()
	var check_against = []

	match side:
		MOVE.down:
			pos.y += 1
		MOVE.up:
			pos.y -= 1
		MOVE.right:
			pos.x += 1
		MOVE.left:
			pos.x -= 1

	# Check if moved object is in bounds
	if pos.x < -size.x:
		return MOVERESULT.leftbounds
	if pos.x > TRUCK_SIZE.x:
		return MOVERESULT.rightbounds
	if pos.y > TRUCK_SIZE.y:
		return MOVERESULT.collision

	if pos.x < 0:
		var collide = false

		for row in obj.spaces:
			if row[-pos.x - 1] == 1:
				collide = true
				break
		if collide:
			return MOVERESULT.leftbounds
	if pos.x + size.x > TRUCK_SIZE.x:
		var collide = false

		for row in obj.spaces:
			if row[size.x - (pos.x + size.x - TRUCK_SIZE.x)] == 1:
				collide = true
				break
		if collide:
			return MOVERESULT.rightbounds

	if pos.y + size.y > TRUCK_SIZE.y:
		var collide = false

		for col in obj.spaces[size.y - (pos.y+size.y - TRUCK_SIZE.y)]:
			if col == 1:
				collide = true
				break
		if collide:
			return MOVERESULT.collision

	# Sort through other objects to detect basic cubic overlap
	for i in range(_gridobjects.size()-1): #ignore our object
		var o = _gridobjects[i]
		# var opos = o.object_pos
		# var osize = o.get_object_size()

		#### Doesn't detect all kinds of collisions, scrapping for now

		# if ((
		# pos.x >= opos.x and pos.x <= opos.x + osize.x and
		# pos.y >= opos.y and pos.y <= opos.y + osize.y
		# ) or (
		# pos.x + size.x >= opos.x and pos.x + size.x <= opos.x + osize.x and
		# pos.y + size.y >= opos.y and pos.y + size.y <= opos.y + osize.y
		# )):
		check_against.append(o)

	# check if any cells overlap with another object's (using our list of basic overlaps)
	for row in range(obj.spaces.size()):
		for col in range(obj.spaces[row].size()):
			if obj.spaces[row][col] == 1:
				for o in check_against:
					var s = o.get_object_size()
					var r = row + (pos.y - o.object_pos.y)
					var c = col + (pos.x - o.object_pos.x)

					if r >= 0 and c >= 0 and r < s.y and c < s.x and o.spaces[r][c] == 1:
						# o.get_node("ColorRect").rect_position = (Vector2(c, r) * CELL_SIZE) + Vector2((CELL_SIZE / 2) - 2, (CELL_SIZE / 2) - 2) # width 4 color rect for debug
						if pos.y < 0:
							game_over()

						return MOVERESULT.collision

	obj.object_pos = pos
	obj.position = get_cell_rpos(pos)

	return MOVERESULT.ok

func _ready():
	var game_nodes: Array = get_tree().get_nodes_in_group("game_node")

	if game_nodes.size() == 1:
		if connect("game_over_time_remaining", game_nodes[0], "save_timekeep_value_to_score_manager") != OK:
			push_error("AHHHHH")

	rng.randomize()

	$Cells.rect_size = (TRUCK_SIZE * CELL_SIZE) + Vector2(1, 1) # 1,1 fixes the grids on the right and bottom not being closed off
	set_wait_time(TIMER_INTERVAL)

	for _i in range(3):
		var add = variations[rng.randi_range(0, variations.size()-1)]
		for x in add:
			object_queue.append(x)

	add_object()

var _presstime = {
	"left" : 0,
	"right": 0,
	"down" : 0,
}
func _process(delta):
	if GAME_OVER:
		return

	var obj = _gridobjects.back()

	if Input.is_action_pressed("move_left"):
		if Input.is_action_just_pressed("move_left"):
			move_object(obj, MOVE.left)
			_presstime.left = TIMER_INTERVAL - 1 # 1 second before repeat starts
		elif _presstime.left >= TIMER_INTERVAL / 4:
			move_object(obj, MOVE.left)
			_presstime.left = 0
		else:
			_presstime.left += delta

	if Input.is_action_pressed("move_right"):
		if Input.is_action_just_pressed("move_right"):
			move_object(obj, MOVE.right)
			_presstime.right = TIMER_INTERVAL - 1 # 1 second before repeat starts
		elif _presstime.right >= TIMER_INTERVAL / 4:
			move_object(obj, MOVE.right)
			_presstime.right = 0
		else:
			_presstime.right += delta

	if Input.is_action_pressed("move_down"):
		if Input.is_action_just_pressed("move_down"):
			if move_object(obj, MOVE.down) == MOVERESULT.collision:
				block_land(obj.id)

			_presstime.down = TIMER_INTERVAL - 1 # 1 second before repeat starts
		elif _presstime.down >= TIMER_INTERVAL / 4:
			if move_object(obj, MOVE.down) == MOVERESULT.collision:
				block_land(obj.id)

			_presstime.down = 0
		else:
			_presstime.down += delta

	if Input.is_action_just_pressed("rotate_right"):
		obj.rotate_object(1)
		Audio.play("Rotate.wav")

	if Input.is_action_just_pressed("rotate_left"):
		obj.rotate_object(-1)
		Audio.play("Rotate.wav")

	if Input.is_action_just_pressed("next_piece"):
		var instant_collide = true

		while move_object(obj, MOVE.down) == MOVERESULT.ok:
			instant_collide = false

		if not instant_collide:
			block_land(obj.id)

func _on_Timer_timeout():
	if not _gridobjects.empty():
		var obj = _gridobjects.back()
		if move_object(obj, MOVE.down) == MOVERESULT.collision and not GAME_OVER:
			block_land(obj.id)

func block_land(block_id: String):
	ScoreManager.add_block_score_to_board(block_id)

	Audio.play("Place")

	object_queue.pop_front()

	# Need to add the complexity bonus to this equation
	var block_spaces_quantity: int = ScoreManager.block_id_array_size_pairs[block_id]
	var s: float = block_spaces_quantity * 100
	if block_spaces_quantity == 2:
		s += ScoreManager.duo_space_value

	# Applies to an [inclusive] range of block spaces from 3 to 6
	elif block_spaces_quantity > 2 && block_spaces_quantity < 7:
		s = s / 2.0 - ScoreManager.space_values_range[0]

	# Applies to an [inclusive] range of block spaces from 7 to 12
	elif block_spaces_quantity > 6 && block_spaces_quantity < 13:
		s = s / 2.0 - ScoreManager.space_values_range[1]

	# Applies to blocks with at least 13 spaces
	else:
		s = s / 2.0 - ScoreManager.space_values_range[2]

	score += (s as int)
	Settings.setting.highscore = max(s, Settings.setting.highscore)

	Settings.update()

	_gridobjects.back().show_score("+" + (s as String) + " score", s)

	emit_signal("object_placed")

	add_object()
