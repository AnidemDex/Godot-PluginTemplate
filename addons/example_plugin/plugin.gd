tool
extends EditorPlugin

var control = Button.new()
func _enter_tree() -> void:
	control.name = "Example Dock"
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UR, control)


func _exit_tree() -> void:
	remove_control_from_docks(control)
	control.queue_free()


func _ready() -> void:
	print("Example Plugin loaded")
