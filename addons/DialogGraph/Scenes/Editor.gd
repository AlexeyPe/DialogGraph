tool
extends Control

#	Save format
#
#	YourSaveName.json:
#	{
#		"SaveVersion": int,
#		"SupportOldVersions": [int],
#		"TimelineHeads":{
#			"string(TimelineHeadNode.name)": index_start:int
#		},
#		"HeadNodes": [
#			# I could save this as a Dictionary for file readability
#			# But why read this file? Let it contain less information so that the file weighs less
#			# instructions - contains different information, depends on which node is saved (check .gd in Nodes folder)
#			[index:int, links:[index:int], node.rect_min_size:Vector2, node.offset:Vector2, instructions:[?] ]
#			[int, [int], Vector2, Vector2, [?] ] *abbreviated
#		],
#		"HeadlessNodes": [
#			# The same as HeadNodes, but without the start node, for example the comment node
#		]
#	}

const _print = "Addon:DialogueGraph, Editor.gd"

export (Array, String, FILE, "*.tscn, *.scn") var GraphNodesScenes
export var popup_menu_nodes:NodePath
export var graph_editor:NodePath
export var label_current_tree:NodePath

var debug_print:bool = true

var GrapNodeName2GraphNodeScene = {}
var GraphNodeScene2GrapNodeName = {}

var current_tree = "test"
var tree:Dictionary

var timeline_head_nodes = []
var headless_nodes = []
var cursor_pos:Vector2 


func show_popup(pos:Vector2):
	if debug_print: print("%s show_popup(pos:%s)"%[_print, pos])
	var graph = get_node(graph_editor)
	var popup_menu_nodes_node:PopupMenu = get_node(popup_menu_nodes)
	popup_menu_nodes_node.popup(Rect2(pos.x, pos.y, popup_menu_nodes_node.rect_size.x, popup_menu_nodes_node.rect_size.y))
	
	cursor_pos = pos


func update_ui():
	if debug_print: print("%s update_ui()"%[_print])
	get_node(label_current_tree).text = "current tree: %s"%[current_tree]
	if current_tree == null:
		get_node(graph_editor).visible = false
		pass
	else:
		get_node(graph_editor).visible = true

func save_tree():
	if debug_print: print("%s save_tree()"%[_print])
	make_tree()


func make_tree():
	if debug_print: print("%s make_tree()"%[_print])


func delete_node(graph_node):
	var graph_editor_node = get_node(graph_editor)
	
	for connection in graph_editor_node.get_connection_list():
		if connection['from'] == graph_node or connection['to'] == graph_node:
			graph_editor_node.disconnect_node(connection['from'], connection['from_port'], connection['to'], connection['to_port'])
	
	graph_editor_node.get_node(graph_node).queue_free()


func _ready():
	print("%s _ready()"%[_print])
	var popup_menu_nodes_node:PopupMenu = get_node(popup_menu_nodes)
	popup_menu_nodes_node.clear()
#	Names in the popup window are set here, this is the name of the graph nodes
	for graph_node in GraphNodesScenes:
		var graph_node_name = load(graph_node).instance().name
		print("%s _ready() add graph_node %s"%[_print, graph_node_name])
		GrapNodeName2GraphNodeScene[graph_node_name] = graph_node
		GraphNodeScene2GrapNodeName[graph_node] = graph_node_name
		popup_menu_nodes_node.add_item(graph_node_name)
	
	update_ui()
	
	print("%s _ready() success"%[_print])


func _on_btn_new_tree_pressed():
	if debug_print: print("%s _on_btn_new_tree_pressed()"%[_print])


func _on_btn_open_tree_pressed():
	if debug_print: print("%s _on_btn_open_tree_pressed()"%[_print])


func _on_btn_save_as_tree_pressed():
	if debug_print: print("%s _on_btn_save_as_tree_pressed()"%[_print])


func _on_btn_save_tree_pressed():
	if debug_print: print("%s _on_btn_save_tree_pressed()"%[_print])


func _on_CheckBoxdebug_print_toggled(button_pressed):
	print("%s _on_CheckBoxdebug_print_toggled(button_pressed:%s)"%[_print, button_pressed])
	debug_print = button_pressed
	var graph:GraphEdit = get_node(graph_editor)
	print(graph.get_connection_list())


func _on_GraphEdit_popup_request(position):
	if debug_print: print("%s _on_GraphEdit_popup_request(position:%s)"%[_print, position])
	show_popup(position)


func _on_popup_menu_nodes_id_pressed(id):
	if debug_print: print("%s _on_popup_menu_nodes_id_pressed(id:%s(%s))"%[_print, id, GraphNodeScene2GrapNodeName[GraphNodesScenes[id]]])
	var graph_node:GraphNode = load(GraphNodesScenes[id]).instance()
	var graph = get_node(graph_editor)
	graph.add_child(graph_node)
	
	graph_node.offset = (cursor_pos - graph.rect_global_position + graph.scroll_offset) / graph.zoom


func _on_GraphEdit_connection_to_empty(from, from_slot, release_position):
	if debug_print: print("%s _on_GraphEdit_connection_to_empty(from:%s, from_slot:%s, release_position:%s)"%[_print, from, from_slot, release_position])
	show_popup(release_position + get_node(graph_editor).rect_global_position)


func _on_GraphEdit_delete_nodes_request(nodes):
	if debug_print: print("%s _on_GraphEdit_delete_nodes_request(nodes:%s)"%[_print, nodes])
	var graph_editor_node:GraphEdit = get_node(graph_editor)
	for graph_node in nodes:
		delete_node(graph_node)


func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	if debug_print: print("%s _on_GraphEdit_connection_request(from:%s, from_slot:%s, to:%s, to_slot:%s)"%[_print, from, from_slot, to, to_slot])
	var graph_editor_node:GraphEdit = get_node(graph_editor)
	graph_editor_node.connect_node(from, from_slot, to, to_slot)


func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	if debug_print: print("%s _on_GraphEdit_connection_request(from:%s, from_slot:%s, to:%s, to_slot:%s)"%[_print, from, from_slot, to, to_slot])
	var graph_editor_node:GraphEdit = get_node(graph_editor)
	graph_editor_node.disconnect_node(from, from_slot, to, to_slot)
