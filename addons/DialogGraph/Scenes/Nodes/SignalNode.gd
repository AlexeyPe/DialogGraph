tool
extends GraphNodeDialogueBase

const _print = "Addon:DialogueGraph, SignalNode.gd"

func get_type() -> String:
	return "SignalNode"

func get_instructions() -> Array:
	var result:Array = []
#	[ signal_name:String, signal_data:Dictionary ]
	result.append($OptionButton.text)
	if $LineEdit.text == "" or $LineEdit.text == null:
		result.append({})
		return result
	var data = JSON.parse($LineEdit.text).result
	if typeof(data) == TYPE_DICTIONARY:
		result.append(data)
	else:
		printerr('%s get_instructions() typeof(data) != TYPE_DICTIONARY. Correct: {"key1": value, "key2": value}'%[_print])
		result.append({})
	return result

func set_instructions(instructions:Array):
	$OptionButton.text = instructions[0]
	$LineEdit.text = JSON.print(instructions[1])

func update_option_button():
	$OptionButton.clear()
	for _signal in DialogueManager.tree_signals:
		$OptionButton.add_item(_signal)


func _on_SignalNode_resize_request(new_minsize):
	rect_size = new_minsize


func _on_OptionButton_button_down():
	update_option_button()
	pass # Replace with function body.


func _on_OptionButton_item_selected(index):
	get_parent().owner.save_tree()


func _on_LineEdit_focus_exited():
	get_parent().owner.save_tree()


func _on_LineEdit_text_entered(new_text):
	get_parent().owner.save_tree()
