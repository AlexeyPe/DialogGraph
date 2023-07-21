tool
extends GraphNode

var option_count = 0

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
		

func _on_DialogueNode_resize_request(new_minsize):
	rect_size = new_minsize

func _on_DialogueNode_close_request():
	print("DialogueNode _on_DialogueNode_close_request")
	get_parent().owner.delete_node()

func _on_add_option_pressed():
	if option_count == 4: return
	option_count += 1
	update_slots()

func _on_minus_option_pressed():
	if option_count == 0: return
	option_count -= 1 
	update_slots()
