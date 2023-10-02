extends Node

# The score bonus for n amount of spaces a block occupies
# Seperated into 3 formulas, plus a direct value for blocks of 2 spaces.
# Formulas for each range are as follows, where n = number of spaces the block occupies:
# 2 : 45 (n * 100) / 2 - 55 (though stored as a direct value)
# 3-6: (n * 100) / 2 - 50
# 7-12: (n * 100) / 2 - 35
# 13+: (n * 100) / 2 - 20

var duo_space_value: int = 45
var space_values_range: Array = [50, 35, 20]
var time_remaining: float = 300

var block_id_array_size_pairs: Dictionary = {}
var score_breakdown: Dictionary = {
	"blocks": {},
	"object_quantity_placed": {},
	"block_complexity_bonus": 0,
	"block_score_total": 0,
	"time_remaining": 300,
	"time_remaining_bonus_multiplier": 1
	}

var finalized_score_breakdown: Array

func _ready():
	
	for block in GridObject.OBJECT_TYPES:
		
		# Number of spaces the block takes up
		var block_size: int = 0
		
		for row in GridObject.OBJECT_TYPES[block].spaces:
			for object_space in row:
				block_size += object_space
		
		score_breakdown["object_quantity_placed"][GridObject.OBJECT_TYPES[block].id] = 0
		
		# Saves that there are blocks that take up `block_spaces_quanity` of spaces
		# Only saves for the first found, as the object's *arrangement* of spaces
		# doesn't matter
		if not score_breakdown["blocks"].has(block_size):
			score_breakdown["blocks"][block_size] = 0
		
		if not block_id_array_size_pairs.has(GridObject.OBJECT_TYPES[block].id):
			block_id_array_size_pairs[GridObject.OBJECT_TYPES[block].id] = block_size

# Takes a block spaces array and checks the `blocks_spaces_array_size_pairs`
# dictionary to quickly find the saved space *quantity* for the given
# block spaces array "fingerprint"
#
# Returns an array, with the first value being the base score...
# and the second being the bonus score
# Also increases the counter in `score_breakdown` for the number of spaces
# the given block has.
#
# Also increases the counter in `score_breakdown` for how instances many of that
# object have been placed.
func add_block_score_to_board(block_id: String):
	var block_spaces_quantity: int = block_id_array_size_pairs[block_id]
	# Used to store the base score value of block for calculation purposes
	var base_value: int = block_spaces_quantity * 100
	
	# Updates `score_breakdown`
	# And terminates if we got a block with 0 spaces (and so no score)
	# (Basically just safety checking. If that last bit gets triggered
	# someone screwed up)
	if not block_spaces_quantity < 1:
		score_breakdown["blocks"][block_spaces_quantity] += 1
	else:
		push_warning("Block with 0 assigned spaces placed")
		return
	
	score_breakdown["object_quantity_placed"][block_id] +=1
	score_breakdown["block_score_total"] += base_value
	
	# Calculate and store block complexity bonus values
	# Starts from 2 as 1 has no bonus score
	if block_spaces_quantity == 2:
		score_breakdown["block_complexity_bonus"] += duo_space_value
	
	# Applies to an [inclusive] range of block spaces from 3 to 6
	elif block_spaces_quantity > 2 && block_spaces_quantity < 7:
		score_breakdown["block_complexity_bonus"] += base_value / 2.0 - space_values_range[0]
	
	# Applies to an [inclusive] range of block spaces from 7 to 12
	elif block_spaces_quantity > 6 && block_spaces_quantity < 13:
		score_breakdown["block_complexity_bonus"] += base_value / 2.0 - space_values_range[1]
	
	# Applies to blocks with at least 13 spaces
	else:
		score_breakdown["block_complexity_bonus"] += base_value / 2.0 - space_values_range[2]

func generate_score_breakdown_array():
	# Multiplier reaches approx. 1.5x by the time the stopwatch hits
	# 180 seconds (two mins elapsed/3 left)
	if score_breakdown["time_remaining"] <= 180:
		score_breakdown["time_remaining_bonus_multiplier"] = clamp(time_remaining / 1000 * 8.34, 1.5, 2.0)
	
	# Multiplier reaches approx. 1.3x by the time the stopwatch hits
	# 30 seconds (four and a half mins elapsed/half a min left)
	elif time_remaining <= 30:
		score_breakdown["time_remaining_bonus_multiplier"] = clamp(time_remaining / 1000 *  7.25, 1.3, 1.5)
	
	# No time bonus multiplier once you hit 30 seconds left
	# So the default multiplier of 1x is already fine
	
	# # #
	
	# Begin building array
	#
	# 0 = score grand total
	# 1 = total blocks placed
	#
	# 2 = time remaining in seconds
	# 3 = time remaining bonus multiplier
	#
	# 4 = score sum
	# 5 = base score for number of spaces filled
	# 6 = bonus score for number of spaces filled
	#
	# 7 = total blocks of each type placed [some sort of list]
	# 8 = total blocks placed
	
	var breakdown: Array = [
		0,
		0,
		
		score_breakdown["time_remaining"],
		score_breakdown["time_remaining_bonus_multiplier"],
		
		score_breakdown["block_score_total"] + score_breakdown["block_complexity_bonus"],
		score_breakdown["block_score_total"],
		score_breakdown["block_complexity_bonus"],
		
		{},
		0
	]
	
	# Create list of number of each type of block placed inside `breakdown` array
	for block_id in score_breakdown["object_quantity_placed"]:
		for block in score_breakdown["object_quantity_placed"][block_id]:
			breakdown[1] += 1
			breakdown[8] += 1
		
		breakdown[7][block_id] = 0
		breakdown[7][block_id] += score_breakdown["object_quantity_placed"][block_id]
	
	breakdown[0] = breakdown[4] * breakdown[3]
	
	finalized_score_breakdown = breakdown.duplicate(true)
