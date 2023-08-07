tool
extends GraphNode
class_name GraphNodeDialogueBase

export var is_timeline_head:bool = false

# Set in Editor.gd build_tree_build_node()
var row:int
var row_links = []
# Set in build_tree()
var row_parent:int

func get_type() -> String:
	return "override get_type() function"

func _on_close_request():
	print("%s _on_close_request"%[get_class()])
	get_parent().owner.delete_node(name)
	get_parent().owner.save_tree()

func set_instructions(instructions:Array):
	pass

func get_instructions() -> Array:
	var result = []
	return result

func _ready():
	connect("close_request", self, "_on_close_request")
	if get_parent() is GraphEdit:
		get_parent().owner.save_tree()

func get_class(): return "GraphNodeDialogueBase"
