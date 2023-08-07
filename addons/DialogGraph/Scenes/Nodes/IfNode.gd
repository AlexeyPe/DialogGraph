tool
extends GraphNode

export var is_use_random_port:bool setget set_is_use_random_port

func set_is_use_random_port(new:bool):
	is_use_random_port = new
	if !has_node("HBoxContainer/is_use_random_port"):return
	if is_use_random_port:
		set_slot_enabled_left(2, true)
		$HBoxContainer/is_use_random_port.visible = true
	else:
		set_slot_enabled_left(2, false)
		$HBoxContainer/is_use_random_port.visible = false

func get_type() -> String:
	return "IfNode"
