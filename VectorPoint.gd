tool
extends VectorControl
class_name VectorPoint
# Point for a VectorPath

enum HandlesType {NONE, IN, OUT, BOTH, MIRROR_IN, MIRROR_OUT, IN_OUT}
export(HandlesType) var handles_type = HandlesType.BOTH setget set_handles_type
export(float, 0.0, 1.0) var stroke_width := 1.0
export(Color) var stroke_color
export(float, 0.0, 100.0) var bake_interval := 0.0
var is_control_point := true
var _cached_stroke_width = 1.0
var _cached_stroke_color
var _cached_bake_interval = 0.0


func _get_configuration_warning() -> String:
	var expected_handle_count :int = {
		HandlesType.NONE: 0,
		HandlesType.IN: 1,
		HandlesType.OUT: 1,
		HandlesType.BOTH: 2,
		HandlesType.MIRROR_IN: 1,
		HandlesType.MIRROR_OUT: 1,
		HandlesType.IN_OUT: 1
	}[handles_type]
	if get_handles().size() != expected_handle_count:
		return (
			"Handle type "
			+ String(HandlesType.keys()[handles_type])
			+ " expects "
			+ String(expected_handle_count)
			+ " handles"
		);
	return ""


func get_has_changed() -> bool:
	if _cached_bake_interval != bake_interval:
		return true
	if .get_has_changed():
		return true
	return false


func get_shape_has_changed() -> bool:
	if get_has_changed():
		return true
	for handle in get_handles():
		if handle.get_has_changed():
			return true
	return false


func get_handle_in_has_changed() -> bool:
	if _cached_transform == null:
		return true
	var handles := get_handles()
	match handles_type:
		HandlesType.NONE, HandlesType.OUT:
			return false
		_:
			if handles.size() == 0:
				return false
			return handles[0].get_has_changed()


func get_handle_out_has_changed() -> bool:
	if _cached_transform == null:
		return true
	var handles := get_handles()
	match handles_type:
		HandlesType.NONE, HandlesType.IN:
			return false
		HandlesType.BOTH:
			if handles.size() < 2:
				return false
			return handles[1].get_has_changed()
		_:
			if handles.size() == 0:
				return false
			return handles[0].get_has_changed()


func set_shape_has_changed(new_value: bool) -> void:
	if new_value:
		_cached_bake_interval = null
	else:
		_cached_bake_interval = bake_interval
	.set_has_changed(new_value)
	for handle in get_handles():
		handle.set_has_changed(new_value)


func get_stroke_data_has_changed() -> bool:
	return (stroke_width != _cached_stroke_width
			or stroke_color != _cached_stroke_color)


func set_stroke_data_has_changed(new_value :bool) -> void:
	if new_value:
		_cached_stroke_color = null
		_cached_stroke_width = null
	else:
		_cached_stroke_color = stroke_color
		_cached_stroke_width = stroke_width


func get_handle_in(base_node: Node2D) -> Vector2:
	match handles_type:
		HandlesType.NONE, HandlesType.OUT:
			return Vector2.ZERO
		HandlesType.MIRROR_OUT:
			return _get_handle(base_node, 0) * -1
		_:
			return _get_handle(base_node, 0)


func get_handle_out(base_node: Node2D) -> Vector2:
	match handles_type:
		HandlesType.NONE, HandlesType.IN:
			return Vector2.ZERO
		HandlesType.MIRROR_IN:
			return _get_handle(base_node, 0) * -1
		HandlesType.BOTH:
			return _get_handle(base_node, 1)
		_:
			return _get_handle(base_node, 0)


func set_handles_type(new_type: int) -> void:
	handles_type = new_type
	set_has_changed(true)
	update_configuration_warning()


func get_handles() -> Array:
	var handles := []
	for child in get_children():
		if child.get("is_control_handle"):
			handles.append(child)
	return handles


func _get_handle(base_node: Node2D, index: int) -> Vector2:
	var handles := get_handles()
	if index >= handles.size():
		return Vector2.ZERO
	var handle := (handles[index] as VectorHandle)
	var handle_position := handle.get_position_in(base_node)
	var own_position := get_position_in(base_node)
	return handle_position - own_position
