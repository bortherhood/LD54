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

func set_object_type(name):
	$Texture.texture = load("res://Textures/" + OBJECT_TYPES[name].texture)

	spaces = OBJECT_TYPES[name].spaces


func _ready():
	set_object_type("chair")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
