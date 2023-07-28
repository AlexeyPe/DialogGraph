tool
extends GraphNodeDialogueBase

var timeline_head_name:String

func get_type() -> String:
	return "TimelineHeadNode"

func get_instructions() -> Array:
	return [timeline_head_name]

func set_instructions(instructions:Array):
	timeline_head_name = instructions[0]
	$MarginContainer/HBoxContainer2/timeline_head_name.text = instructions[0]

func _on_timeline_head_name_text_changed(new_text):
	timeline_head_name = new_text


func _on_TimelineHeadNode_resize_request(new_minsize):
	rect_min_size = new_minsize


func _on_run_pressed():
	print("TimelineHeadNode _on_run_pressed()")
	get_parent().owner.run_from_node(name)


func _on_timeline_head_name_focus_exited():
#	print("TimelineHeadNode _on_timeline_head_name_focus_exited()")
	get_parent().owner.save_tree()
