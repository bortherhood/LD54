extends Node2D

export var spaces = []
export var object_pos = Vector2()

func _ready():

	pass
	# rotate_object(1, OBJECT_TYPES["chair"].spaces)
	# assert(OBJECT_TYPES["chair"].spaces[0][0] == 1)
	# assert(OBJECT_TYPES["chair"].spaces[0][1] == 1)
	# assert(OBJECT_TYPES["chair"].spaces[1][0] == 1)
	# assert(OBJECT_TYPES["chair"].spaces[1][1] == 0)
	# rotate_object(1, OBJECT_TYPES["chair"].spaces)
	# assert(OBJECT_TYPES["chair"].spaces[0][0] == 1)
	# assert(OBJECT_TYPES["chair"].spaces[0][1] == 1)
	# assert(OBJECT_TYPES["chair"].spaces[1][0] == 0)
	# assert(OBJECT_TYPES["chair"].spaces[1][1] == 1)
	# rotate_object(1, OBJECT_TYPES["chair"].spaces)
	# assert(OBJECT_TYPES["chair"].spaces[0][0] == 0)
	# assert(OBJECT_TYPES["chair"].spaces[0][1] == 1)
	# assert(OBJECT_TYPES["chair"].spaces[1][0] == 1)
	# assert(OBJECT_TYPES["chair"].spaces[1][1] == 1)
	# rotate_object(1, OBJECT_TYPES["chair"].spaces)
	# assert(OBJECT_TYPES["chair"].spaces[0][0] == 1)
	# assert(OBJECT_TYPES["chair"].spaces[0][1] == 0)
	# assert(OBJECT_TYPES["chair"].spaces[1][0] == 1)
	# assert(OBJECT_TYPES["chair"].spaces[1][1] == 1)

	# rotate_object(-1, OBJECT_TYPES["chair"].spaces)
	# assert(OBJECT_TYPES["chair"].spaces[0][0] == 0)
	# assert(OBJECT_TYPES["chair"].spaces[0][1] == 1)
	# assert(OBJECT_TYPES["chair"].spaces[1][0] == 1)
	# assert(OBJECT_TYPES["chair"].spaces[1][1] == 1)
	# rotate_object(-1, OBJECT_TYPES["chair"].spaces)
	# assert(OBJECT_TYPES["chair"].spaces[0][0] == 1)
	# assert(OBJECT_TYPES["chair"].spaces[0][1] == 1)
	# assert(OBJECT_TYPES["chair"].spaces[1][0] == 0)
	# assert(OBJECT_TYPES["chair"].spaces[1][1] == 1)
	# rotate_object(-1, OBJECT_TYPES["chair"].spaces)
	# assert(OBJECT_TYPES["chair"].spaces[0][0] == 1)
	# assert(OBJECT_TYPES["chair"].spaces[0][1] == 1)
	# assert(OBJECT_TYPES["chair"].spaces[1][0] == 1)
	# assert(OBJECT_TYPES["chair"].spaces[1][1] == 0)
	# rotate_object(-1, OBJECT_TYPES["chair"].spaces)
	# assert(OBJECT_TYPES["chair"].spaces[0][0] == 1)
	# assert(OBJECT_TYPES["chair"].spaces[0][1] == 0)
	# assert(OBJECT_TYPES["chair"].spaces[1][0] == 1)
	# assert(OBJECT_TYPES["chair"].spaces[1][1] == 1)

func rotate_object(dir = 1, sp = spaces):
	var a = sp
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

func get_object_size():
	var size = Vector2(0, 0)

	for row in range(spaces.size()):
		var all_zero = true
		for col in range(spaces[row].size()):
			size.x = max(size.x, col+1)

			if spaces[row][col] == 1:
				all_zero = false

		if not all_zero:
			size.y += 1

	return size

func set_object_type(name):
	spaces = get_parent().OBJECT_TYPES[name].spaces.duplicate(true)

	$Texture.texture = load("res://Textures/" + get_parent().OBJECT_TYPES[name].texture)
	$Texture.rect_size         = get_parent().CELL_SIZE * get_object_size()
	$Texture.rect_pivot_offset = get_parent().CELL_SIZE * (get_object_size() / 2).floor()
