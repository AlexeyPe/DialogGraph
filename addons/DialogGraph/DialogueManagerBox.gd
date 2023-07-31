tool
extends Control
class_name DialogueManagerBox

var current_row_data:DialogueManager.RowData

# Main
export var root_node:NodePath

# Text
export var rich_text_speaker:NodePath
export var rich_text_description:NodePath

# Buttons options
export var button_1:NodePath
export var button_2:NodePath
export var button_3:NodePath
export var button_4:NodePath

# Close button(For Editor mode)
export var button_close:NodePath

# Shows this button when all options are "" or null
export var button_empty:NodePath

func _get(property):
	match property:
		"button_1": button_1
		"button_2": button_2
		"button_3": button_3
		"button_4": button_4

func on_run_row(row_data:DialogueManager.RowData):
	get_node(root_node).visible = true
	get_node(rich_text_speaker).bbcode_text = row_data.speaker
	get_node(rich_text_description).bbcode_text = row_data.description
	
	current_row_data = row_data
	
	var show_button_empty:bool = true
	for i in row_data.options.size():
		if row_data.options[i] == "" or row_data.options[i] == null:
			get_node(get("button_%s"%[i+1])).visible = false
		else:
			show_button_empty = false
			get_node(get("button_%s"%[i+1])).text = row_data.options[i]
			get_node(get("button_%s"%[i+1])).visible = true
	if show_button_empty:
		get_node(button_empty).visible = true
	else:
		get_node(button_empty).visible = false

func on_button_1_pressed():
	DialogueManager.run_from_row(current_row_data.row_links[0])

func on_button_2_pressed():
	DialogueManager.run_from_row(current_row_data.row_links[1])

func on_button_3_pressed():
	DialogueManager.run_from_row(current_row_data.row_links[2])

func on_button_4_pressed():
	DialogueManager.run_from_row(current_row_data.row_links[3])

func on_button_close_pressed():
	get_node(root_node).visible = false

func on_button_empty_pressed():
	if current_row_data.row_links.size() == 0:
		get_node(root_node).visible = false
	else:
		DialogueManager.run_from_row(current_row_data.row_links[0])

func _ready():
	DialogueManager.connect("on_run_row", self, "on_run_row")
	get_node(button_1).connect("pressed", self, "on_button_1_pressed")
	get_node(button_2).connect("pressed", self, "on_button_2_pressed")
	get_node(button_3).connect("pressed", self, "on_button_3_pressed")
	get_node(button_4).connect("pressed", self, "on_button_4_pressed")
	get_node(button_close).connect("pressed", self, "on_button_close_pressed")
	get_node(button_empty).connect("pressed", self, "on_button_empty_pressed")
	pass
