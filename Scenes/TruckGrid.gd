extends Node2D

export var CELL_SIZE = 16
export var TRUCK_SIZE: Vector2 = Vector2(24, 40)

export(float, EXP, 0.1, 10, 0.1) var TIMER_INTERVAL = 1.0

var GRIDCELL = load("res://Objects/GridCell.tscn")

func set_wait_time(time: float):
	$Timer.wait_time = time

func _ready():
	$Cells.rect_size = (TRUCK_SIZE * CELL_SIZE) + Vector2(1, 1) # fixes the grids on the right and bottom not being closed off
	set_wait_time(TIMER_INTERVAL)

func get_cell_rpos(pos: Vector2):
	return (pos * CELL_SIZE) - (Vector2(CELL_SIZE/2, CELL_SIZE/2) + Vector2(2, 2))

var i = Vector2(0, 1)
func _on_Timer_timeout():
	i.x += 1

	if i.x > TRUCK_SIZE.x:
		i.x = 0
		i.y += 1

	$ColorRect.rect_position = get_cell_rpos(i)
