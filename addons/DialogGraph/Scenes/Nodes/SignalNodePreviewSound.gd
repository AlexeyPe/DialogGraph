tool
extends GraphNodeDialogueBase

const _print = "Addon:DialogueGraph, SignalNodePreviewSound.gd"

var sound_path:String = ""
var signal_select:String = ""
var stop:bool

func get_type() -> String:
	return "SignalNodePreviewSound"

func get_instructions() -> Array:
	var result:Array = []
#	[ signal_name:String, signal_data:Dictionary ]
#	signal_data = {"SoundPath":String, "Loop":bool, "PitchMin":float/null, "PitchMax":float/null, "dB":float}
	result = [
		signal_select,
		{
			"SoundPath": sound_path,
			"Loop": $HBoxContainer/VBoxContainer2/CheckBox_loop.pressed,
			"PitchMin": $HBoxContainer/VBoxContainer/SpinBox_min.value,
			"PitchMax": $HBoxContainer/VBoxContainer/SpinBox_max.value,
			"dB": $HBoxContainer/VBoxContainer/SpinBox_dB.value
		}
	]
	if !$HBoxContainer/VBoxContainer/CheckBox_random_pitch.pressed:
		result[1]["PitchMin"] = null
		result[1]["PitchMax"] = null
	return result

func set_instructions(instructions:Array):
#	[ signal_name:String, signal_data:Dictionary ]
#	signal_data = {"SoundPath":String, "Loop":bool, "PitchMin":float/null, "PitchMax":float/null, "dB":float}
	signal_select = instructions[0]
	$OptionButton_signal.text = instructions[0]
	sound_path = instructions[1]["SoundPath"]
	$HBoxContainer2/LineEdit_path.text = sound_path
	$HBoxContainer/VBoxContainer2/CheckBox_loop.pressed = instructions[1]["Loop"]
	if instructions[1]["PitchMin"] != null and instructions[1]["PitchMax"] != null:
		$HBoxContainer/VBoxContainer/SpinBox_min.value = instructions[1]["PitchMin"]
		$HBoxContainer/VBoxContainer/SpinBox_max.value = instructions[1]["PitchMax"]
		$HBoxContainer/VBoxContainer/CheckBox_random_pitch.pressed = true
	$HBoxContainer/VBoxContainer/SpinBox_dB.value = instructions[1]["dB"]
	update_ui()

func set_disabled(new:bool):
	$HBoxContainer/VBoxContainer/CheckBox_random_pitch.disabled = new
	$HBoxContainer/VBoxContainer/SpinBox_dB.editable = !new
	$HBoxContainer/VBoxContainer/SpinBox_min.editable = !new
	$HBoxContainer/VBoxContainer/SpinBox_max.editable = !new
	$HBoxContainer/VBoxContainer2/CheckBox_loop.disabled = new
	$HBoxContainer/VBoxContainer2/Button_play.disabled = new
	

func update_ui():
	if sound_path != "":
		$HBoxContainer2/TextureRect_path_ok.visible = true
		$HBoxContainer2/TextureRect_path_err.visible = false
	else:
		$HBoxContainer2/TextureRect_path_ok.visible = false
		$HBoxContainer2/TextureRect_path_err.visible = true
	if sound_path == "" or signal_select == "":
		set_disabled(true)
	else:
		set_disabled(false)
	if $HBoxContainer/VBoxContainer/CheckBox_random_pitch.pressed:
		$HBoxContainer/VBoxContainer/SpinBox_min.visible = true
		$HBoxContainer/VBoxContainer/SpinBox_max.visible = true
	else:
		$HBoxContainer/VBoxContainer/SpinBox_min.visible = false
		$HBoxContainer/VBoxContainer/SpinBox_max.visible = false

func _ready():
	update_ui()

func _on_SignalNodePreviewSound_resize_request(new_minsize):
	rect_size = new_minsize


func _on_OptionButton_signal_button_down():
	$OptionButton_signal.clear()
	for _signal in DialogueManager.tree_signals:
		$OptionButton_signal.add_item(_signal)
	$OptionButton_signal.select(-1)
	$OptionButton_signal.text = "Variable"

func _on_OptionButton_signal_item_selected(index):
	if $OptionButton_signal.text != "Variable":
		signal_select = $OptionButton_signal.text
		update_ui()

func set_path(new:String):
	var file = File.new()
	if !file.file_exists(new): return
	if load(new) is AudioStream:
		sound_path = new
		update_ui()

func _on_LineEdit_path_text_entered(new_text):
	set_path(new_text)


func _on_LineEdit_path_focus_exited():
	set_path($HBoxContainer2/LineEdit_path.text)


func _on_CheckBox_random_pitch_toggled(button_pressed):
	update_ui()


func mouse_entered():
	get_parent().owner.zoom_lock(true)
	pass # Replace with function body.


func mouse_exited():
	get_parent().owner.zoom_lock(false)
	pass # Replace with function body.

func get_pitch() -> float:
	var result:float = 1.0
	if $HBoxContainer/VBoxContainer/CheckBox_random_pitch.pressed:
		var r_min = $HBoxContainer/VBoxContainer/SpinBox_min.value
		var r_max = $HBoxContainer/VBoxContainer/SpinBox_max.value
		var rnd = RandomNumberGenerator.new()
		rnd.randomize()
		result = rnd.randf_range(r_min, r_max)
	return result

func _on_Button_play_pressed():
	stop = false
	var stream = load(sound_path)
	$AudioStreamPlayer.stream = stream
	$AudioStreamPlayer.volume_db = $HBoxContainer/VBoxContainer/SpinBox_dB.value
	$AudioStreamPlayer.pitch_scale = get_pitch()
	$AudioStreamPlayer.play()
	$HBoxContainer/VBoxContainer2/Button_play.visible = false
	$HBoxContainer/VBoxContainer2/Button_stop.visible = true


func _on_Button_stop_pressed():
	stop = true
	$AudioStreamPlayer.stop()
	$HBoxContainer/VBoxContainer2/Button_play.visible = true
	$HBoxContainer/VBoxContainer2/Button_stop.visible = false


func _on_AudioStreamPlayer_finished():
	$HBoxContainer/VBoxContainer2/Button_play.visible = true
	$HBoxContainer/VBoxContainer2/Button_stop.visible = false
	if $HBoxContainer/VBoxContainer2/CheckBox_loop.pressed and !stop:
		_on_Button_play_pressed()
