extends Node2D

export var GAME_TIME = 5 * 60
export var WAIT_TIME = 5

onready var TRUCKGRID = $Control/TruckGrid
onready var PROGRESS  = $TimeKeep/Progress
onready var TIMELABEL = $TimeKeep/TimeLabel
onready var TIMEKEEPER = $TimeKeep/TimeKeeper
onready var NOTES = $Notepad/Notes
onready var SUMMARY = $Notepad/Notes/Summary
onready var SCORE = $Notepad/Notes/Score

var UPCOMINGITEM = load("res://Objects/UpcomingItem.tscn")
var upcoming_items = []

var rng = RandomNumberGenerator.new()

var time_left = GAME_TIME

func _ready():
	rng.randomize()

	$UncheckTimer.wait_time = WAIT_TIME
	SUMMARY.visible = false

	update_timekeep()

	for _i in range(8):
		var item = UPCOMINGITEM.instance()

		NOTES.add_child(item)

		upcoming_items.append(item)

	update_upcoming()

	TRUCKGRID.connect("object_placed", self, "_update_upcoming")
	TRUCKGRID.connect("game_over", self, "_update_upcoming", [true])
	TRUCKGRID.connect("game_over", self, "_game_over")

func _game_over():
	$TimeKeep/TimeKeeper.stop()

	$Notepad/Notes/Extra.text = "Game Over"

	SUMMARY.visible = true

var _latest_update = 0
func _update_upcoming(no_timer: bool = false):
	if no_timer or _latest_update >= upcoming_items.size():
		if $UncheckTimer.is_stopped():
			update_upcoming()
		else:
			$UncheckTimer.stop()
			_on_UncheckTimer_timeout()
	else:
		upcoming_items[_latest_update].get_node("Unchecked").visible = false
		upcoming_items[_latest_update].get_node("Checked").visible = true
		_latest_update += 1

		print(_latest_update, " : ", _latest_update > 1)

		if _latest_update <= 1:
			$UncheckTimer.start()
		else:
			if not $UncheckTimer.is_stopped():
				$UncheckTimer.stop()

			$UncheckTimer.start(max(1, $UncheckTimer.wait_time - _latest_update))

func update_upcoming():
	var delete = upcoming_items.size() - TRUCKGRID.object_queue.size()

	if delete > 0:
		for _i in range(delete):
			upcoming_items.pop_back().queue_free()

	if not TRUCKGRID.GAME_OVER and upcoming_items.empty():
		TRUCKGRID.game_over(true)
		return

	for i in range(upcoming_items.size()):
		upcoming_items[i].setup(TRUCKGRID.object_queue[i])

	SCORE.text = "Score: " + (TRUCKGRID.score as String)

	if $Notepad/Notes/Extra.text != "Game Over":
		$Notepad/Notes/Extra.text = "Todo: %3d" % TRUCKGRID.object_queue.size()

func update_timekeep():
	var seconds = time_left % 60
	var minutes = (time_left - seconds) / 60

	TIMELABEL.text = "%d:%s" % [minutes, "00" if seconds == 0 else (seconds if seconds >= 10 else "0"+(seconds as String))]

	PROGRESS.value = 0.0 if time_left <= 0 else ((GAME_TIME as float)/(time_left as float) * 3.0)

func save_timekeep_value_to_score_manager():
	ScoreManager.score_breakdown["time_remaining"] = time_left as float
	ScoreManager.generate_score_breakdown_array()
	Settings.setting.highscore = max(ScoreManager.finalized_score_breakdown[0], Settings.setting.highscore)

func _on_TimeKeeper_timeout():
	if time_left <= 0:
		TRUCKGRID.game_over()
		TIMEKEEPER.stop()
		return

	time_left -= 1

	update_timekeep()

func _on_UncheckTimer_timeout():
	for i in _latest_update:
		upcoming_items[i].get_node("Unchecked").visible = true
		upcoming_items[i].get_node("Checked").visible = false

	_latest_update = 0
	$UncheckTimer.wait_time = WAIT_TIME
	update_upcoming()
