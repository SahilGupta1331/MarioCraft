extends StaticBody2D

onready var coords = self.global_position

var block_sprites = [
	preload("res://blocks/dirt.png"),
	preload("res://blocks/grass.png"),
	preload("res://blocks/stone.png"),
	preload("res://blocks/bedrock.png")
	]
var block_type
var cursed = false

func _ready():
	get_node("Sprite").texture = block_sprites[block_type]

func _process(delta):
	if cursed:
		cursed = false
		modulate = Color(2,2,2,1)
	else:
		modulate = Color(1,1,1,1)
