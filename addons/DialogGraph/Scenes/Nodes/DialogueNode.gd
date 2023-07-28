tool
extends GraphNodeDialogueBase

var option_count = 0

func get_instructions() -> Array:
	var result = []
#	[speaker:String, text:String, option1:String, option2:String, option3:String, option4:String]
	result.append($Speaker.text)
	result.append($TextEdit.text)
	result.append($Option1.text)
	result.append($Option2.text)
	result.append($Option3.text)
	result.append($Option4.text)
	return result

func _ready():
	update_slots()

func update_slots():
	if option_count == 0:
		set_slot_enabled_right(0, true)
	else:
		set_slot_enabled_right(0, false)
	for i in 4:
		get_node("Option%s"%[i+1]).visible = false
		set_slot_enabled_right(i+1, false)
	for i in option_count:
		get_node("Option%s"%[i+1]).visible = true
		set_slot_enabled_right(i+1, true)

func get_type() -> String:
	return "DialogueNode"

func set_instructions(instructions:Array):
	$Speaker.text = instructions[0]
	$TextEdit.text = instructions[1]
	option_count = 0
	if instructions[2] != "": 
		option_count += 1
		$Option1.text = instructions[2]
	if instructions[3] != "": 
		option_count += 1
		$Option2.text = instructions[3]
	if instructions[4] != "": 
		option_count += 1
		$Option4.text = instructions[4]
	if instructions[5] != "": 
		option_count += 1
		$Option3.text = instructions[5]
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
