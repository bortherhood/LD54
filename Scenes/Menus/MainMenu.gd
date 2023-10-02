extends Control

onready var center_box: CenterContainer = $CenterBox
onready var highscore_display: Label = $CenterBox/VBox/HighscoreBG/VBox/HighscoreDisplay

func _ready():
	center_box.set_size(Vector2(OS.window_size.x / 2, rect_size.y))
	highscore_display.text = Settings.setting["highscore"] as String

	Audio.stop("Game.ogg")
	Audio.play("MainMenu.ogg")

func _on_button_activate(button):
	if button == "Quit":
		Quit.quit()
	elif button == "Start":
		Audio.stop("MainMenu.ogg")
		Audio.play("Game.ogg")
