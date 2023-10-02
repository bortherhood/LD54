extends CenterContainer

# Fields to fill
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

func _ready():
	# 0 = total blocks placed
	# 1 = time remaining bonus multiplier
	# 2 = score grand total
	
	set_data_var("ScoreGrandTotal", "Grand Score:", ScoreManager.finalized_score_breakdown[0])
	set_data_var("TotalBlockNumberPlaced", "Total Items Loaded:", ScoreManager.finalized_score_breakdown[1])
	set_data_var("TimeBonusMultiplier", "Time Bonus Multiplier:", ScoreManager.finalized_score_breakdown[3])
	set_data_var("TotalScoreForFilledSpaces", "Score Sum:", ScoreManager.finalized_score_breakdown[4])

func set_data_var(data_entry_name: String, text: String, value):
	get_node("HBox/VBox/" + data_entry_name + "/DataName").text = text
	get_node("HBox/VBox/" + data_entry_name + "/DataValue").text = str(value)
