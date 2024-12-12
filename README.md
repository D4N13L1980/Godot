# Godot Collision Mesh to Area3D Import Script

**Author:** Daniel Glebinski  
**Version:** 1.0  
**Improvements:** ChatGPT Code Copilot (December 2024)  

## License: MIT License
---

### MIT License
Copyright (c) 2024 Daniel Glebinski

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

---

## Purpose:
- Automatically processes imported scenes and replaces nodes with specific names or types.
- Replaces nodes with names ending in a customizable tag (default: `_CM`) that are of type `CollisionObject3D` with `Area3D`.
- Ensures the transformed scene is saved as a `.tscn` file for further use.

---

## Features:
### 1. Dynamic Node Replacement:
- Finds nodes ending with the specified tag (default: `_CM`).
- Replaces eligible nodes (of type `CollisionObject3D`) with `Area3D` nodes, maintaining their name, transform, and position in the hierarchy.
- Logs unsupported nodes with the tag that do not match the required type.

### 2. Scene Saving:
- Automatically saves the processed scene as a `.tscn` file in the same directory as the imported file.
- Ensures that the target directory exists before saving.

### 3. Customizable Behavior:
- `hint_tag`: Customizable tag to identify nodes for processing (default: `_CM`).
- `save_as_tscn`: Toggle saving the processed scene.
- `debug_mode`: Enable or disable verbose logging.

---

## How to Use:
- Attach this script to the "Import Script" field of an imported resource (e.g., a `.glb` file).
- Customize the `hint_tag`, `save_as_tscn`, and `debug_mode` options via the inspector.

---

## Scene Setup and Export Instructions:
### 1. Structure your file as follows:
- The collision mesh must be parented to the mesh it is associated with.
- Example hierarchy:
    ```plaintext
    Cube <- Mesh
        Cube_CM_colonly <- Collision Mesh
    ```
- `Cube_CM_colonly` is the collision mesh node. Its name ends with the default `hint_tag` "_CM" and should be tagged as `_colonly`, so that Godot recognizes the collision mesh as such and does not render it.

### 2. Export the file as a `.glb` or another supported format.

### 3. In Godot:
- Attach this script to the "Import Script" field of the resource in the Import tab.
- Ensure the node naming and hierarchy follow the conventions outlined above.

---

## Requirements:
- Godot Engine 4.x or compatible version.
