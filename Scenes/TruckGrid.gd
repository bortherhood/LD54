extends Node2D

export var CELL_SIZE = 16
export var TRUCK_SIZE: Vector2 = Vector2(12, 20)

func _ready():
	$Cells.rect_size = (TRUCK_SIZE * CELL_SIZE) + Vector2(1, 1)
