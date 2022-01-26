tool
extends EditorPlugin

#####
# Plugin classes
#####

class WelcomeNode extends WindowDialog:
	
	var _main_panel:TabContainer
	var _margin:MarginContainer
	var _menu:PopupMenu
	
	var _plugin_data:ConfigFile
	
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
		add_tab("Plugin Info")
		
		var label = Label.new()
		label.text = "This plugin uses Plugin Template v%s"%__PLUGIN_VERSION
		add_child(label)
		label.set_anchors_and_margins_preset(Control.PRESET_BOTTOM_RIGHT)
		label.add_color_override("font_color", get_color("disabled_font_color", "Editor"))
		
		var plugin_information:VBoxContainer = get_tab_by_name("Plugin Info")
		
		if _plugin_data:
			var keys = _plugin_data.get_section_keys(__Constants.PLUGIN)
			for key in keys:
				var value = _plugin_data.get_value(__Constants.PLUGIN, key, "")
				var info_label := Label.new()
				info_label.text = "{key}: {value}".format({"key":key.capitalize(), "value":value})
				plugin_information.add_child(info_label)
				
	
	
	func add_tab(tab_name:String) -> void:
		var tab = VBoxContainer.new()
		tab.name = tab_name
		_main_panel.add_child(tab)
	
	
	func get_tab_by_name(tab_name) -> Control:
		var tab:Control = null
		for tab_idx in _main_panel.get_tab_count():
			var title = _main_panel.get_tab_title(tab_idx)
			if title == tab_name:
				tab = get_tab_by_idx(tab_idx)
				break
		return tab
	
	
	func get_tab_by_idx(tab_idx:int) -> Control:
		var tab:Control = _main_panel.get_tab_control(tab_idx)
		return tab
	
	
	func get_tab_container() -> TabContainer:
		return _main_panel
	
	func set_plugin_data(plugin_data:ConfigFile) -> void:
		_plugin_data = plugin_data


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


func request(from_plugin:String, method:String, args:=[]):
	var plugin:EditorPlugin = get_plugin_or_null(from_plugin)
	if plugin == null:
		return
	
	assert(plugin.has_method(method))
	if plugin.has_method(method):
		return plugin.callv(method, args)


func get_plugin_or_null(plugin_name:String) -> EditorPlugin:
	if Engine.has_meta(plugin_name):
		return Engine.get_meta(plugin_name) as EditorPlugin
	return null

####
# "Virtual" methods
####

func _save_external_data() -> void:
	pass

#####
# Godot methods
#####

func _enter_tree() -> void:
	add_editor_node(__welcome_node)
	__add_plugin_version_button()


func _ready() -> void:
	__register_itself_on_editor()
	__register_plugin_template()


func save_external_data() -> void:
	_save_external_data()
	var plugin_data:ConfigFile = get_plugin_data()
	if __plugin_sensible_data_modified:
		var message = "{plugin} sensible data was modified. The plugin will be disabled"
		OS.alert(message.format({"plugin":get_plugin_name()}))
		get_editor_interface().call_deferred("set_plugin_enabled", get_plugin_folder_path().split("/")[-1], false)
	var _err = plugin_data.save(get_plugin_folder_path()+"/plugin.cfg")
	assert(_err == OK, "There was a problem while saving plugin data")


func _set(property: String, value) -> bool:
	var plugin_data := get_plugin_data()
	var has_property := false
	
	for section in plugin_data.get_sections():
		if property.begins_with("plugin_"):
			property = property.replace("plugin_", "")
			__plugin_sensible_data_modified = true
		has_property = plugin_data.has_section_key(section, property)
		if has_property:
			plugin_data.set_value(section, property, value)
			
	return has_property


func _get(property: String):
	var plugin_data := get_plugin_data()
	for section in plugin_data.get_sections():
		if property.begins_with("plugin_"):
			property = property.replace("plugin_", "")
		if plugin_data.has_section_key(section, property):
			return plugin_data.get_value(section, property, null)


func _get_property_list() -> Array:
	var p := []
	
	for section in __plugin_data.get_sections():
		var pre := ""
		var _section:String = str(section)
		
		if _section == __Constants.PLUGIN:
			pre = _section+"_"
		
		p.append({"name":_section.capitalize(), "type":TYPE_NIL, "usage":PROPERTY_USAGE_CATEGORY})
		
		for key in __plugin_data.get_section_keys(section):
			var _key:String = str(key)
			var _value = __plugin_data.get_value(_section, _key)
			var _type:int = typeof(_value)
			var usage_hint := PROPERTY_USAGE_EDITOR
			
			if _section == __Constants.PLUGIN:
				usage_hint |= PROPERTY_USAGE_RESTART_IF_CHANGED
				if not is_plugin_editable():
					usage_hint = 0
			
			p.append({"name":pre+key, "type":_type, "usage":usage_hint})
	return p


func _init() -> void:
	__registered_nodes = []
	
	__plugin_data = ConfigFile.new()
	__plugin_data.load(get_plugin_folder_path()+"/plugin.cfg")
	
	name = get_plugin_name()
	
	__welcome_node = WelcomeNode.new()
	__welcome_node.set_plugin_data(__plugin_data)
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
	const PLUGIN_TEMPLATE = "PluginTemplateHandler"


class __Logger:
	enum LogType {DEBUG, INFO, WARNING, ERROR}


class __PluginTemplate extends EditorPlugin:
	class __NodeHandler extends EditorInspectorPlugin:
		
		var ignore_category = false
		
		func can_handle(object: Object) -> bool:
			return object is EditorPlugin
		
		
		func parse_begin(object: Object) -> void:
			pass
		
		
		func parse_category(object: Object, category: String) -> void:
			ignore_category = "Node" == category
		
		
		func parse_property(object: Object, type: int, path: String, hint: int, hint_text: String, usage: int) -> bool:
			if ignore_category:
				return true
			return false
	
	
	var node_handler := __NodeHandler.new()
	
	func _enter_tree() -> void:
		add_inspector_plugin(node_handler)
	
	
	func _ready() -> void:
		__register_itself_on_editor()
	
	
	func _exit_tree() -> void:
		remove_inspector_plugin(node_handler)
	
	# Copied from godot_plugin since we can't extend itself
	func __register_itself_on_editor() -> void:
		Engine.set_meta(__Constants.PLUGIN_TEMPLATE, self)


const __PLUGIN_VERSION = 0.1

var __plugin_data:ConfigFile
var __welcome_node:WelcomeNode
var __version_button:BaseButton

var __registered_nodes:Array = []

var __plugin_sensible_data_modified:bool = false

func __add_plugin_version_button() -> void:
	if __version_button.is_inside_tree():
		return
	
	var _v = {"version":get_plugin_version(), "plugin_name":get_plugin_name()}
	
	__version_button.set("text", "[{version}]".format(_v))
	__version_button.hint_tooltip = "{plugin_name} version {version}".format(_v)
	__version_button.connect("pressed", self, "__WelcomeButton_pressed")
	
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
	get_editor_interface().inspect_object(self)


func __register_itself_on_editor() -> void:
	# Technically we can use get_tree(), but I don't rely on tree order
	Engine.set_meta(get_plugin_name(), self)
	add_tool_menu_item(get_plugin_name(), self, "__ToolMenu_item_pressed")
	connect("tree_exiting", self, "remove_tool_menu_item", [get_plugin_name()])


func __register_plugin_template() -> void:
	var plugin:EditorPlugin = get_plugin_or_null(__Constants.PLUGIN_TEMPLATE) as EditorPlugin
	if plugin != null:
		plugin.queue_free()
	plugin = __PluginTemplate.new()
	plugin.name = __Constants.PLUGIN_TEMPLATE
	get_parent().add_child(plugin)


func __WelcomeButton_pressed() -> void:
	__request_configuration()
	show_welcome_node()


func __ToolMenu_item_pressed(_d):
	__request_configuration()
	show_welcome_node()
