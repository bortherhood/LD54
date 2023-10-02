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

var block_id_array_size_pairs: Dictionary = {}
var score_breakdown: Dictionary = {
	"blocks": {},
	"time": {}
	}


func _ready():
	for block in GridObject.OBJECT_TYPES:
		
		# Number of spaces the block takes up
		var block_size: int = 0
		
		for row in GridObject.OBJECT_TYPES[block].spaces:
			for object_space in row:
				block_size += object_space
		
		# Saves that there are blocks that take up `block_spaces_quanity` of spaces
		# Only saves for the first found, as the object's *arrangement* of spaces
		# doesn't matter
		if not score_breakdown.has(block_size):
			score_breakdown[block_size] = 0
		
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
func calculate_block_score(block_id: String) -> Array:
	var block_spaces_quantity: int = block_id_array_size_pairs[block_id]
	# Used to store the base score value of block for calculation purposes
	var base_value: int = block_spaces_quantity * 100
	
	# Updates `score_breakdown`
	# And terminates if we got a block with 0 spcaes (and so no score)
	# (Basically just safety checking. If that last bit gets triggered
	# someone screwed up)
	if not block_spaces_quantity < 1:
		score_breakdown[block_spaces_quantity] += 1
	else:
		push_warning("Block with 0 assigned spaces placed")
		return [0, 0]
	
	# Covers 1-2 [inclusive range]
	# Have direct bonus & score values
	if block_spaces_quantity == 2:
		return [base_value, duo_space_value]
	elif block_spaces_quantity == 1:
		return [base_value, 0]
	
	# Applies to an [inclusive] range of block spaces from 3 to 6
	elif block_spaces_quantity > 2 && block_spaces_quantity < 7:
		return [base_value, base_value / 2 - space_values_range[0]]
	
	# Applies to an [inclusive] range of block spaces from 7 to 12
	elif block_spaces_quantity > 6 && block_spaces_quantity < 13:
		return [base_value, base_value / 2 - space_values_range[1]]
	
	# Applies to blocks with at least 13 spaces
	else:
		return [base_value, base_value / 2 - space_values_range[2]]

# Takes a block spaces array and checks the `blocks_spaces_array_size_pairs`
# dictionary to quickly find the saved space *quantity* for the given
# block spaces array "fingerprint"
#
# Returns an int that is the sum of the base score and block spaces bonus
# Also increases the counter in `score_breakdown` for the number of spaces
# the given block has.
func calculate_block_score_int(block_id: String) -> int:
	var block_spaces_quantity: int = block_id_array_size_pairs[block_id]
	# Used to store the base score value of block for calculation purposes
	var base_value: int = block_spaces_quantity * 100
	
	# Updates `score_breakdown`
	# And terminates if we got a block with 0 spcaes (and so no score)
	# (Basically just safety checking. If that last bit gets triggered
	# someone screwed up)
	if not block_spaces_quantity < 1:
		score_breakdown[block_spaces_quantity] += 1
	else:
		push_warning("Block with 0 assigned spaces placed")
		return 0
	
	# Covers 1-2 [inclusive range]
	# Have direct bonus & score values
	if block_spaces_quantity == 2:
		return 200 + duo_space_value
	elif block_spaces_quantity == 1:
		return 100
	
	# Applies to an [inclusive] range of block spaces from 3 to 6
	elif block_spaces_quantity > 2 && block_spaces_quantity < 7:
		return base_value + base_value / 2 - space_values_range[0]
	
	# Applies to an [inclusive] range of block spaces from 7 to 12
	elif block_spaces_quantity > 6 && block_spaces_quantity < 13:
		return base_value + base_value / 2 - space_values_range[1]
	
	# Applies to blocks with at least 13 spaces
	else:
		return base_value + base_value / 2 - space_values_range[2]
