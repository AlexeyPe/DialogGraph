tool
extends HBoxContainer

export var is_default:bool setget set_is_default

func set_is_default(new:bool):
	is_default = new
	if is_default:
		$LineEdit.text = "_ default"
		$LineEdit.editable = false
		$add_option.disabled = true
	else:
		$LineEdit.text = ""
		$LineEdit.editable = true
		$add_option.disabled = false
