extends Node2D

var rng = RandomNumberGenerator.new()

export var CELL_SIZE = 16
export var TRUCK_SIZE: Vector2 = Vector2(12, 20)

var OBJECT_LIST = []
const OBJECT_TYPES = {
	"chair": {
		texture = "Chair.png",
		spaces = [
			[1, 0],
			[1, 1],
		]
	},
	"bed": {
		texture = "Bed.png",
		spaces = [
			[0, 0, 0],
			[1, 0, 0],
			[1, 1, 1],
		]
	},
}

export(float, EXP, 0.1, 10, 0.1) var TIMER_INTERVAL = 0.6

enum MOVE {left, right, down}

var GRIDCELL = load("res://Objects/GridObject.tscn")

var _gridobjects = []

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

	newobject.object_pos = Vector2(rng.randi_range(0, TRUCK_SIZE.x - newobject.get_object_size().x), 0)
	newobject.position = get_cell_rpos(newobject.object_pos)

	_gridobjects.append(newobject)

#returns false if it can't be moved
func move_object(obj, side = MOVE.down):
	var pos = obj.object_pos
	var size = obj.get_object_size()
	var check_against = []

	if side == MOVE.down:
		pos.y += 1
	elif side == MOVE.right:
		pos.x += 1
	elif side == MOVE.left:
		pos.x -= 1

	# Check if moved object is in bounds
	if pos.x < 0 or pos.x + size.x > TRUCK_SIZE.x:
		return false
	elif pos.y + size.y > TRUCK_SIZE.y:
		return false

	# Sort through other objects to detect basic cubic overlap
	for i in range(_gridobjects.size()-1): #ignore our object
		var o = _gridobjects[i]
		var opos = o.object_pos
		var osize = o.get_object_size()

		if ((
		pos.x >= opos.x and pos.x <= opos.x + osize.x and
		pos.y >= opos.y and pos.y <= opos.y + osize.y
		) or (
		pos.x + size.x >= opos.x and pos.x + size.x <= opos.x + osize.x and
		pos.y + size.y >= opos.y and pos.y + size.y <= opos.y + osize.y
		)):
			check_against.append(o)

	# check if any cells overlap with another object's (using our list of basic overlaps)
	for row in range(obj.spaces.size()):
		for col in range(obj.spaces[row].size()):
			if obj.spaces[row][col] == 1:
				for o in check_against:
					var s = o.get_object_size()
					var r = row + (pos.y - o.object_pos.y) # 0
					var c = col + (pos.x - o.object_pos.x) # 1
					if r >= 0 and c >= 0 and r < s.y and c < s.x and o.spaces[r][c] == 1:
						#o.get_node("ColorRect").rect_position = (Vector2(c, r) * CELL_SIZE) + Vector2((CELL_SIZE / 2) - 2, (CELL_SIZE / 2) - 2) # width 4 color rect for debug
						#print(o.spaces)
						return false

	obj.object_pos = pos
	obj.position = get_cell_rpos(pos)

	return true

func _ready():
	rng.randomize()

	for name in OBJECT_TYPES:
		OBJECT_LIST.append(name)

	$Cells.rect_size = (TRUCK_SIZE * CELL_SIZE) + Vector2(1, 1) # 1,1 fixes the grids on the right and bottom not being closed off
	set_wait_time(TIMER_INTERVAL)

	add_object(OBJECT_LIST[rng.randi_range(0, OBJECT_LIST.size()-1)])

var _presstime = {
	"left": 0,
	"right": 0,
}
func _process(delta):
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

	if Input.is_action_just_pressed("rotate_left"):
		obj.rotate_object(-1)

	if Input.is_action_just_pressed("next_piece"):
		while move_object(obj, MOVE.down):
			pass

		add_object(OBJECT_LIST[rng.randi_range(0, OBJECT_LIST.size()-1)])

func _on_Timer_timeout():
	if not _gridobjects.empty():
		if not move_object(_gridobjects.back(), MOVE.down):
			add_object(OBJECT_LIST[rng.randi_range(0, OBJECT_LIST.size()-1)])
