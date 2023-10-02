extends Control

func _ready():
	$CenterBox/VBox/HSlider.value = -Settings.setting.audio_volume_shift

	if !Settings.setting.keybinds.empty():
		for action in Settings.setting.keybinds.keys():
			InputMap.add_action(action)
			InputMap.action_add_event(action, to_inputevent(OS.find_scancode_from_string(Settings.setting.keybinds[action])))

	$CenterBox/VBox/KeyChangeEntry.refresh(true)

func to_inputevent(x):
	var out = InputEventKey.new()

	out.set_scancode(x)

	return out

func _on_HSlider_value_changed(value: float):
	if not $Blip.playing:
		$Blip.volume_db = (Audio.BASE_VOL - (-value / 2)) - 2
		Settings.setting.audio_volume_shift = -value
		Audio.update_volumes()

		$Blip.play()
