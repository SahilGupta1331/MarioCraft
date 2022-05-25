extends Node2D

var chunk = preload("res://Chunk.tscn")
var noise_seed
var chunk_extexts = range(0)

func _ready():
	randomize()
	noise_seed = randi()
	$Chunk.noise_seed = noise_seed
	$Chunk2.noise_seed = noise_seed

func _process(delta):
	randomize()
	get_chunk()
	hide_chunk()
	if  chunk_extexts.back() < $Player.position.x+256:
		var Chunk = chunk.instance()
		add_child(Chunk)
		Chunk.global_position = Vector2(chunk_extexts.back(),0)
		Chunk.noise_seed = noise_seed
	if  chunk_extexts.front() > $Player.position.x-256:
		var Chunk = chunk.instance()
		add_child_below_node($Player, Chunk)
		Chunk.global_position = Vector2(chunk_extexts.front()-512,0)
		Chunk.noise_seed = noise_seed
	$sound.volume_db = rand_range(-30,-10)

func get_chunk():
	chunk_extexts = range(get_tree().get_nodes_in_group('chunks').front().global_position.x, get_tree().get_nodes_in_group('chunks').back().global_position.x+512)

func hide_chunk():
	for node in get_tree().get_nodes_in_group('chunks'):
		if $Player.global_position.x+128 > node.global_position.x and $Player.global_position.x-128 < node.global_position.x+512:
			node.visible = true
		else:
			node.visible = false
