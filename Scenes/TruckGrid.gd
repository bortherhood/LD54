extends Node2D
class_name TruckGrid

const CELL_SIZE = 16
const TRUCK_SIZE: Vector2 = Vector2(10, 16)

export(float, EXP, 0.1, 10, 0.1) var TIMER_INTERVAL = 0.6

enum MOVE {left, right, down, up, check}
enum MOVERESULT {ok, collision, leftbounds, rightbounds}

var GRIDCELL = load("res://Objects/GridObject.tscn")

var _gridobjects = []

var GAME_OVER = false

func _game_over():
	$Timer.stop()
	GAME_OVER = true
	Audio.play("GameOver.wav")
	_gridobjects.pop_back().queue_free()

func set_wait_time(time: float):
	$Timer.wait_time = time

func get_cell_rpos(pos, y: int=0):
	if pos is int:
		pos = Vector2(pos, y)

	return pos * CELL_SIZE

func add_object(name: String):
	var newobject = GRIDCELL.instance()

	self.add_child(newobject)

	newobject.set_object_type(name)

	newobject.object_pos = Vector2(TRUCK_SIZE.x/2 - newobject.get_object_size().x/2, -newobject.get_object_size().y).round()
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

		# Doesn't detect all kinds of collisions, scrapping for now
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
						if pos.y <= 0:
							_game_over()

						return MOVERESULT.collision

	obj.object_pos = pos
	obj.position = get_cell_rpos(pos)

	return MOVERESULT.ok

# @GridObject@5 - (3, 14) - 0 - 0
# (3, 3) - -3 - -2
# (3, 3) - -2 - -3
# (3, 3) - -1 - -2
# @GridObject@5 - (3, 14) - 0 - 1
# (3, 3) - -3 - -1
# (3, 3) - -2 - -2
# (3, 3) - -1 - -1
# @GridObject@5 - (3, 14) - 1 - 0
# (3, 3) - -2 - -2
# (3, 3) - -1 - -3
# (3, 3) - 0 - -2
# @GridObject@5 - (3, 14) - 2 - 0
# (3, 3) - -1 - -2
# (3, 3) - 0 - -3
# (3, 3) - 1 - -2


func _ready():
	$Cells.rect_size = (TRUCK_SIZE * CELL_SIZE) + Vector2(1, 1) # 1,1 fixes the grids on the right and bottom not being closed off
	set_wait_time(TIMER_INTERVAL)

	add_object("random")

var _presstime = {
	"left": 0,
	"right": 0,
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

	if Input.is_action_just_pressed("rotate_right"):
		obj.rotate_object(1)
		Audio.play("Rotate.wav")

	if Input.is_action_just_pressed("rotate_left"):
		obj.rotate_object(-1)
		Audio.play("Rotate.wav")

	if Input.is_action_just_pressed("next_piece"):
		while move_object(obj, MOVE.down) == MOVERESULT.ok:
			pass

		block_land(obj.spaces)

func _on_Timer_timeout():
	if not _gridobjects.empty():
		var obj = _gridobjects.back()
		if move_object(obj, MOVE.down) == MOVERESULT.collision and not GAME_OVER:
			block_land(obj.spaces)

func block_land(block_spaces: Array):
	# First value in score array is the base score, second value is the bonus score
	var score_array: Array = ScoreManager.calculate_block_score(block_spaces)
	var final_score: float = score_array[0] + score_array[1]
	
	Audio.play("Place")
	
	_gridobjects.back().show_score("+" + str(final_score) + " score", final_score)
	add_object("random")
