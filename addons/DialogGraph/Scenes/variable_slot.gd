tool
extends HBoxContainer

const _print = "Addon:DialogueGraph, variable_slot.gd"

var types:Array = ["int", "float", "string", "bool", "signal"]
var type:String

var name_before_focus:String

func on_update_editor_variable(var_name:String, var_value):
	print("%s on_update_editor_variable(var_name:%s, var_value:%s)"%[_print, var_name, var_value])
	if var_name == $LineEdit_name.text:
		set_value(var_value)

func _ready():
	if DialogueManager.load_tree:
		print("%s _ready()"%[_print])
	DialogueManager.connect("update_editor_variable", self, "on_update_editor_variable")
	$OptionButton.clear()
	for type in types:
		$OptionButton.add_item(type)
	type = types[0]
	update_value()

func set_name(new):
	$LineEdit_name.text = new
	name_before_focus = $LineEdit_name.text

func set_value(new):
	if DialogueManager.load_tree:
		print("%s set_value(new:%s)"%[_print, new])
	$LineEdit_value.visible = false
	$CheckBox.visible = false
	$SpinBox_float_value.visible = false
	$SpinBox_int_value.visible = false
	$OptionButton.text = type
	match type:
		"bool":
			$CheckBox.pressed = new
			$CheckBox.visible = true
		"string":
			$LineEdit_value.text = str(new)
			$LineEdit_value.visible = true
		"int":
			$SpinBox_int_value.value = int(new)
			$SpinBox_int_value.visible = true
		"float":
			$SpinBox_float_value.value = float(new)
			$SpinBox_float_value.visible = true
		

func update_value():
	$LineEdit_value.visible = false
	$CheckBox.visible = false
	$SpinBox_float_value.visible = false
	$SpinBox_int_value.visible = false
	match type:
		"bool":
			$CheckBox.visible = true
			type = "bool"
		"string":
			$LineEdit_value.visible = true
			type = "string"
		"int":
			$SpinBox_int_value.visible = true
			type = "int"
		"float":
			$SpinBox_float_value.visible = true
			type = "float"
		"signal":
			type = "signal"
	
	if DialogueManager.load_tree == false: slot_update()

# func for save tree
func slot_update():
	if DialogueManager._debug_print:
		print("%s slot_update() name_before_focus:%s, $LineEdit_name.text:%s"%[_print, name_before_focus, $LineEdit_name.text])
	var editor = get_parent().owner
#	if editor != GraphEdit: return
	if ("tree" in editor) == false: return
	
	editor.tree["Variables"].erase(name_before_focus)
	
#	Get var_name
	var var_name:String = ""
	if editor.tree["Variables"].has($LineEdit_name.text):
		if name_before_focus == $LineEdit_name.text:
#			print("%s slot_update() var name !change"%[_print, var_name])
			var_name = $LineEdit_name.text
		else:
#			print("%s slot_update() var name change"%[_print, var_name])
			var count:int = 1
			while(var_name == ""):
				if editor.tree["Variables"].has("%s-%s"%[$LineEdit_name.text, count]):
					count += 1
				else:
					var_name = "%s-%s"%[$LineEdit_name.text, count]
			$LineEdit_name.text = var_name
	else:
		var_name = $LineEdit_name.text
#	print("%s slot_update() var_slot_name result:%s"%[_print, var_name])
#	Add variable to tree
	match type:
		"bool":
			editor.tree["Variables"][var_name] = [$CheckBox.toggle_mode, type]
		"string":
			editor.tree["Variables"][var_name] = [$LineEdit_value.text, type]
		"int":
			editor.tree["Variables"][var_name] = [$SpinBox_int_value.value, type]
		"float":
			editor.tree["Variables"][var_name] = [$SpinBox_float_value.value, type]
		"signal":
			editor.tree["Variables"][var_name] = ["", type]
#	Save tree
	editor.save_tree()
	if DialogueManager._debug_print:
		print("%s slot_update() success, var_slot_name:%s"%[_print, var_name])

func _on_OptionButton_item_selected(index):
	type = $OptionButton.text
	update_value()
	slot_update()


func _on_Button_delete_pressed():
	if DialogueManager._debug_print:
		print("%s _on_Button_delete_pressed() var_slot_name:%s"%[_print, $LineEdit_name.text])
	var workspace = get_parent().owner
	workspace.tree["Variables"].erase($LineEdit_name.text)
	if DialogueManager._debug_print:
		print("%s _on_Button_delete_pressed() data after deleting a variable:%s"%[_print, workspace.tree["Variables"]])
	workspace.save_tree()
	if DialogueManager._debug_print:
		print("%s _on_Button_delete_pressed() var_slot_name:%s, success"%[_print, $LineEdit_name.text])
	queue_free()


func _on_LineEdit_name_text_entered(new_text):
	slot_update()
	name_before_focus = new_text


func _on_CheckBox_toggled(button_pressed):
	slot_update()


func _on_SpinBox_int_value_value_changed(value):
	slot_update()


func _on_LineEdit_value_text_changed(new_text):
	slot_update()


func _on_SpinBox_float_value_value_changed(value):
	slot_update()



func _on_LineEdit_name_focus_exited():
#	print("_on_LineEdit_name_focus_exited()")
	slot_update()
	name_before_focus = $LineEdit_name.text
