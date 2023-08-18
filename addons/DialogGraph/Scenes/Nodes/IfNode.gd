tool
extends GraphNodeDialogueBase

export var is_use_random_port:bool setget set_is_use_random_port

var operations = ["==", "!=", ">", ">=", "<", "<="]

func get_instructions() -> Array:
	var result:Array = []
#	[ variable_name:String, operation:String, value:Variant ]
	result.append($Variable.text)
	result.append($PanelContainer/HBox/Operation.text)
	var value = $PanelContainer/HBox/LineEdit.text
	match DialogueManager.tree["Variables"][$Variable.text][1]:
		"int": result.append(int(value))
		"float": result.append(float(value))
		"string": result.append(value)
		_: result.append("")
	return result

func set_instructions(instructions:Array):
#	[ variable_name:String, operation:String, value:Variant ]
	$Variable.text = instructions[0]
	$PanelContainer/HBox/LineEdit.text = str(instructions[2])
	update_ui()
	$PanelContainer/HBox/Operation.text = instructions[1]
	pass

func _on_Variable_button_down():
#	print("%s _on_Variable_button_down() DialogueManager.tree_varibales_without_signals.size(): %s, DialogueManager.tree_varibales_without_signals:%s"%[_print, DialogueManager.tree_varibales_without_signals.size(), DialogueManager.tree_varibales_without_signals])
	$Variable.clear()
	if DialogueManager.tree_varibales_without_signals.size() == 0: 
		$Variable.text = "Variable"
		return
	$Variable.add_item("Random Port")
	for variable in DialogueManager.tree_varibales_without_signals:
		$Variable.add_item(variable)
	$Variable.select(-1)

func _on_Variable_focus_exited():
	if $Variable.text == "":
		$Variable.text = "Variable"

func set_is_use_random_port(new:bool):
	is_use_random_port = new
	if !has_node("HBoxContainer/is_use_random_port"):return
	if is_use_random_port:
		set_slot_enabled_left(2, true)
		$HBoxContainer/is_use_random_port.visible = true
	else:
		set_slot_enabled_left(2, false)
		$HBoxContainer/is_use_random_port.visible = false

func get_type() -> String:
	return "IfNode"

#func _ready():
#	set_is_use_random_port(false)

func update_ui():
	set_is_use_random_port(false)
	var var_name = $Variable.text
	if var_name == "Random Port": 
		set_is_use_random_port(true)
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
