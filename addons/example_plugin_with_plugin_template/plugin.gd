tool
extends "./godot_plugin.gd"

var control = Button.new()
func _enter_tree() -> void:
	var welcome_node := get_plugin_welcome_node()
	var tab := welcome_node.get_tab_by_idx(0)
	var label = Label.new()
	register_plugin_node(label)
	welcome_node.window_title = "Thank you for using plugin template!"
	label.text = "Now the example plugin is loaded and you can see the source code"
	tab.add_child(label)
	
	
	show_plugin_version_button()
	
	control.name = "ExampleDock"
	register_control_to_dock(control)


func _ready() -> void:
	print("Example Plugin With Godot Plugin loaded")


func enable_plugin() -> void:
	show_welcome_node()
