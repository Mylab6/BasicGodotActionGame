tool
extends Polygon2D
class_name VectorFill
# Polygon2D used as "fill" for a VectorPath

export(NodePath) var path_node_path setget set_path_node_path
var is_vector_fill := true
onready var is_ready := true


func _get_configuration_warning():
	if ! _get_path_node():
		return "No valid path set"
	return ""


func set_path_node_path(new_path :NodePath) -> void:
	path_node_path = new_path
	update_configuration_warning()
	if is_ready and path_node_path:
		update_fill()


func update_fill():
	var node = _get_path_node()
	if ! node:
		return
	polygon = node.get_shape(0,0)


func _get_path_node():
	if path_node_path == "":
		return null
	var node = get_node(path_node_path)
	if ! node:
		return null
	if node.get('is_vector_path'):
		return node
	return null
