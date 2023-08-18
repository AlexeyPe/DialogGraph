tool
extends GraphNodeDialogueBase

const _print = "Addon:DialogueGraph, MatchNode.gd"

# 1 Default node, 
var match_node_count:int = 1

func get_type() -> String:
	return "MatchNode"

func get_instructions() -> Array:
	var result:Array = []
#	[ variable_name:String, match_cases:Array ]
#	match_cases = [ value: String/int/float ]
	result.append($Variable.text)
	result.append([])
	if $Variable.text == "Variable": return result
	for i in match_node_count:
		var case = get_node("MatchNodeCase_"+str(i+1))
		if case.is_default: continue
		match DialogueManager.tree["Variables"][$Variable.text][1]:
			"int": result[1].append(int(case.get_value()))
			"float": result[1].append(float(case.get_value()))
			"string": result[1].append(case.get_value())
	return result

func set_instructions(instructions:Array):
#	[ variable_name:String, match_cases:Array ]
#	match_cases = [ value: String/int/float ]
	match_node_count = 1
	$Variable.text = instructions[0]
	print("\n\t\t\tinstructions ", instructions)
	for case in instructions[1]:
		_on_add_case_pressed()
		var case_node = get_node("MatchNodeCase_"+str(match_node_count))
		case_node.set_value(case)
		pass

func remove_case(case:HBoxContainer):
	set_slot_enabled_right(case._case_id+1, false)
	case.queue_free()
	match_node_count -= 1

func _on_add_case_pressed():
	if $Variable.text == "Variable": 
		printerr("%s _on_minus_case_pressed() Please select variable."%[_print])
		return
	var case = load("res://addons/DialogGraph/Scenes/Nodes/MatchNodeCase.tscn").instance()
	match_node_count += 1
	case._case_id = match_node_count
	add_child(case)
	case.name = "MatchNodeCase_"+str(match_node_count)
	set_slot_enabled_right(case._case_id+1, true)


func _on_minus_case_pressed():
	if $Variable.text == "Variable": 
		printerr("%s _on_minus_case_pressed() Please select variable."%[_print])
		return
	if match_node_count > 1:
		var case_node = get_node("MatchNodeCase_"+str(match_node_count))
		remove_case(case_node)


func _on_MatchNode_resize_request(new_minsize):
	rect_size = new_minsize

func _on_Variable_button_down():
#	print("%s _on_Variable_button_down() DialogueManager.tree_varibales_without_signals.size(): %s, DialogueManager.tree_varibales_without_signals:%s"%[_print, DialogueManager.tree_varibales_without_signals.size(), DialogueManager.tree_varibales_without_signals])
	$Variable.clear()
	if DialogueManager.tree_varibales_without_signals.size() == 0: 
		$Variable.text = "Variable"
		return
	for variable in DialogueManager.tree_varibales_without_signals:
		if DialogueManager.tree["Variables"][variable][1] != "bool":
			$Variable.add_item(variable)
	$Variable.select(-1)

func _on_Variable_focus_exited():
	if $Variable.text == "":
		$Variable.text = "Variable"
