extends KinematicBody2D

export var ACC = 100
export var MAXSPEED = 10000
export var FRIC = 100
export var MAXJUMP = 80
var vel = Vector2.ZERO
var jumping = false
var flying = false
var dir = Vector2.DOWN
var item = 0
var tap_count = 0 

func sprite():
	if dir.x > 0:
		$AnimatedSprite.flip_h = false
	elif dir.x < 0:
		$AnimatedSprite.flip_h = true

func move(delta):
	if dir.x != 0:
		$AnimatedSprite.animation = 'run'
		vel.x += dir.x*ACC*delta
		vel.x = vel.clamped(MAXSPEED*delta).x
	else:
		$AnimatedSprite.animation = 'idle'
		vel.x = vel.move_toward(Vector2.ZERO, FRIC*delta).x
	if jumping:
		if vel.y <= -MAXJUMP:
			vel.y = -MAXJUMP
			jumping = false
		if is_on_ceiling():
			jumping = false
		dir.y = -1
	elif flying:
		dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		if Input.is_action_just_pressed("ui_accept"):
			flying = false
	else:
		dir.y = 1
		if tap_count < 10 and tap_count > 0 and Input.is_action_just_pressed("ui_accept"):
			dir = Vector2.ZERO
			flying = true
			tap_count = 0
	if !is_on_floor() and !flying:
		$AnimatedSprite.animation = 'jump'
	vel.y += dir.y*(ACC*2)*delta
	vel=move_and_slide(vel, Vector2.UP)

func _process(delta):
	$RayCast2D.look_at(get_global_mouse_position())
	if $RayCast2D.is_colliding():
		if $RayCast2D.get_collider() != null:
			$RayCast2D.get_collider().set('cursed', true)
		if Input.is_action_just_pressed("place_block"):
			if item > 1:
				$sound.stream = preload("res://blocks/stone.ogg")
			else:
				$sound.stream = preload("res://blocks/grass.ogg")
			$sound.play()
			var block_coords = $RayCast2D.get_collider().get('coords')
			var place_block_coords = Vector2.ZERO
			if $RayCast2D.get_collision_point().y == block_coords.y-8:
				place_block_coords = block_coords - Vector2(0,16)
			elif $RayCast2D.get_collision_point().y == block_coords.y+8:
				place_block_coords = block_coords + Vector2(0,16)
			elif $RayCast2D.get_collision_point().x == block_coords.x-8:
				place_block_coords = block_coords - Vector2(16,0)
			elif $RayCast2D.get_collision_point().x == block_coords.x+8:
				place_block_coords = block_coords + Vector2(16,0)
			var block = preload("res://blocks/Block.tscn").instance()
			block.block_type = item
			block.global_position = place_block_coords
			get_parent().add_child(block)
		elif Input.is_action_just_pressed("remove_block"):
			if $RayCast2D.get_collider().get('block_type') > 1:
				$sound.stream = preload("res://blocks/stone.ogg")
			else:
				$sound.stream = preload("res://blocks/grass.ogg")
			$sound.play()
			
			$RayCast2D.get_collider().call('queue_free')
			return
	$CanvasLayer/Coordinates.text = str((global_position/16).floor())
	dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if Input.is_action_just_pressed("ui_accept"):
		tap_count += 1
		if is_on_floor():
			jumping = true
	if Input.is_action_just_released("ui_accept"):
		if jumping:
			if vel.y >=-100:
				vel.y = -100
			jumping = false
	sprite()
	move(delta)

func _input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				BUTTON_WHEEL_UP:
					item += 1
				BUTTON_WHEEL_DOWN:
					item -= 1
		if item < 0:
			item = 3
		elif item > 3:
			item = 0
		$CanvasLayer/box_selected.global_position.x = 35 + (20*item)
