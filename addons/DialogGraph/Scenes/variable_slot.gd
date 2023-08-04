tool
extends HBoxContainer

const _print = "Addon:DialogueGraph, variable_slot.gd"

var types:Array = ["int", "float", "string", "bool"]

var name_before_focus:String

func _ready():
	for type in types:
		$OptionButton.add_item(type)
	update_value()

func set_name(new):
	$LineEdit_name.text = new

func set_string(new):
	$LineEdit_value.text = new
	$OptionButton.text = "string"
	update_value()

func set_int(new):
	$SpinBox_int_value.value
	$OptionButton.text = "int"
	update_value()

func set_float(new):
	$SpinBox_float_value.value
	$OptionButton.text = "float"
	update_value()

func set_bool(new):
	$CheckBox.toggle_mode = new
	$OptionButton.text = "bool"
	update_value()

func update_value():
	$LineEdit_value.visible = false
	$CheckBox.visible = false
	$SpinBox_float_value.visible = false
	$SpinBox_int_value.visible = false
	match $OptionButton.text:
		"bool":
			$CheckBox.visible = true
		"string":
			$LineEdit_value.visible = true
		"int":
			$SpinBox_int_value.visible = true
		"float":
			$SpinBox_float_value.visible = true
	slot_update()

# func for save tree
func slot_update():
	if DialogueManager._debug_print:
		print("%s slot_update()"%[_print])
	var workspace = get_parent().owner
	if ("tree" in workspace) == false: return
	
	workspace.tree["Variables"].erase(name_before_focus)
	
#	Get var_name
	var var_name:String
	if workspace.tree["Variables"].has($LineEdit_name.text):
		var count:int = 1
		while(var_name != null):
			if workspace.tree["Variables"].has("%s-%s"%[$LineEdit_name.text, count]):
				count += 1
			else:
				var_name = "%s-%s"%[$LineEdit_name.text, count]
	else:
		var_name = $LineEdit_name.text
#	Add variable to tree
	match $OptionButton.text:
		"bool":
			workspace.tree["Variables"][var_name] = $CheckBox.toggle_mode
		"string":
			workspace.tree["Variables"][var_name] = $LineEdit_value.text
		"int":
			workspace.tree["Variables"][var_name] = $SpinBox_int_value.value
		"float":
			workspace.tree["Variables"][var_name] = $SpinBox_float_value.value
#	Save tree
	workspace.save_tree()
	if DialogueManager._debug_print:
		print("%s slot_update() success, slot_name:%s"%[_print, var_name])

func _on_OptionButton_item_selected(index):
	update_value()
	slot_update()



func _on_Button_delete_pressed():
	var workspace = get_parent().owner
	if not ("tree" in workspace): 
		workspace.tree["Variables"].erase($LineEdit_name.name)
	queue_free()


func _on_LineEdit_name_text_entered(new_text):
	slot_update()


func _on_LineEdit_name_text_changed(new_text):
	slot_update()


func _on_CheckBox_toggled(button_pressed):
	slot_update()


func _on_SpinBox_int_value_value_changed(value):
	slot_update()


func _on_LineEdit_value_text_changed(new_text):
	slot_update()


func _on_SpinBox_float_value_value_changed(value):
	slot_update()
