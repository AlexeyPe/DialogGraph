tool
extends GraphNodeDialogueBase

const _print = "Addon:DialogueGraph, SetNode.gd"

const TypeOperationIntFloat = ["=", "+=", "-=", "*=", "/=", "%=", "abs"]
const TypeOperationBool = ["=", "inverting"]
const TypeOperationString = ["=", "+="]

func get_type() -> String:
	return "SetNode"

func _ready():
	$HBox/SpinBox_int_value.get_line_edit().connect("focus_exited", self, "focus_exit")
	$HBox/SpinBox_float_value.get_line_edit().connect("focus_exited", self, "focus_exit")

func get_instructions() -> Array:
	var result:Array = []
#	[ variable:String, value:Variant, operation:String ]
#	variable - key for tree["Variables"]
#	value - bool/int/float/string
	var variable_name = $Variable.text
	var variable_operation = $HBox/Operation.text
	var variable_value = null
	if variable_name == "Variable":
		result.append(null)
		result.append(null)
		result.append(null)
		return result
	var variable_type = DialogueManager.tree['Variables'][variable_name][1]
	match variable_type:
		"bool": variable_value = $HBox/CheckBox.pressed
		"string": variable_value = $HBox/LineEdit_string.text
		"int": variable_value = $HBox/SpinBox_int_value.value
		"float": variable_value = $HBox/SpinBox_float_value.value
	
	result.append(variable_name)
	result.append(variable_value)
	if variable_operation != "Select Variable": result.append(variable_operation)
	else: result.append(null)
	return result

func set_instructions(instructions:Array):
#	[ variable:String, value:Variant, operation:String ]
#	variable - key for tree["Variables"]
#	value - bool/int/float/string
	var variable_name = instructions[0]
	var variable_value = instructions[1]
	var variable_operation = instructions[2]
	
	if variable_name == null: return
	$Variable.text = variable_name
	if variable_operation == null: return
	$HBox/Operation.text = variable_operation
	if variable_value == null: return
	var variable_type = DialogueManager.tree['Variables'][variable_name][1]
	match variable_type:
		"bool": $HBox/CheckBox.pressed = variable_value
		"string": $HBox/LineEdit_string.text = variable_value
		"int": $HBox/SpinBox_int_value.value = variable_value 
		"float": $HBox/SpinBox_float_value.value = variable_value
	update_ui()
	$HBox/Operation.text = variable_operation

func _on_Variable_button_down():
#	print("%s _on_Variable_button_down() DialogueManager.tree_varibales_without_signals.size(): %s, DialogueManager.tree_varibales_without_signals:%s"%[_print, DialogueManager.tree_varibales_without_signals.size(), DialogueManager.tree_varibales_without_signals])
	$Variable.clear()
	if DialogueManager.tree_varibales_without_signals.size() == 0: 
		$Variable.text = "Variable"
		return
	for variable in DialogueManager.tree_varibales_without_signals:
		$Variable.add_item(variable)
	$Variable.select(-1)

func update_ui():
	var variable_name = $Variable.text
	var variable_type = DialogueManager.tree['Variables'][variable_name][1]
	
	$HBox/Operation.clear()
	$HBox/LineEdit_string.visible = false
	$HBox/SpinBox_int_value.visible = false
	$HBox/SpinBox_float_value.visible = false
	$HBox/CheckBox.visible = false
	
	match variable_type:
		"bool":
			for operation in TypeOperationBool:
				$HBox/Operation.add_item(operation)
			$HBox/CheckBox.visible = true
		"int":
			for operation in TypeOperationIntFloat:
				$HBox/Operation.add_item(operation)
			$HBox/SpinBox_int_value.visible = true
		"float":
			for operation in TypeOperationIntFloat:
				$HBox/Operation.add_item(operation)
			$HBox/SpinBox_float_value.visible = true
		"string":
			for operation in TypeOperationString:
				$HBox/Operation.add_item(operation)
			$HBox/LineEdit_string.visible = true
#	if $HBox/Operation.text == "Select Variable":
#		$HBox/Operation.select(0)

func _on_Variable_item_selected(index):
	update_ui()
	get_parent().owner.save_tree()


func _on_Variable_focus_exited():
	if $Variable.text == "":
		$Variable.text = "Variable"
		$HBox/Operation.clear()
		$HBox/Operation.text = "Select Variable"

func mouse_enter():
	get_parent().owner.zoom_lock(true)

func mouse_exit():
	get_parent().owner.zoom_lock(false)

func focus_exit():
	print("focus_exit, value int ", $HBox/SpinBox_int_value.value)
	get_parent().owner.save_tree()

func _on_Operation_item_selected(index):
	var variable_name = $Variable.text
	var variable_type = DialogueManager.tree['Variables'][variable_name][1]
	match variable_type:
		"bool":
			match $HBox/Operation.text:
				"inverting": $HBox/CheckBox.visible = false
				"=": $HBox/CheckBox.visible = true
		"int":
			if $HBox/Operation.text == "abs": $HBox/SpinBox_int_value.visible = false
			else: $HBox/SpinBox_int_value.visible = true
		"float":
			if $HBox/Operation.text == "abs": $HBox/SpinBox_float_value.visible = false
			else: $HBox/SpinBox_float_value.visible = true
	get_parent().owner.save_tree()


func _on_SetNode_resize_request(new_minsize):
	rect_size = new_minsize


func _on_SpinBox_int_value_modal_closed():
	print("n_SpinBox_int_value_modal_closed")
 


func _on_CheckBox_pressed():
	get_parent().owner.save_tree()
