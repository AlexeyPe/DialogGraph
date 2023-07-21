tool
extends GraphNode

var timeline_head_name:String

func _on_timeline_head_name_text_changed(new_text):
	timeline_head_name = new_text

func _on_timeline_head_name_text_entered(new_text):
	print("TimelineHeadNode, _on_timeline_head_name_text_entered(new_text:%s)"%[new_text])
	timeline_head_name = new_text
	get_parent().owner.save_tree()


func _on_DialogueNode_resize_request(new_minsize):
	rect_min_size = new_minsize


func _on_DialogueNode_close_request():
	print("TimelineHeadNode _on_DialogueNode_close_request")
	get_parent().owner.delete_node(name)
