tool
extends EditorPlugin

#####
# Plugin classes
#####

class WelcomeNode extends WindowDialog:
	
	var _main_panel:TabContainer
	var _margin:MarginContainer
	var _menu:PopupMenu
	
	func _ready() -> void:
		add_stylebox_override("panel", get_stylebox("panel", "ProjectSettingsEditor"))
		
		var _margin = MarginContainer.new()
		_margin.set_anchors_and_margins_preset(Control.PRESET_WIDE, Control.PRESET_MODE_KEEP_SIZE)
		_margin.add_constant_override("margin_top", 8)
		_margin.add_constant_override("margin_left", 2)
		_margin.add_constant_override("margin_right", 2)
		_margin.add_constant_override("margin_bottom", 16)
		add_child(_margin)
		
		_main_panel = TabContainer.new()
		_margin.add_child(_main_panel)
		
		_menu = PopupMenu.new()
		add_child(_menu)
		_main_panel.set_popup(_menu)
		
		add_tab("Information")
		
		var label = Label.new()
		label.text = "This plugin uses Plugin Template v%s"%__PLUGIN_VERSION
		add_child(label)
		label.set_anchors_and_margins_preset(Control.PRESET_BOTTOM_RIGHT)
		label.add_color_override("font_color", get_color("disabled_font_color", "Editor"))
	
	
	func add_tab(tab_name:String) -> void:
		var tab = VBoxContainer.new()
		tab.name = tab_name
		_main_panel.add_child(tab)

#####
# Plugin methods
#####

func is_plugin_editable() -> bool:
	return __plugin_data.get_value(__Constants.PLUGIN, "editable", false)


func get_plugin_path() -> String:
	var script:Script = get_script() as Script
	var path:String = ""
	# No idea why this should return null but anyway...
	if script:
		path = script.resource_path
	return path


func get_plugin_folder_path() -> String:
	var path:String = get_plugin_path()
	return path.get_base_dir()


func get_plugin_author() -> String:
	return __plugin_data.get_value(__Constants.PLUGIN, __Constants.AUTHOR, "")


func get_plugin_version() -> String:
	return str(__plugin_data.get_value(__Constants.PLUGIN, __Constants.VERSION, ""))


func get_plugin_name() -> String:
	return __plugin_data.get_value(__Constants.PLUGIN, __Constants.NAME, "")


func get_plugin_description() -> String:
	return __plugin_data.get_value(__Constants.PLUGIN, __Constants.DESCRIPTION, "")


func get_plugin_docs_url() -> String:
	return __plugin_data.get_value(__Constants.PLUGIN, __Constants.DOCS, "")


func get_plugin_repository() -> String:
	return __plugin_data.get_value(__Constants.PLUGIN, __Constants.REPOSITORY, "")


func get_plugin_license() -> String:
	return __plugin_data.get_value(__Constants.PLUGIN, __Constants.LICENSE, "")


func get_plugin_data() -> ConfigFile:
	return __plugin_data


func get_plugin_welcome_node() -> WelcomeNode:
	return __welcome_node


func register_plugin_node(node:Node) -> void:
	assert(node != null)
	
	if not is_connected("tree_exiting", node, "queue_free"):
		connect("tree_exiting", node, "queue_free")
	
	assert(not node in __registered_nodes)
	__registered_nodes.append(node)


func add_editor_node(node:Node) -> void:
	if not node in __registered_nodes:
		register_plugin_node(node)
	
	if not node.is_inside_tree():
		get_editor_interface().get_base_control().add_child(node)


func show_welcome_node() -> void:
	__welcome_node.popup_centered_ratio(0.45)


func show_plugin_version_button() -> void:
	__version_button.show()

####
# "Virtual" methods
####


#####
# Godot methods
#####

func _enter_tree() -> void:
	add_editor_node(__welcome_node)
	__add_plugin_version_button()


func _ready() -> void:
	pass


func _get_property_list() -> Array:
	var p := []
	
	for section in __plugin_data.get_sections():
		if section == "plugin":
			continue
		var _section:String = str(section)
		p.append({"name":_section.capitalize(), "type":TYPE_NIL, "usage":PROPERTY_USAGE_CATEGORY})
		for key in __plugin_data.get_section_keys(section):
			var _key:String = str(key)
			var _value = __plugin_data.get_value(_section, _key)
			var _type:int = typeof(_value)
			p.append({"name":key, "type":_type})
	return p


func _init() -> void:
	__registered_nodes = []
	
	__plugin_data = ConfigFile.new()
	__plugin_data.load(get_plugin_folder_path()+"/plugin.cfg")
	
	__welcome_node = WelcomeNode.new()
	__welcome_node.window_title = get_plugin_name().capitalize()
	register_plugin_node(__welcome_node)
	
	__version_button = ToolButton.new()
	register_plugin_node(__version_button)


#####
# Private
#####

# what is an struct?
class __Constants:
	const PLUGIN = "plugin"
	const VERSION = "version"
	const NAME = "name"
	const AUTHOR = "author"
	const SCRIPT = "script"
	const DESCRIPTION = "description"
	const DOCS = "docs"
	const REPOSITORY = "repository"
	const LICENSE = "license"


class __Logger:
	enum LogType {DEBUG, INFO, WARNING, ERROR}
	pass


class __PluginTemplate extends EditorPlugin:
	class __NodeHandler extends EditorInspectorPlugin:
		pass
	pass

const __PLUGIN_VERSION = 0.1

var __plugin_data:ConfigFile
var __welcome_node:WelcomeNode
var __version_button:BaseButton

var __registered_nodes:Array = []

func __add_plugin_version_button() -> void:
	if __version_button.is_inside_tree():
		return
	
	var _v = {"version":get_plugin_version(), "plugin_name":get_plugin_name()}
	
	__version_button.set("text", "[{version}]".format(_v))
	__version_button.hint_tooltip = "{plugin_name} version {version}".format(_v)
	__version_button.connect("pressed", self, "__request_configuration")
	
	var _new_color = __version_button.get_color("font_color")
	_new_color.a = 0.6
	__version_button.add_color_override("font_color", _new_color)
	__version_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var _dummy := Control.new()
	var _dock_button := add_control_to_bottom_panel(_dummy, "dummy")
	_dock_button.get_parent().get_parent().add_child(__version_button)
	_dock_button.get_parent().get_parent().move_child(__version_button, 1)
	remove_control_from_bottom_panel(_dummy)
	_dummy.free()
	
	__version_button.hide()


func __request_configuration() -> void:
	get_editor_interface().edit_node(self)
