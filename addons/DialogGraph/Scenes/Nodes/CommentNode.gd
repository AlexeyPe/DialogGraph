tool
extends GraphNodeDialogueBase

const _print = "Addon:DialogueGraph, CommentNode.gd"

func get_instructions() -> Array:
	var result = []
	result.append($TextEdit.text)
	return result

func set_instructions(instructions:Array):
	$TextEdit.text = instructions[0]

func get_type() -> String:
	return "CommentNode"


func _on_CommentNode_resize_request(new_minsize):
	rect_size = new_minsize


func _on_TextEdit_focus_exited():
	get_parent().owner.save_tree()


func _on_TextEdit_mouse_entered():
	get_parent().owner.zoom_lock(true)


func _on_TextEdit_mouse_exited():
	get_parent().owner.zoom_lock(false)
	pass # Replace with function body.
