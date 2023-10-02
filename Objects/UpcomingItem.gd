extends HSplitContainer

func setup(oname: String):
	$Control/GridObject.set_object_type(oname)

	var tsize = $Control/GridObject.get_object_size()

	rect_size.y = tsize.y * TruckGrid.CELL_SIZE

	$Control/GridObject/BG.rect_size = (tsize * TruckGrid.CELL_SIZE) + Vector2(1, 1)
	$Control/GridObject.position.y = -tsize.y * TruckGrid.CELL_SIZE/2
