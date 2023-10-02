extends Control

var _playblip = false

func _ready():
	$CenterBox/VBox/HSlider.value = -Settings.setting.audio_volume_shift
	$CenterBox/VBox/Difficulty.value = Settings.setting.difficulty

	_playblip = true

	$CenterBox/VBox/KeyChangeEntry.refresh(true)

func _on_HSlider_value_changed(value: float):
	if not $Blip.playing:
		$Blip.volume_db = (Audio.BASE_VOL - (-value / 2)) - 2
		Settings.setting.audio_volume_shift = -value
		Audio.update_volumes()

		if _playblip:
			$Blip.play()

func _on_Difficulty_value_changed(value:float):
	Settings.setting.difficulty = value

	Settings.update()
