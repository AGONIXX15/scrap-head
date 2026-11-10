class_name Part extends Resource

const HEAD := "head"
const ARM := "arm"
const LEGS := "legs"
const BACK := "back"
const FRAME_SIZE := 32

@export var name: String
@export_enum("head", "arm", "legs", "back") var slot: String
@export var texture: Texture2D
@export var stats: Dictionary
@export var scene: PackedScene

func frames() -> int:
	return int(texture.get_width() / float(FRAME_SIZE))
