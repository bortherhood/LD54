extends Node2D

export var spaces = []

const OBJECT_TYPES = {
	"chair": {
		texture = "Chair.png",
		spaces = [
			[1, 0],
			[1, 1],
		]
	}
}

func rotate_object(dir = 1):
	var a = spaces
	var s = a[0].size()

	if dir == 1:
		$Texture.set_rotation($Texture.get_rotation() + (PI / 2))
		for i in range(s / 2 as int):
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
		for i in range(s / 2 as int):
			var l = s - 1 - i
			for j in range(i, l):
				var k = l - (j - i)
				var tmp = a[i][j]
				a[i][j] = a[j][l]
				a[j][l] = a[l][k]
				a[l][k] = a[k][i]
				a[k][i] = tmp

	spaces = a
	print("Rotated", spaces)

func get_object_size():
	return Vector2(spaces[0].size(), spaces.size())

func set_object_type(name):
	spaces = OBJECT_TYPES[name].spaces

	$Texture.texture = load("res://Textures/" + OBJECT_TYPES[name].texture)
	$Texture.rect_size = get_parent().CELL_SIZE * (get_object_size())
	$Texture.rect_pivot_offset = get_parent().CELL_SIZE * (get_object_size() / 2)


func _ready():
	set_object_type("chair")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
