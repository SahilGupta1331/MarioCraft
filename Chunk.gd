extends Node2D

var noise = preload("res://softnoise.gd")
var block = preload("res://blocks/Block.tscn")
var noise_seed = 0

enum block_type {
	DIRT, GRASS, STONE, BEDROCK
}

var world_depth = 64
var world_height = 64
var chunk_width = 32

func _ready():
	var softnoise = noise.SoftNoise.new(noise_seed)
	for x in range(0, chunk_width):
		var y = floor(softnoise.openSimplex2D((global_position.x/16+x)*.1,0)*world_height*.2)
		var stone_y = floor(softnoise.openSimplex2D((global_position.x/16+x)*.1,32)*4)
		var bedrock_y = floor(softnoise.openSimplex2D((global_position.x/16+x)*.5,64))
		new_block(Vector2(x*16,y*16),block_type.GRASS)
		for yy in range(y+1, world_depth+bedrock_y):
			if yy > world_depth*.25+stone_y:
				new_block(Vector2(x*16,yy*16),block_type.STONE)
			else:
				new_block(Vector2(x*16,yy*16),block_type.DIRT)
		new_block(Vector2(x*16, (world_depth+bedrock_y)*16),block_type.BEDROCK)

func new_block(pos,type):
	var new_block = block.instance()
	new_block.position = pos
	new_block.block_type = type
	add_child(new_block)
