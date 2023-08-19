tool
extends Control

#	Save format
#
#	YourSaveName.json:
#	{
#		"SaveVersion": int,
#		"SupportOldVersions": [int],
#		"Variables": { "var_name:String": value:int/float/string/bool },
#		"NodeTypes": [String],
#		"TimelineHeads":{
#			"string(TimelineHeadNode.name)": index_start:int
#		},
#		"Nodes": [
#			# I could save this as a Dictionary for file readability
#			# But why read this file?..) Let it contain less information so that the file weighs less
#			# instructions - contains different information, depends on which node is saved (check .gd in Nodes folder)
#			[links:[ [index, from_port, to_port] ], node.rect_min_size:Vector2, node.offset:Vector2, node_type_index:int, instructions:[?] ]
#			[ [[int, int, int]], Vector2, Vector2, int, [?] ]
#		]
#	}

const SaveVersion = 1
const SuportOldVersions = [1]
const _print = "Addon:DialogueGraph, Editor.gd"

export (Array, String, FILE, "*.tscn, *.scn") var GraphNodesScenes

export (String, FILE, "*.tscn, *.scn") var scene_variable_slot
export var variable_slot_parent:NodePath

export var popup_menu_nodes:NodePath
export var graph_editor:NodePath
export var label_current_tree:NodePath
export var FileDialogOpen:NodePath
export var FileDialogNew:NodePath
export var FileDialogSaveAs:NodePath
export var workspace_node:NodePath
export var dialogue_box_test:NodePath

export var default_signals:Array = ["on_texture_update"]

var GraphNodeName2GraphNodeScene = {}
var GraphNodeScene2GraphNodeName = {} # Scene is path
var GraphNodeName2TreeRow = {}
var TreeRow2GraphNode = {}


var current_tree_name = null
var current_tree_path = null
var tree:Dictionary

var cursor_pos:Vector2
# for _on_GraphEdit_connection_to_empty
var request_node 
var request_node_slot

var mode_load_tree:bool = false

func show_popup(pos:Vector2):
	if DialogueManager._debug_print: print("%s show_popup(pos:%s)"%[_print, pos])
	var graph = get_node(graph_editor)
	var popup_menu_nodes_node:PopupMenu = get_node(popup_menu_nodes)
	popup_menu_nodes_node.popup(Rect2(pos.x, pos.y, popup_menu_nodes_node.rect_size.x, popup_menu_nodes_node.rect_size.y))
	
	cursor_pos = pos

func set_mode_load_tree(new):
	if DialogueManager._debug_print: print("%s set_mode_load_tree(new:%s)"%[_print, new])
	mode_load_tree = new

func update_ui():
	if DialogueManager._debug_print:
		print("%s update_ui()"%[_print])
		$"MarginContainer/VBoxContainer/HBoxContainer/CheckBox-debug_print".pressed = true
	else:
		$"MarginContainer/VBoxContainer/HBoxContainer/CheckBox-debug_print".pressed = false
	get_node(label_current_tree).text = "current tree: %s"%[current_tree_name]
	if current_tree_name == null:
		get_node(graph_editor).visible = false
		get_node(workspace_node).visible = false
		pass
	else:
		get_node(workspace_node).visible = true
		get_node(graph_editor).visible = true

func save_tree():
	if mode_load_tree: 
		if DialogueManager._debug_print: print("%s  save_tree() mode_load_tree - return"%[_print])
		return
	if DialogueManager._debug_print: print("%s save_tree()"%[_print])
	var copy_tree_variables = {}
	if tree.has("Variables"):
		copy_tree_variables = tree["Variables"]
	make_tree()
	tree["Variables"] = copy_tree_variables
	save_tree_to_json()
	DialogueManager.set_tree(tree)
	if DialogueManager._debug_print: print("%s save_tree() success"%[_print])

func make_tree():
	if DialogueManager._debug_print: print("%s make_tree()"%[_print])
	GraphNodeName2TreeRow.clear()
	var graph_editor_node = get_node(graph_editor)
	tree = {
		"SaveVersion": SaveVersion,
		"SupportOldVersions": SuportOldVersions,
		"Variables": {
#			"var_name:String": value:int/float/string/bool 
		},
		"NodeTypes": [],
		"TimelineHeads":{
#			"string(TimelineHeadNode.name)": index_start:int
		},
		"Nodes": [
			# I could save this as a Dictionary for file readability
			# But why read this file? Let it contain less information so that the file weighs less
			# instructions - contains different information, depends on which node is saved (check .gd in Nodes folder)
#			[links:[ [index, from_port, to_port] ], node.rect_min_size:Vector2, node.offset:Vector2, node_type_index:int, instructions:[?] ]
#			[ [[int, int, int]], Vector2, Vector2, int, [?] ]
		]
	}
	for graph_node_name in GraphNodeName2GraphNodeScene.keys():
		tree["NodeTypes"].append(graph_node_name)
	
#	for node in graph_editor_node.get_children():
#		if node is GraphNodeDialogueBase:
#			print(node.name)
	
	for connection in graph_editor_node.get_connection_list():
#		connection {from:TimelineHeadNode, from_port:0, to:DialogueNode, to_port:0}
		print("connection ", connection)

#		Add to node and get index
		var to_index = add_node_to_tree(graph_editor_node.get_node(connection["to"]), connection["to"])
#		Add from node and get index
		var from_index = add_node_to_tree(graph_editor_node.get_node(connection["from"]), connection["from"])

		if !GraphNodeName2TreeRow.has(connection["from"]):
			GraphNodeName2TreeRow[connection["from"]] = from_index
		
		if !GraphNodeName2TreeRow.has(connection["to"]):
			GraphNodeName2TreeRow[connection["to"]] = to_index

		var has_elem:bool = false
		for elem in tree["Nodes"][from_index][0]:
#			tree["Nodes"][from_index][0] is [ [index:int, from_port:int, to_port:int], .. ]
#			elem is [index:int, from_port:int, to_port:int]
			if elem[0] == to_index and elem[1] == connection['from_port'] and elem[2] == connection['to_port']: 
				has_elem = true
		if has_elem == false:
			tree["Nodes"][from_index][0].append([to_index, connection['from_port'], connection['to_port'] ])

		var node = graph_editor_node.get_node(connection["from"])
		if node is GraphNodeDialogueBase:
			if node.is_timeline_head:
				tree["TimelineHeads"][node.timeline_head_name] = from_index
	
	for child in graph_editor_node.get_children():
		if child is GraphNodeDialogueBase:
			if !GraphNodeName2TreeRow.has(child.name):
				add_node_to_tree(child, child.name)
	
	if DialogueManager._debug_print: print("%s make_tree() success"%[_print])

# return - index in tree["Nodes"]
func add_node_to_tree(node, node_name) -> int:
	if DialogueManager._debug_print: print("%s add_node_to_tree(node:%s, node_name:%s)"%[_print, node, node_name])
	var node_index:int
	if node is GraphNodeDialogueBase:
		if GraphNodeName2TreeRow.has(node_name):
			node_index = GraphNodeName2TreeRow[node_name]
			node.row = node_index
		else:
			node_index = tree["Nodes"].size()
			node.row = node_index
			print("\t\t\tadd_node_to_tree(node:%s, node_name:%s)"%[node, node_name])
			tree["Nodes"].append([ [], node.rect_size, node.offset, tree["NodeTypes"].find(node.get_type()), node.get_instructions()])
	if DialogueManager._debug_print: print("%s add_node_to_tree(node:%s, node_name:%s) success"%[_print, node, node_name])
	return node_index


func build_tree():
	if DialogueManager._debug_print: print("%s build_tree()"%[_print])
	TreeRow2GraphNode.clear()
	set_mode_load_tree(true)
	tree = load_tree_from_json()
	DialogueManager.set_tree(tree)
#	rows_added is {row_index(int): node}
	var graph_editor_node:GraphEdit = get_node(graph_editor)

#	Variables
	for var_slot_name in tree["Variables"]:
		if var_slot_name == "": continue
#		print("\t\tvar_slot_name:%s var_slot.value:%s var_slot.value type:%s"%[var_slot_name, tree["Variables"][var_slot_name], typeof(tree["Variables"][var_slot_name])])
		var var_slot = load(scene_variable_slot).instance()
		var elem = tree["Variables"][var_slot_name]
		get_node(variable_slot_parent).add_child(var_slot)
		var_slot.type = elem[1]
		var_slot.set_value(elem[0])
		var_slot.set_name(str(var_slot_name))

#	Add to graph editor
	for i in tree["Nodes"].size():
		var node = build_tree_build_node(i)
		TreeRow2GraphNode[i] = node

	print("TreeRow2GraphNode %s"%[TreeRow2GraphNode])

#	Add connections for graph node in graph editor
	for i in tree["Nodes"].size():
#		[links:[ [index, from_port, to_port] ], node.rect_min_size:Vector2, node.offset:Vector2, node_type_index:int, instructions:[?] ]
#		[ [[int, int, int]], Vector2, Vector2, int, [?] ]
		for link in tree["Nodes"][i][0]:
			graph_editor_node.connect_node(TreeRow2GraphNode[i].name, link[1], TreeRow2GraphNode[int(link[0])].name, link[2])
			TreeRow2GraphNode[int(link[0])].row_parent = i
	
	set_mode_load_tree(false)
	if DialogueManager._debug_print: print("%s build_tree() success"%[_print])

func build_tree_build_node(i):
	if DialogueManager._debug_print: print("%s build_tree_build_node(i:%s)"%[_print, i])
	var node_row = tree["Nodes"][i]
#	[links:[ [index, from_port, to_port] ], node.rect_min_size:Vector2, node.offset:Vector2, node_type_index:int, instructions:[?] ]
#	[ [[int, int, int]], Vector2, Vector2, int, [?] ]
	var node:GraphNodeDialogueBase = load( GraphNodeName2GraphNodeScene[ tree["NodeTypes"][node_row[3]] ]).instance()
	get_node(graph_editor).add_child(node)
	var new_size:Vector2 = str2var("Vector2" + node_row[1])
#	print("\t\t\tnew_size ",new_size)
	node.rect_size = new_size
	node.offset = str2var("Vector2" + node_row[2])
	node.row = i
	node.row_links = []
	for link in node_row[0]:
		node.row_links.append(link[0])
	node.set_instructions(node_row[4])
#	print(node)
	return node

func save_tree_to_json():
	var file = File.new()
	
	file.open(current_tree_path, File.WRITE)
	file.store_string(JSON.print(tree))
	file.close()

func load_tree_from_json() -> Dictionary:
	var file = File.new()
	var result:Dictionary
	if file.open(current_tree_path, File.READ) == OK:
		result = JSON.parse(file.get_as_text()).result
	file.close()
	return result

func on_delete_node_request(graph_node_name:String):
	delete_node(graph_node_name)
	save_tree()

func delete_node(graph_node_name:String):
	if DialogueManager._debug_print: print("%s delete_node(graph_node_name:%s)"%[_print, graph_node_name])
	var graph_editor_node = get_node(graph_editor)
	var graph_node = graph_editor_node.get_node(graph_node_name)
	
	for connection in graph_editor_node.get_connection_list():
		if connection['from'] == graph_node_name or connection['to'] == graph_node_name:
			graph_editor_node.disconnect_node(connection['from'], connection['from_port'], connection['to'], connection['to_port'])
	
	graph_node.get_parent().remove_child(graph_node)
	graph_node.queue_free()

func zoom_lock(new:bool):
	if new == true:
		get_node(graph_editor).zoom_step = 1
	else:
		get_node(graph_editor).zoom_step = 1.1
	
func on_toggle_debug_print(new:bool, old:bool):
	update_ui()


func _ready():
	print("%s _ready()"%[_print])
	DialogueManager.connect("on_toggle_debug_print", self, "on_toggle_debug_print")
	get_node(dialogue_box_test).visible = false
	var popup_menu_nodes_node:PopupMenu = get_node(popup_menu_nodes)
	popup_menu_nodes_node.clear()
#	Names in the popup window are set here, this is the name of the graph nodes
	var graph_node_types = []
	for graph_node in GraphNodesScenes:
		var graph_node_name = load(graph_node).instance().get_type()
		GraphNodeName2GraphNodeScene[graph_node_name] = graph_node
		GraphNodeScene2GraphNodeName[graph_node] = graph_node_name
		popup_menu_nodes_node.add_item(graph_node_name)
		graph_node_types.append(graph_node_name)
	if DialogueManager._debug_print: print("%s _ready() add graph_node types %s"%[_print, graph_node_types])
	update_ui()
	
	print("%s _ready() success"%[_print])

func _input(event):
	if current_tree_path == null: return
	if Input.is_key_pressed(KEY_CONTROL) and Input.is_key_pressed(KEY_S):
		if $"MarginContainer/VBoxContainer/HBoxContainer/CheckBox-debug_print2".pressed:
			save_tree()

func _on_btn_new_tree_pressed():
	if DialogueManager._debug_print: print("%s _on_btn_new_tree_pressed()"%[_print])
	var file_dialog:FileDialog = get_node(FileDialogNew)
	file_dialog.popup_centered()

func _on_btn_open_tree_pressed():
	if DialogueManager._debug_print: print("%s _on_btn_open_tree_pressed()"%[_print])
	var file_dialog_open:FileDialog = get_node(FileDialogOpen)
	file_dialog_open.popup_centered()

func _on_btn_save_as_tree_pressed():
	if DialogueManager._debug_print: print("%s _on_btn_save_as_tree_pressed()"%[_print])


func _on_btn_save_tree_pressed():
	if DialogueManager._debug_print: print("%s _on_btn_save_tree_pressed()"%[_print])
	save_tree()

func _on_CheckBoxdebug_print_toggled(button_pressed):
	print("%s _on_CheckBoxdebug_print_toggled(button_pressed:%s)"%[_print, button_pressed])
	DialogueManager.set_debug_print(button_pressed)
	var graph:GraphEdit = get_node(graph_editor)
	print(tree)


func _on_GraphEdit_popup_request(position):
	if DialogueManager._debug_print: print("%s _on_GraphEdit_popup_request(position:%s)"%[_print, position])
	show_popup(position)


func _on_popup_menu_nodes_id_pressed(id):
	if DialogueManager._debug_print: print("%s _on_popup_menu_nodes_id_pressed(id:%s(%s))"%[_print, id, GraphNodeScene2GraphNodeName[GraphNodesScenes[id]]])
	var graph_node:GraphNode = load(GraphNodesScenes[id]).instance()
	var graph = get_node(graph_editor)
	graph.add_child(graph_node)
	
	# connect to previous node if created from _on_GraphEdit_connection_to_empty
	if request_node:
		if graph_node.is_slot_enabled_left(0):
			# remove any connection from this slot to previous node
			remove_connection(request_node, request_node_slot, graph_node.name)
			# make new connection
			graph.connect_node(request_node, request_node_slot, graph_node.name, 0)
	
	request_node = null
	request_node_slot = null
	
	graph_node.offset = (cursor_pos - graph.rect_global_position + graph.scroll_offset) / graph.zoom
	save_tree()

func _on_GraphEdit_connection_to_empty(from, from_slot, release_position):
	if DialogueManager._debug_print: print("%s _on_GraphEdit_connection_to_empty(from:%s, from_slot:%s, release_position:%s)"%[_print, from, from_slot, release_position])
	request_node = from
	request_node_slot = from_slot
	show_popup(release_position + get_node(graph_editor).rect_global_position)


func _on_GraphEdit_delete_nodes_request(nodes):
	if DialogueManager._debug_print: print("%s _on_GraphEdit_delete_nodes_request(nodes:%s)"%[_print, nodes])
	var graph_editor_node:GraphEdit = get_node(graph_editor)
	for graph_node in nodes:
		delete_node(graph_node)
	
	save_tree()

func remove_connection(from, from_slot, to):
	var graph_editor_node:GraphEdit = get_node(graph_editor)
	for connection in graph_editor_node.get_connection_list():
		if connection['from'] == from:
			if connection['to'] != to and connection['from_port'] == from_slot:
				graph_editor_node.disconnect_node(
					connection['from'], connection['from_port'], connection['to'], connection['to_port']
				)

func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	if DialogueManager._debug_print: print("%s _on_GraphEdit_connection_request(from:%s, from_slot:%s, to:%s, to_slot:%s)"%[_print, from, from_slot, to, to_slot])
	if from == to: return
	var graph_editor_node:GraphEdit = get_node(graph_editor)
	
	# remove any connection from this slot to previous node
	remove_connection(from, from_slot, to)
	
	# create new connction
	graph_editor_node.connect_node(from, from_slot, to, to_slot)
	
	save_tree()

func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	if DialogueManager._debug_print: print("%s _on_GraphEdit_connection_request(from:%s, from_slot:%s, to:%s, to_slot:%s)"%[_print, from, from_slot, to, to_slot])
	var graph_editor_node:GraphEdit = get_node(graph_editor)
	graph_editor_node.disconnect_node(from, from_slot, to, to_slot)
	
	save_tree()

func _on_FileDialogNew_file_selected(path):
	if current_tree_path != null:
		save_tree()
		tree = {}
	var graph:GraphEdit = get_node(graph_editor)
	graph.clear_connections()
	
	for child in get_node(graph_editor).get_children():
		if child is GraphNodeDialogueBase:
			child.queue_free()
	
	for child in get_node(variable_slot_parent).get_children():
		child.queue_free()
	
	current_tree_path = path
	current_tree_name = current_tree_path.get_file()
	update_ui() 
#	create tree and save
	save_tree()
#	add variables to tree
	for _signal in default_signals:
		tree["Variables"][_signal] = ["","signal"]
#	save new tree
	save_tree()
#	build new tree
	build_tree()

func _on_FileDialogOpen_file_selected(path):
	if current_tree_path != null:
		 save_tree()
	var graph:GraphEdit = get_node(graph_editor)
	
#	Clear all connections
	graph.clear_connections()

#	Delete all Graph Nodes
	for child in get_node(graph_editor).get_children():
		if child is GraphNodeDialogueBase:
			child.queue_free()

#	Delete all variable nodes
	for child in get_node(variable_slot_parent).get_children():
		child.queue_free()

#	Update path
	current_tree_path = path
	current_tree_name = current_tree_path.get_file()
	
#	Change visiblity
	update_ui()
	
#	Build all Graph Nodes and variable slots
	build_tree()


func _on_Button_add_var_pressed():
	var var_slot = load(scene_variable_slot).instance()
	get_node(variable_slot_parent).add_child(var_slot)
	if DialogueManager._debug_print:
		print("%s _on_Button_add_var_pressed() tree['Variables']:%s"%[_print, tree['Variables']])


func _on_GraphEdit_duplicate_nodes_request():
	print("%s _on_GraphEdit_duplicate_nodes_request()"%[_print])
	
	var editor:GraphEdit = get_node(graph_editor)
	var selected_nodes:Array
	var add_offset:Vector2 = Vector2(0, 0)
	for graph_node in editor.get_children():
		if graph_node is GraphNodeDialogueBase and graph_node.selected:
			selected_nodes.append(graph_node)
			var instructions = graph_node.get_instructions()
			
			var duplicate_graph_node:GraphNode = load(GraphNodeName2GraphNodeScene[graph_node.get_type()]).instance()
			editor.add_child(duplicate_graph_node)
			cursor_pos = editor.get_global_mouse_position()
			var mouse_offset = (cursor_pos - editor.rect_global_position + editor.scroll_offset) / editor.zoom
			duplicate_graph_node.offset = mouse_offset + add_offset
			duplicate_graph_node.set_instructions(instructions)
			add_offset -= Vector2(40, 40)
	pass # Replace with function body.
