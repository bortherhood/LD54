extends Node2D

const SPACE_SIZE = 16
const TRUCK_SIZE: Vector2 = Vector2(8, 20)

func _ready():
	$Grid.color = Color("#362c86")
	$Grid.rect_size = TRUCK_SIZE * SPACE_SIZE
