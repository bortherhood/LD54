extends Node2D

var rng = RandomNumberGenerator.new()

export var spaces = []
export var object_pos = Vector2()

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

func _ready():
	rng.randomize()

	for name in OBJECT_TYPES:
		OBJECT_LIST.append(name)

func rotate_object(dir = 1, sp = spaces):
	var a = sp
	var s = a[0].size()

	if dir == 1:
		$Texture.set_rotation($Texture.get_rotation() + (PI / 2))
		for i in range((s - (s % 2)) / 2):
			for j in range(i, s - i - 1):
				var k = s - 1 - j
				var l = s - 1 - i
				var tmp = a[i][j]
				a[i][j] = a[k][i]
				a[k][i] = a[l][k]
				a[l][k] = a[j][l]
				a[j][l] = tmp
	elif dir == -1:
		$Texture.set_rotation($Texture.get_rotation() - (PI / 2))
		for i in range((s - (s % 2)) / 2):
			var l = s - 1 - i
			for j in range(i, l):
				var k = l - (j - i)
				var tmp = a[i][j]
				a[i][j] = a[j][l]
				a[j][l] = a[l][k]
				a[l][k] = a[k][i]
				a[k][i] = tmp

	var MOVE = get_parent().MOVE
	var MOVERESULT = get_parent().MOVERESULT
	var d = MOVE.check
	while true:
		match get_parent().move_object(self, d):
			MOVERESULT.leftbounds:
				d = MOVE.right
			MOVERESULT.rightbounds:
				d = MOVE.left
			MOVERESULT.collision:
				d = MOVE.up
			MOVERESULT.ok:
				break

	spaces = a

func get_object_size():
	return Vector2(spaces[0].size(), spaces.size())

func set_object_type(name):
	if name == "random":
		name = OBJECT_LIST[rng.randi_range(0, OBJECT_LIST.size()-1)]

	spaces = OBJECT_TYPES[name].spaces.duplicate(true)

	$Texture.texture = load("res://Textures/" + OBJECT_TYPES[name].texture)
	$Texture.rect_size         = get_parent().CELL_SIZE * get_object_size()
	$Texture.rect_pivot_offset = get_parent().CELL_SIZE * (get_object_size() / 2)
