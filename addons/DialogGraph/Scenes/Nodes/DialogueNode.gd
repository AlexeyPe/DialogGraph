tool
extends GraphNodeDialogueBase

var option_count = 0

const _print = "Addon:DialogueGraph, DialogueNode.gd"

func get_instructions() -> Array:
	var result = []
#	[speaker:String, text:String, option1:String, option2:String, option3:String, option4:String]
#	speaker
	result.append($Speaker.text)
#	if $Speaker.text == "": result.append(null)
#	else: result.append($Speaker.text)
#	description
	result.append($TextEdit.text)
#	if $TextEdit.text == "": result.append(null)
#	else: result.append($TextEdit.text)
#	option 1
	if $Option1.text == "": 
		if option_count >= 1: result.append("")
		else: result.append(null)
	else: result.append($Option1.text)
#	option 2
	if $Option2.text == "": 
		if option_count >= 2: result.append("")
		else: result.append(null)
	else: result.append($Option2.text)
#	option 3
	if $Option3.text == "": 
		if option_count >= 3: result.append("")
		else: result.append(null)
	else: result.append($Option3.text)
#	option 4
	if $Option4.text == "": 
		if option_count >= 4: result.append("")
		else: result.append(null)
	else: result.append($Option4.text)
	return result

func _ready():
	update_slots()

func update_slots():
	for i in 4:
		get_node("Option%s"%[i+1]).visible = false
		set_slot_enabled_right(i+1, false)
	for i in option_count:
		get_node("Option%s"%[i+1]).visible = true
		set_slot_enabled_right(i+1, true)
	
	var graph_editor:GraphEdit
	var connections = []
	if get_parent() is GraphEdit:
		graph_editor = get_parent()
		for connection in graph_editor.get_connection_list():
			if connection["from"] == name:
				connections.append( )
	
	if option_count == 0:
		set_slot_enabled_right(0, true)
	else:
		set_slot_enabled_right(0, false)
		for i in 4:
			var slot_index = 4-i+option_count-1
#			print("slot_index ", slot_index)
			for connection in connections:
				if connection["from_port"] == slot_index:
#					print("connection['from_port'] == slot_index")
					graph_editor.disconnect_node(connection["from"], connection["from_port"], connection["to"], connection["to_port"])

func get_type() -> String:
	return "DialogueNode"

func set_instructions(instructions:Array):
	if instructions[0] == null:
		$Speaker.text = ""
	else:
		$Speaker.text = instructions[0]
	if instructions[1] == null:
		$TextEdit.text = ""
	else:
		$TextEdit.text = instructions[1]
	
	option_count = 0
	if instructions[2] != null: 
		option_count += 1
		$Option1.text = instructions[2]
	if instructions[3] != null: 
		option_count += 1
		$Option2.text = instructions[3]
	if instructions[4] != null: 
		option_count += 1
		$Option3.text = instructions[4]
	if instructions[5] != null: 
		option_count += 1
		$Option4.text = instructions[5]
	update_slots()

func _on_DialogueNode_resize_request(new_minsize):
	rect_size = new_minsize

func _on_add_option_pressed():
	if option_count == 4: return
	option_count += 1
	update_slots()

func _on_minus_option_pressed():
	if option_count == 0: return
	option_count -= 1 
	update_slots()


func _on_TextEdit_mouse_entered():
	get_parent().owner.zoom_lock(true)

func _on_TextEdit_mouse_exited():
	get_parent().owner.zoom_lock(false)


func _on_focus_exited():
	get_parent().owner.save_tree()


func _on_run_pressed():
	if DialogueManager._debug_print:
		print("%s _on_run_pressed() DialogueManager.run_from_row(row:%s)"%[_print, row])
	DialogueManager.run_from_row(row)
	pass # Replace with function body.
