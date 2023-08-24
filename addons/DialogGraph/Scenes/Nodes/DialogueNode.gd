tool
extends GraphNodeDialogueBase

var option_node_count = 0

const _print = "Addon:DialogueGraph, DialogueNode.gd"

func get_type() -> String:
	return "DialogueNode"

func get_instructions() -> Array:
	var result = []
#	[speaker:String, text:String, options:[option_text:String] ]
	result.append($Speaker.text) # speaker
	result.append($TextEdit.text) # description
	result.append([]) # options array
	for option_id in option_node_count:
		var option = get_node("DialogueNodeOption_"+str(option_id))
		result[2].append(option.get_value()) # options array append option value
	return result

func set_instructions(instructions:Array):
#	[speaker:String, text:String, options:[option_text:String] ]
#	Speaker
	if instructions[0] == null: $Speaker.text = ""
	else: $Speaker.text = instructions[0]
#	Description
	if instructions[1] == null: $TextEdit.text = ""
	else: $TextEdit.text = instructions[1]
#	Options
	for option_value in instructions[2]:
		add_option()
		get_node("DialogueNodeOption_"+str(option_node_count-1)).set_value(option_value)

func remove_option(option:HBoxContainer):
	if option_node_count-1 == 0:
		set_slot_enabled_right(option_node_count+2, false)
		remove_child(option)
		option.queue_free()
		set_slot_enabled_right(0, true)
		option_node_count -= 1
	else:
		get_parent().owner.delete_port(self, option.slot_id_enable)
		set_slot_enabled_right(option_node_count+2, false)
		remove_child(option)
		option.queue_free()
		option_node_count -= 1
		
#		update slot_id for options
		var options = []
		for child in get_children():
			if "DialogueNodeOption" in child.name:
				options.append(child)
		var old_options = {}
		for option_id in options.size():
			options[option_id].slot_id = option_id+3
			old_options[options[option_id].slot_id_enable] = option_id
			options[option_id].slot_id_enable = option_id
			options[option_id].name = "DialogueNodeOption_"+str(option_id)
		
		var new_connections = []
		for connection in get_parent().owner.get_connections():
			if connection["from"] != name: continue
			for option_id in old_options.keys().size():
				var old_option_id_enable = old_options.keys()[option_id]
				if connection["from_port"] == old_option_id_enable:
					var new_connection = connection
					new_connection["from_port"] = old_options[old_option_id_enable]
					new_connections.append(new_connection)

		get_parent().owner.delete_all_ports(self)
		get_parent().owner.set_connections(new_connections)

func add_option():
	var spacer_delete = get_node("spacer")
	remove_child(spacer_delete)
	spacer_delete.queue_free()
	
	var option = load("res://addons/DialogGraph/Scenes/Nodes/DialogueNodeOption.tscn").instance()
	option.name = "DialogueNodeOption_"+str(option_node_count)
	option.slot_id = option_node_count+3
	option.slot_id_enable = option_node_count
	option_node_count += 1
	add_child(option)
	
	if option_node_count == 1:
		set_slot_enabled_right(option_node_count+2, true)
		set_slot_enabled_right(0, false)
	else:
		set_slot_enabled_right(option_node_count+2, true)
	
	var spacer = Control.new()
	spacer.rect_min_size.y = 10
	spacer.rect_size.y = 10
	spacer.name = "spacer"
	add_child(spacer)

func _on_DialogueNode_resize_request(new_minsize):
	rect_size = new_minsize

func _on_TextEdit_mouse_entered():
	get_parent().owner.zoom_lock(true)

func _on_TextEdit_mouse_exited():
	get_parent().owner.zoom_lock(false)


func _on_focus_exited():
	get_parent().owner.save_tree()


func _on_run_pressed():
	if DialogueManager._debug_print:
		print("%s _on_run_pressed() DialogueManager.run_from_row(row:%s)"%[_print, row])
	DialogueManager.current_timeline = "_editor_test"
	DialogueManager.run_from_row(row)


