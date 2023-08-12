tool
extends Node

# Is singltone
var _debug_print:bool = true setget set_debug_print

#	To find out about the node code, check Scenes/Nodes/...
#	New nodes are added via Scenes/Editor.tscn/Editor(root)/GraphNodesScenes:[path]

#	Is "tree" and json save
#	{
#		"SaveVersion": int,
#		"SupportOldVersions": [int],
#		"Variables": { "var_name:String": value:int/float/string/bool },
#		"NodeTypes": [String], # TimelineHeadNode, DialogueNode
#		"TimelineHeads":{
#			"string(TimelineHeadNode.name)": index_start:int
#		},
#		"Nodes": [
#			# I could save this as a Dictionary for file readability
#			# But why read this file?..) Let it contain less information so that the file weighs less
#			# instructions - contains different information, depends on which node is saved (check .gd in Nodes folder)
#			[links:[ [index, from_port, to_port] ], node.rect_min_size:Vector2, node.offset:Vector2, node_type_index:int, instructions:[?] ]
#			[ [[int, int, int]], Vector2, Vector2, int, [?] ]
#			[ 0,				 1, 	  2,	   3,	4   ]
#		]
#	}

# Default signals are written in Editor.gd, row 41
# export var default_signals:Array = ["on_texture_update"]

const SupportVersions = 1
const _print = "Addon:DialogueGraph, DialogueGraph.gd"

class RowData:
	var row_index:int
	var speaker:String
	var description:String
#	["","","",""] button option text or empty string(size() = 4, for 1 version)
	var options:Array
	var row_links:Array
	
	func _init(row_index:int, speaker:String, description:String, options:Array, row_links:Array):
		self.row_index = row_index
		self.speaker = speaker
		self.description = description
		self.options = options
		for row_link in row_links:
			self.row_links.append(row_link[0])

signal on_run_row(row_data)
signal on_run_timeline_head(head_name, row_index)
# Emit from Editor.gd, connect in Signal/Match/If/Set Nodes
signal on_delete_variable(variable_name, variable_value, variable_type)
# signal_name:String, signal_data:Dictionary
signal on_emit_custom_signal(signal_name, signal_data)
signal on_toggle_debug_print(new, old)


var load_tree:bool = false
var tree:Dictionary

var tree_signals:Array
# has_user_signal does not work..(
var added_signals:Array = []

func set_debug_print(new:bool):
	var old = _debug_print
	_debug_print = new
	emit_signal("on_toggle_debug_print", new, old)

func on_emit_custom_signal(signal_name:String, signal_data:Dictionary):
#	This function for test signals
	print("%s on_emit_custom_signal(signal_name:%s, signal_data:%s)"%[_print, signal_name, signal_data])
	pass

func _ready():
	connect("on_emit_custom_signal", self, "on_emit_custom_signal")
	pass

func load_tree(path:String, params:Dictionary):
	load_tree = true

# call in Scenes/Editor.gd save_tree()
func set_tree(new_tree:Dictionary):
	if SupportVersions == new_tree["SaveVersion"]: 
		if _debug_print: print("%s set_tree(new_tree)"%[_print])
	else:
		printerr("%s set_tree(new_tree)"%[_print])
		print("set_tree SupportVersions:%s new_tree['SaveVersion']:%s"%[SupportVersions, new_tree['SaveVersion']])
		load_tree = false
		tree = {}
		return
	load_tree = true
	tree = new_tree
	
	tree_signals = []
	
	
	for variable_name in tree["Variables"].keys():
		var variable_type:String = tree["Variables"][variable_name][1]
		if variable_type == "signal":
			tree_signals.append(variable_name)
	
	if _debug_print: print("%s set_tree(new_tree) success"%[_print])

func run_from_row(row_id:int):
	if load_tree == false: 
		printerr("%s:60 run_from_row(row_id:%s) load_tree == false"%[_print, row_id])
		return
	elif _debug_print: print("%s run_from_row(row_id:%s)"%[_print, row_id])
	
	var _row_data = tree["Nodes"][row_id]
	
	print("%s _row_data %s"%[_print, _row_data])

#	_row_data = [links:[ [index, from_port, to_port] ], node.rect_min_size:Vector2, node.offset:Vector2, node_type_index:int, instructions:[?] ]	
	match tree['NodeTypes'][_row_data[3]]:
		"TimelineHeadNode": 
#			_row_data[4] = [head_name:String]
			emit_signal("on_run_timeline_head", _row_data[4][0])
			run_from_row(_row_data[0][0][0])
		"DialogueNode":
#			_row_data[4] = [speaker:String, text:String, option1:String, option2:String, option3:String, option4:String]
			var speaker:String = _row_data[4][0]
			var description:String = _row_data[4][1]
			var options:Array = [
					_row_data[4][2], 
					_row_data[4][3], 
					_row_data[4][4], 
					_row_data[4][5]
				]
			emit_signal("on_run_row", RowData.new(
				row_id, 
				speaker, 
				description, 
				options, 
				_row_data[0]
				))
		"SignalNodePreviewTexture":
#			_row_data[4] = [ signal_name:String, signal_data:Dictionary ]
#			signal_data = {img_path:String}
			emit_signal("on_emit_custom_signal", _row_data[4][0], _row_data[4][1])
			run_from_row(_row_data[0][0][0])
		"SignalNode":
#			_row_data[4] = [ signal_name:String, signal_data:Dictionary ]
			emit_signal("on_emit_custom_signal", _row_data[4][0], _row_data[4][1])
			run_from_row(_row_data[0][0][0])
	pass

func run_from_timeline_head(timeline_head:String):
	if _debug_print: print("%s"%[_print])
	pass 
