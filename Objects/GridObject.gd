extends Node2D
class_name GridObject

var rng = RandomNumberGenerator.new()

export var id: String = ""
export var spaces = []
export var object_pos = Vector2()

var OBJECT_LIST = []
const OBJECT_TYPES = {
	"chair": {
		id = "chair",
		texture = "Chair.png",
		spaces = [
			[1, 0],
			[1, 1],
		]
	},
	"bed": {
		id = "bed",
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

const MAX_SCORE = 1320
func show_score(text, score):
	var color = Color.from_hsv((score / MAX_SCORE) * 0.3, 1, 1) # h: 0, 0.5, 1.3, ..., 4 | RED, YELLOW, GREEN, etc, back to red

	$Score/Text.text = text
	$Score/Text.set("custom_colors/font_color",            color)
	$Score/Text.set("custom_colors/font_outline_modulate", color.darkened(0.4))

	$Score.mode = $Score.MODE_RIGID
	$Score.linear_velocity = Vector2(rng.randi_range(-60, 60), -70)

	$Score.visible = true
	$Score/Timer.start()

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

	var d = TruckGrid.MOVE.check
	while true:
		match get_parent().move_object(self, d):
			TruckGrid.MOVERESULT.leftbounds:
				d = TruckGrid.MOVE.right
			TruckGrid.MOVERESULT.rightbounds:
				d = TruckGrid.MOVE.left
			TruckGrid.MOVERESULT.collision:
				d = TruckGrid.MOVE.up
			TruckGrid.MOVERESULT.ok:
				break

	spaces = a

func get_object_size():
	return Vector2(spaces[0].size(), spaces.size())

func set_object_type(name):
	if name == "random":
		name = OBJECT_LIST[rng.randi_range(0, OBJECT_LIST.size()-1)]

	id = OBJECT_TYPES[name].id
	spaces = OBJECT_TYPES[name].spaces.duplicate(true)

	$Texture.texture = load("res://Textures/" + OBJECT_TYPES[name].texture)
	$Texture.rect_size         = TruckGrid.CELL_SIZE * get_object_size()
	$Texture.rect_pivot_offset = TruckGrid.CELL_SIZE * get_object_size() / 2

	$Score/Text.rect_size = $Texture.rect_size * 2
	$Score/Text.rect_position = -$Texture.rect_size/2


func _on_Timer_timeout():
	$Score.queue_free()
