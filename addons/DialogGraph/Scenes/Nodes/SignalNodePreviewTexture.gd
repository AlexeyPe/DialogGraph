tool
extends GraphNodeDialogueBase

const _print = "Addon:DialogueGraph, SignalNodePreviewTexture.gd"

export var texture_error:Texture

func get_type() -> String:
	return "SignalNodePreviewTexture"

func get_instructions() -> Array:
	var result:Array = []
#	[ signal_name:String, signal_data:Dictionary ]
#	signal_data = {"img_path": String}
	result.append($OptionButton.text)
	var data = {"img_path": $LineEdit.text}
	result.append(data)
	return result

func set_instructions(instructions:Array):
	$OptionButton.text = instructions[0]
	$LineEdit.text = instructions[1]["img_path"]
	update_preview()

func on_delete_variable(variable_name:String, variable_value, variable_type:String):
	if DialogueManager.tree_signals.size() == 0:
		$OptionButton.text == "select signal"

func update_option_button():
	$OptionButton.clear()
	for _signal in DialogueManager.tree_signals:
		$OptionButton.add_item(_signal)

func _on_OptionButton_button_down():
#	tree_signals - is [String]
	update_option_button()

func _ready():
	DialogueManager.connect("on_delete_variable", self, "on_delete_variable")
	update_option_button()
	if $OptionButton.selected == -1 and DialogueManager.tree_signals.size() > 0: $OptionButton.selected = 0

func update_preview():
	if File.new().file_exists($LineEdit.text) == false: 
		$TextureRect.texture = texture_error
		return
	var new_texture = load($LineEdit.text)
	print(typeof(new_texture))
	$TextureRect.texture = new_texture


func _on_LineEdit_text_entered(new_text):
	update_preview()
	get_parent().owner.save_tree()


func _on_LineEdit_focus_exited():
	update_preview()
	get_parent().owner.save_tree()

func _on_SignalNodePreviewTexture_resize_request(new_minsize):
	rect_size = new_minsize
