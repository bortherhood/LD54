extends Control

func _ready():
	$CenterBox/VBox/HSlider.value = -Settings.setting.audio_volume_shift

func _on_HSlider_value_changed(value: float):

	if not $Blip.playing:
		$Blip.volume_db = (Audio.BASE_VOL - (-value / 2)) - 2
		Settings.setting.audio_volume_shift = -value
		Audio.update_volumes()

		$Blip.play()
