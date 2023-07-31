tool
extends GraphNodeDialogueBase

var timeline_head_name:String

const _print = "Addon:DialogueGraph, TimelineHeadNode.gd"

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
	if DialogueManager._debug_print:
		print("%s _on_run_pressed() DialogueManager.run_from_row(row:%s)"%[_print, row])
	DialogueManager.run_from_row(row)

func _on_timeline_head_name_focus_exited():
#	print("TimelineHeadNode _on_timeline_head_name_focus_exited()")
	get_parent().owner.save_tree()
