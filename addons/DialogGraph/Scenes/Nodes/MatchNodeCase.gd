tool
extends HBoxContainer

export var is_default:bool setget set_is_default

var _case_id:int

func set_is_default(new:bool):
	is_default = new
	if is_default:
		$LineEdit.text = "_ default"
		$LineEdit.editable = false
		$delete_case.disabled = true
	else:
		$LineEdit.text = ""
		$LineEdit.editable = true
		$delete_case.disabled = false

func get_value():
	return $LineEdit.text

func set_value(new):
	$LineEdit.text = str(new)

func _on_delete_case_pressed():
	get_parent().remove_case(self)
