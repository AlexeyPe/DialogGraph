tool
extends EditorPlugin

const _print = "Addon:DialogueGraph, manager.gd"
const Editor = preload("res://addons/DialogGraph/Scenes/Editor.tscn")
const AddonName = "DialogueGraph"
var editor_instance:Control

func _enter_tree():
	print("%s _enter_tree()"%[_print])
	editor_instance = Editor.instance()
	get_editor_interface().get_editor_viewport().add_child(editor_instance)
	make_visible(false)
	print("%s _enter_tree success"%[_print])

func _exit_tree():
	print("%s _exit_tree()"%[_print])
	if editor_instance:
		editor_instance.queue_free()
	print("%s _exit_tree() success"%[_print])

func has_main_screen():
	return true

func get_plugin_name():
	return AddonName

func get_plugin_icon():
	return load("res://addons/DialogGraph/imgs/addon_icon.png")

func make_visible(visible):
	editor_instance.visible = visible
