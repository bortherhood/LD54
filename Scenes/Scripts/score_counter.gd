extends Reference


var timer: Timer


func _ready():
	pass

func _process(delta):
	pass

func score_counter(block_section_num: int, score_multiplier: float):
	var score: float
	var time_elapsed: int
	score = block_section_num * score_multiplier / time_elapsed
