@tool
extends EditorScenePostImport

"""
Author: Daniel Glebinski
Version: 1.0
Improvements: ChatGPT Code Copilot (December 2024)

License: MIT License
-------------------------------------
MIT License

Copyright (c) 2024 Daniel Glebinski

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
-------------------------------------

This script is designed to be used as an import script in the Godot Engine. 

Purpose:
- Automatically processes imported scenes and replaces nodes with specific names or types.
- Replaces nodes with names ending in a customizable tag (default: "_CM") that are of type `CollisionObject3D` with `Area3D`.
- Ensures the transformed scene is saved as a `.tscn` file for further use.

Features:
1. Dynamic Node Replacement:
   - Finds nodes ending with the specified tag (default: "_CM").
   - Replaces eligible nodes (of type `CollisionObject3D`) with `Area3D` nodes, maintaining their name, transform, and position in the hierarchy.
   - Logs unsupported nodes with the tag that do not match the required type.

2. Scene Saving:
   - Automatically saves the processed scene as a `.tscn` file in the same directory as the imported file.
   - Ensures that the target directory exists before saving.

3. Customizable Behavior:
   - `hint_tag`: Customizable tag to identify nodes for processing (default: "_CM").
   - `save_as_tscn`: Toggle saving the processed scene.
   - `debug_mode`: Enable or disable verbose logging.

How to Use:
- Attach this script to the "Import Script" field of an imported resource (e.g., a `.glb` file).
- Customize the `hint_tag`, `save_as_tscn`, and `debug_mode` options via the inspector.

Scene Setup and Export Instructions:
1. Structure your file as follows:
   - The collision mesh must be parented to the mesh it is associated with.
   - Example hierarchy:
     ```
     Cube <- Mesh
         Cube_CM_colonly <- Collision Mesh
     ```

   - `Cube_CM_colonly` is the collision mesh node. Its name ends with the default `hint_tag` "_CM" and sould be tagged as "_colonly", so that Godot recognize the collision mesh as such and does not render it.

2. Export the file as a `.glb` or another supported format.

3. In Godot:
   - Attach this script to the "Import Script" field of the resource in the Import tab.
   - Ensure the node naming and hierarchy follow the conventions outlined above.

Requirements:
- Godot Engine 4.x or compatible version.
"""


@export var save_as_tscn: bool = true  # Option to enable or disable saving as .tscn
@export var hint_tag: String = "_CM"  # Default "_CM" for the Collision Mesh
@export var debug_mode: bool = true  # Enable/disable verbose logging


func _post_import(scene: Node) -> Node:
    log_debug("--- Import for scene: " + scene.name + " ---")
    
    # Process nodes (replace _CM with Area3D)
    var replaced_nodes_count = process_nodes(scene)

    if replaced_nodes_count == 0:
        print("Warning: No nodes matching '" + hint_tag + "' were found in the scene.")

    # Save as .tscn if the option is enabled
    if save_as_tscn:
        var source_path = get_source_file()
        if source_path == "" or source_path == null:
            print("Error: Failed to get source file path.")
            return scene  # Exit early if the source path is invalid

        var save_path = source_path.get_base_dir().path_join(scene.name + ".tscn")
        log_debug("save_path: " + save_path)
        save_scene_as_tscn(scene, save_path)

    return scene


func process_nodes(node: Node) -> int:
    """
    Processes nodes in the scene tree, replacing nodes ending with hint_tag
    and derived from CollisionObject3D with Area3D.

    Returns:
        int: The count of nodes replaced.
    """
    var replaced_count = 0
    for child in node.get_children():
        if child.name.ends_with(hint_tag):
            if child is CollisionObject3D:
                log_debug("Replacing node: " + child.name + " with Area3D")
                replace_with_area3d(child)
                replaced_count += 1
            else:
                print("Warning: Node '" + child.name + "' matches '" + hint_tag + "' but is not a CollisionObject3D.")
        
        # Continue processing child nodes recursively
        replaced_count += process_nodes(child)
    return replaced_count


func replace_with_area3d(node: Node):
    """
    Replaces a node with an Area3D, preserving its name, transform, and children.

    Args:
        node (Node): The node to replace.
    """
    var parent = node.get_parent()
    if parent:
        var new_node = Area3D.new()
        new_node.name = node.name
        new_node.transform = node.transform

        # Replace node and free the old one
        node.replace_by(new_node)
        node.queue_free()
        log_debug("Successfully replaced node: " + node.name + " with Area3D")
    else:
        print("Error: Node " + node.name + " does not have a parent. Skipping replacement.")


func save_scene_as_tscn(scene: Node, source_path: String):
    """
    Saves the processed scene as a .tscn file.

    Args:
        scene (Node): The processed scene to save.
        source_path (String): The source file path of the scene.
    """
    if source_path.strip_edges() == "":
        print("Error: Source path is empty. Cannot determine save path.")
        return

    if scene.name.strip_edges() == "":
        print("Error: Scene name is empty. Cannot determine save path.")
        return

    var save_path = source_path.get_base_dir().path_join(scene.name + ".tscn")
    log_debug("Saving processed scene to: " + save_path)

    # Ensure the directory exists
    ensure_directory_exists(save_path)

    var packed_scene = PackedScene.new()
    var pack_result = packed_scene.pack(scene)
    if pack_result == OK:
        var save_result = ResourceSaver.save(packed_scene, save_path)
        if save_result == OK:
            print("Scene saved successfully at: " + save_path)
        else:
            print("Failed to save .tscn file. Error code: " + str(save_result))
    else:
        print("Failed to pack the scene. Error code: " + str(pack_result))


func ensure_directory_exists(path: String) -> void:
    """
    Ensures the directory for the given path exists, creating it if necessary.

    Args:
        path (String): The full path to validate or create.
    """
    var base_dir = path.get_base_dir()
    var dir = DirAccess.open(base_dir)
    if dir == null:
        dir = DirAccess.open(".")  # Open current directory
        if dir == null:
            print("Error: Failed to open current directory. Cannot create base directory.")
            return
        var create_result = dir.make_dir_recursive(base_dir)
        if create_result != OK:
            print("Error: Failed to create directory: " + base_dir)


func log_debug(message: String) -> void:
    """
    Logs a debug message if debug_mode is enabled.

    Args:
        message (String): The debug message to log.
    """
    if debug_mode:
        print(message)
