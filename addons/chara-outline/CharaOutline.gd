extends Node

#
# キャラクタアウトライン by あるる（きのもと 結衣） @arlez80
# Character Outline by Yui Kinomoto @arlez80
#
# MIT License
#

class_name CharaOutline, "icon.png"

const group_name:String = "arlez80:character_outline"

var loaded_tscn:Node
var outline_viewport:Viewport
var outline_camera:Camera
var outline_filter:ColorRect
var outline_draw:ColorRect

export(int, LAYERS_3D_RENDER) var layers_for_draw_target:int = 1 << 19
var max_objects:int = 32

func _ready( ):
	self.loaded_tscn = preload("CharaOutlineBase.tscn").instance( )
	self.add_child( self.loaded_tscn )

	self.outline_viewport = self.loaded_tscn.get_node( "OutlineViewport" )
	self.outline_camera = self.loaded_tscn.get_node( "OutlineViewport/Camera" )
	self.outline_filter = self.loaded_tscn.get_node( "OutlineViewport/DetectOutlineFilter" )
	self.outline_draw = self.loaded_tscn.get_node( "OutlineDraw" )

	self.outline_camera.cull_mask = self.layers_for_draw_target
	self._generate_nodes( )

func _clear_all_nodes( ) -> void:
	var start_node:Node = self.get_viewport( )
	for t in start_node.get_tree( ).get_nodes_in_group( self.group_name ):
		if start_node.is_a_parent_of( t ):
			t.queue_free( )

func _generate_nodes( ) -> void:
	self._clear_all_nodes( )
	self._check_registers( self.get_tree( ).get_root( ) )

func _check_registers( n:Node ):
	for t in n.get_children( ):
		if t is CharaOutlineRegister:
			var root:Node = t.get_node( t.target_path )
			self._copy_nodes( root, t )

		self._check_registers( t )

func _copy_nodes( n:Node, cor:CharaOutlineRegister ):
	if n is MeshInstance:
		self._copy_mesh_instance( n.get_parent( ), n, cor )

	for t in n.get_children( ):
		self._copy_nodes( t, cor )

func _copy_mesh_instance( parent:Node, mi:MeshInstance, cor:CharaOutlineRegister ):
	if mi.mesh == null or ( self.group_name in mi.get_groups( ) ):
		return

	var copyed: = MeshInstance.new( )
	parent.add_child( copyed )

	copyed.mesh = mi.mesh
	copyed.skeleton = mi.skeleton
	copyed.skin = mi.skin
	copyed.software_skinning_transform_normals = mi.software_skinning_transform_normals
	copyed.visible = mi.visible
	copyed.layers = self.layers_for_draw_target
	mi.layers = mi.layers & ( ~self.layers_for_draw_target )

	var matr: = ShaderMaterial.new( )
	matr.shader = preload("id_and_depth.shader")
	if cor.hide:
		matr.set_shader_param("object_id", 0.0)
		matr.set_shader_param("hide", 1.0 )
	else:
		matr.set_shader_param("object_id", float( cor.object_id + 1 ) / float( self.max_objects ))
		matr.set_shader_param("hide", 0.0 )

	copyed.material_override = matr

	copyed.add_to_group( self.group_name )

func _process( delta:float ):
	var screen_viewport: = self.get_viewport( )
	if screen_viewport == null:
		return

	self.outline_viewport.size = screen_viewport.size
	self.outline_filter.rect_size = screen_viewport.size
	self.outline_draw.rect_size = screen_viewport.size
	#$Debug.rect_size = screen_viewport.size

	var src_camera: = screen_viewport.get_camera( )
	if src_camera == null or self.outline_camera == src_camera:
		return

	self.outline_camera.cull_mask = self.layers_for_draw_target
	self.outline_camera.global_transform = src_camera.global_transform
	self.outline_camera.set_perspective(src_camera.fov, src_camera.near, src_camera.far)
