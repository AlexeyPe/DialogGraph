tool
extends HBoxContainer

var slot_id:int = 0
var slot_id_enable:int = 0

func get_value():
	return $LineEdit.text

func set_value(new):
	$LineEdit.text = str(new)

func _on_delete_option_pressed():
	get_parent().remove_option(self)
