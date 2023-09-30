extends Node2D

# * set_wait_time()
# * add_object()
#
# * get_cell_rpos

export var CELL_SIZE = 16
export var TRUCK_SIZE: Vector2 = Vector2(24, 40)

export(float, EXP, 0.1, 10, 0.1) var TIMER_INTERVAL = 0.6

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

	newobject.position = get_cell_rpos(2, 2)
	self.add_child(newobject)
	newobject.set_object_type(name)

	_gridobjects.append(newobject)

func _ready():
	$Cells.rect_size = (TRUCK_SIZE * CELL_SIZE) + Vector2(1, 1) # 1,1 fixes the grids on the right and bottom not being closed off
	set_wait_time(TIMER_INTERVAL)

	add_object("chair")

var _presstime = {
	"left": 0,
	"right": 0,
}
func _process(delta):
	var obj = _gridobjects.back()
	var pos = obj.position
	var change: bool = false

	if Input.is_action_pressed("move_left") and pos.x > 0:
		if Input.is_action_just_pressed("move_left") or _presstime.left >= TIMER_INTERVAL/2:
			pos.x -= CELL_SIZE
			_presstime.left = 0
			change = true
		else:
			_presstime.left += delta

	if Input.is_action_pressed("move_right") and pos.x < (TRUCK_SIZE.x - obj.get_object_size().x) * CELL_SIZE:
		if Input.is_action_just_pressed("move_right") or _presstime.right >= TIMER_INTERVAL/2:
			pos.x += CELL_SIZE
			_presstime.right = 0
			change = true
		else:
			_presstime.right += delta

	if Input.is_action_just_pressed("rotate_right"):
		obj.rotate_object(1)

	if Input.is_action_just_pressed("rotate_left"):
		obj.rotate_object(-1)

	if change:
		obj.position = pos

func _on_Timer_timeout():
	if not _gridobjects.empty():
		_gridobjects.back().position.y += CELL_SIZE
