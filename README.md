# 📚 Godot Plugin Template
An `EditorPlugin` class with helpful functions to make plugins easily.

## 🚩 Installation
1. Download `godot_plugin.gd` file. You can download it directly from this repository or from the `releases` section. 
2. Put it inside your plugin folder and replace `extends EditorPlugin` with `extends "res://addons/<your_plugin_folder>/godot_plugin.gd"`

## 🕯️ Features
This script class aims to help plugins developers in their task of creating plugins, wrapping common tasks in functions, adding util nodes and managing the plugin data for them. 
That's why this class includes:

### 🔧 `WelcomeNode` node
A `Popup` node that appears when you need it, displaying information of the plugin and the nodes that you pass to it, fully customizable!

![WelcomeNode](#)

### 🔩 `VersionButton` node
A little button near Godot's version button to display the version of your plugin. Custom information and functions can be added.

![VersionButton](#)

### Plugin data configuration
Show, modify and update plugin's data directly in the editor, as if it were any common `Object`. Include your own data for your users and stop complaining about how to save that information!

![PluginData](#)

### ⛓️ Node management
You can register nodes as plugin nodes to avoid memory leaks. Do your work, and let the plugin handle the cleanup for you!

Some methods were wrapped around this idea, to save some time while making custom inspectors/docks/editors.

### 🧵 Comunnication between plugins
Get other active plugins and use them! Ideal if you want to make weak dependency and/or want to use other plugin's features.
> ⚠️ This only works for plugins that extends this script.


## 🧐 Usage example
```GDScript
extends "res://addons/my_plugin/godot_plugin.gd"

func _enter_tree() -> void:
  # Shows version button
  show_version_button()

# Default virtual methods are used in godot_plugin.gd
# Instead, use the same method with a _ prefix
func _enable_plugin() -> void:
  # Shows welcome node
  show_welcome_node()

func _ready() -> void:
  print("Hello! I'm a %s plugin"%get_plugin_real_name())
```
