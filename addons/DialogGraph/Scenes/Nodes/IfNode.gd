tool
extends GraphNodeDialogueBase

export var is_use_random:bool setget set_is_use_random

var operations = ["==", "!=", ">", ">=", "<", "<=", "== Variable", "!= Variable", "> Variable", ">= Variable", "< Variable", "<= Variable"]

func get_instructions() -> Array:
	var result:Array = []
#	if Variable/var_name =  [ variable_name:String, operation:String, value:Variant ]
#	if Random = 			[ variable_name:String, operation:String, min:int, max:int ]
	result.append($Variable.text)
	result.append($PanelContainer/HBox/Operation.text)
	if $Variable.text == "Variable":
		result.append("")
		return result
	var value = $PanelContainer/HBox/LineEdit.text
	if $Variable.text == "Random":
		result.append(int(value))
		result.append($HBoxContainer/SpinBox_min.value)
		result.append($HBoxContainer2/SpinBox_max.value)
		return result
	match DialogueManager.tree["Variables"][$Variable.text][1]:
		"int": result.append(int(value))
		"float": result.append(float(value))
		"string": result.append(value)
		_: result.append("")
	return result

func set_instructions(instructions:Array):
#	[ variable_name:String, operation:String, value:Variant ]
	print("set_instructions(instructions) 1")
	$Variable.text = instructions[0]
	$PanelContainer/HBox/LineEdit.text = str(instructions[2])
	update_ui()
	print("set_instructions(instructions) 2")
	$PanelContainer/HBox/Operation.text = instructions[1]
	if instructions[0] == "Random":
		$HBoxContainer/SpinBox_min.value = instructions[3]
		$HBoxContainer2/SpinBox_max.value = instructions[4]

func _on_Variable_button_down():
#	print("%s _on_Variable_button_down() DialogueManager.tree_varibales_without_signals.size(): %s, DialogueManager.tree_varibales_without_signals:%s"%[_print, DialogueManager.tree_varibales_without_signals.size(), DialogueManager.tree_varibales_without_signals])
	$Variable.clear()
	$Variable.add_item("Random")
	$Variable.select(-1)
	if DialogueManager.tree_varibales_without_signals.size() == 0: 
		$Variable.text = "Variable"
		return
	for variable in DialogueManager.tree_varibales_without_signals:
		$Variable.add_item(variable)
	$Variable.select(-1)

func _on_Variable_focus_exited():
	if $Variable.text == "":
		$Variable.text = "Variable"

func set_is_use_random(new:bool):
	is_use_random = new
	if is_use_random:
		$HBoxContainer2/SpinBox_max.visible = true
		$HBoxContainer/SpinBox_min.visible = true
	else:
		$HBoxContainer2/SpinBox_max.visible = false
		$HBoxContainer/SpinBox_min.visible = false

func get_type() -> String:
	return "IfNode"

func mouse_enter():
	get_parent().owner.zoom_lock(true)
	pass

func mouse_exit():
	get_parent().owner.zoom_lock(false)
	pass

func _ready():
	set_is_use_random(false)
	update_ui()
	$PanelContainer/HBox/Operation.clear()
	$PanelContainer/HBox/Operation.text = "Select Variable"

func update_ui():
	set_is_use_random(false)
	var var_name = $Variable.text
	$PanelContainer/HBox/Operation.clear()
	for operation in operations:
		$PanelContainer/HBox/Operation.add_item(operation)
	if var_name == "Random": 
		set_is_use_random(true)
		return
	if var_name == "Variable": 
		set_is_use_random(false)
		return
	var var_type = DialogueManager.tree["Variables"][var_name][1]
	$PanelContainer/HBox.visible = true
	match var_type:
		"bool":
			$PanelContainer/HBox.visible = false
		"string":
			$PanelContainer/HBox/Operation.clear()
			$PanelContainer/HBox/Operation.add_item("==")
			$PanelContainer/HBox/Operation.add_item("!=")
		_:
			$PanelContainer/HBox/Operation.clear()
			for operation in operations:
				$PanelContainer/HBox/Operation.add_item(operation)

func _on_Variable_item_selected(index):
	update_ui()
