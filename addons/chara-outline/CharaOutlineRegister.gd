extends Node

#
# キャラクタアウトライン by あるる（きのもと 結衣） @arlez80
# Character Outline by Yui Kinomoto @arlez80
#
# MIT License
#

class_name CharaOutlineRegister, "register_icon.png"

export(bool) var hide:bool = false
export(int, 0, 255) var object_id:int = 0
export(NodePath) var target_path:NodePath = ".."
