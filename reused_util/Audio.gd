extends Node

var rng = RandomNumberGenerator.new()

var BASE_VOL = -8

var sounds = {}

# You can add sounds here
func _ready():
	rng.randomize()

	new_soundgroup("Place", [
		["Place.wav", -4],
		["Place2.wav", -3],
	])
	new_sound("Rotate.wav", 0)
	new_sound("GameOver.wav", 4)

enum SOUND {filename, volume}
func new_soundgroup(name, sgroup):
	for data in sgroup:
		var audionode = AudioStreamPlayer.new()

		audionode.volume_db = BASE_VOL + data[SOUND.volume]
		audionode.stream = load("res://SoundEffects/" + data[SOUND.filename])

		if not name in sounds:
			sounds[name] = {"nodes": [audionode], "playpos": 0, volumes = [data[SOUND.volume]]}
		else:
			sounds[name].nodes.append(audionode)
			sounds[name].volumes.append(data[SOUND.volume])

		add_child(audionode)

func new_sound(name, volume):
	var audionode = AudioStreamPlayer.new()

	audionode.volume_db = BASE_VOL + volume
	audionode.stream = load("res://SoundEffects/" + name)
	sounds[name] = {"node": audionode, "playpos": 0, volume = volume}

	add_child(audionode)

	print("Loaded Audio: ", name)

func new_music(name, volume):
	var audionode = AudioStreamPlayer.new()

	audionode.volume_db = BASE_VOL + volume
	audionode.stream = load("res://Music/" + name)
	sounds[name] = {"node": audionode, "playpos": 0, volume = volume}

	add_child(audionode)

	print("Loaded Music: ", name)

var _time = 0
func _process(delta):
	_time += delta

	if _time >= 0.5:
		_time = 0

		for sound in sounds:
			if "node" in sounds[sound]:
				sounds[sound].node.volume_db = (BASE_VOL - (Settings.setting.audio_volume_shift / 2)) + sounds[sound].volume
			else:
				for i in range(sounds[sound].nodes.size()):
					sounds[sound].nodes[i].volume_db = (BASE_VOL - (Settings.setting.audio_volume_shift / 2)) + sounds[sound].volumes[i]

func play(sound_name):
	if sounds[sound_name]:
		print("Playing sound " + sound_name)
		if "node" in sounds[sound_name]:
			sounds[sound_name].node.play()
		else:
			var i = rng.randi_range(0, sounds[sound_name].nodes.size()-1)
			sounds[sound_name].nodes[i].play()

func play_low(sound_name, vol_shift):
	if sounds[sound_name]:
		print("Playing sound " + sound_name)

		if "node" in sounds[sound_name]:
			sounds[sound_name].node.volume_db = (BASE_VOL - (Settings.setting.audio_volume_shift / 2)) + sounds[sound_name].volume + vol_shift
			sounds[sound_name].node.play()
		else:
			var i = rng.randi_range(0, sounds[sound_name].nodes.size()-1)

			sounds[sound_name].nodes[i].volume_db = (BASE_VOL - (Settings.setting.audio_volume_shift / 2)) + sounds[sound_name].volumes[i] + vol_shift
			sounds[sound_name].nodes[i].play()

# Works for everything but soundgroups
func resume(sound_name):
	if sounds[sound_name]:
		print("Resuming sound " + sound_name)
		sounds[sound_name].node.play(sounds[sound_name].playpos)

# Works for everything but soundgroups
func stop(sound_name):
	if sounds[sound_name]:
		print("Stopping sound " + sound_name)
		sounds[sound_name].playpos = sounds[sound_name].node.get_playback_position()
		sounds[sound_name].node.stop()
