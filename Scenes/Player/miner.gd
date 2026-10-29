extends CharacterBody2D

const PROBE := 2.0   # pixels au-delà du bord du corps
const DIG_PARTICLES := preload("uid://dqcdtnt3m2aaa")
const SPEED = 100.0
const JUMP_VELOCITY = -200.0
var dig_progress: float = 0.0
var dig_target: Vector2i = Vector2i(-1, -1)
var facing: Vector2i = Vector2i(1, 0)
var score: int = 0
var damage: Dictionary[Vector2i, float] = {}
@export var dig_time: float = 1.0
@export var energy_cost: int = 5
@export var energy: int
@onready var body_shape: RectangleShape2D = $CollisionShape2D.shape
@onready var sprite: AnimatedSprite2D = %AnimatedSprite2D
@export var pikeaxe_power: float = 1.0


signal new_score(score: int)
signal energy_changed(energy: int)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	_update_facing()

	var target := _get_dig_target()

	if _is_mining_pressed() and _can_dig(target):
		velocity.x = facing.x * SPEED
		_dig(target, delta)
	else:
		_reset_dig()
		var direction := Input.get_axis("ui_left", "ui_right")
		velocity.x = direction * SPEED if direction else move_toward(velocity.x, 0, SPEED)
		_walk_animation()
	
	move_and_slide()

func _walk_animation() -> void:
	if velocity.x > 0:
		%AnimatedSprite2D.flip_h = false
		%AnimatedSprite2D.play("walk_right")
	elif velocity.x < 0:
		%AnimatedSprite2D.flip_h = true
		%AnimatedSprite2D.play("walk_right")
	else:
		%AnimatedSprite2D.play("default")

func _anim_length(anim: StringName) -> float:
	var frames := sprite.sprite_frames
	var total := 0.0
	for i in frames.get_frame_count(anim):
		total += frames.get_frame_duration(anim, i)
	return total / frames.get_animation_speed(anim)

func _mining_animation() -> void:
	var anim := &"mine_down" if facing.y == 1 else &"mine_right"
	if facing.y != 1:
		sprite.flip_h = facing.x < 0
	sprite.play(anim, _anim_length(anim) / dig_time)

func _update_facing() -> void:
	if Input.is_action_pressed("ui_down"):
		facing = Vector2i(0, 1)
	elif Input.is_action_pressed("ui_left"):
		facing = Vector2i(-1, 0)
	elif Input.is_action_pressed("ui_right"):
		facing = Vector2i(1, 0)

func _get_dig_target() -> Vector2i:
	var half := body_shape.size / 2.0
	# Point juste devant le bord du corps, dans la direction visée
	var probe = global_position + %CollisionShape2D.position \
		+ Vector2(facing) * (Vector2(half.x, half.y) + Vector2(PROBE, PROBE))
	return %Mine.local_to_map(%Mine.to_local(probe))

func _can_dig(cell: Vector2i) -> bool:
	if %Mine.get_cell_source_id(cell) == -1:
		return false
	if facing.x != 0:   # sur les côtés : il faut être collé au mur
		return is_on_wall() and signf(get_wall_normal().x) == -facing.x
	return is_on_floor()   # vers le bas : il faut être posé au sol

func _spawn_dig_particles(cell: Vector2i, color_ramp: Gradient) -> void:
	var fx := DIG_PARTICLES.instantiate()
	fx.global_position = %Mine.to_global(%Mine.map_to_local(cell))   # centre de la case
	fx.color_ramp = color_ramp
	get_parent().add_child(fx)   # ajouté au niveau, pas au joueur

func get_block(cell: Vector2i) -> BlockData:
	var data = %Ore.get_cell_tile_data(cell)
	if data == null:
		data = %Mine.get_cell_tile_data(cell)
	return data.get_custom_data("block") if data else null

## Returns true if the block broke.
func hit(cell: Vector2i) -> bool:
	var block := get_block(cell)
	if block == null:
		return false
	damage[cell] = damage.get(cell, 0.0) + pikeaxe_power
	if %PickaxeEffect.stream != block.hit_sound: %PickaxeEffect.stream = block.hit_sound
	%PickaxeEffect.play()
	if damage[cell] >= block.hardness:
		score += block.value
		new_score.emit(score)
		_spawn_dig_particles(cell, block.particle_color)
		damage.erase(cell)
		%Cracks.erase_cell(cell)
		%Mine.set_cells_terrain_connect([cell], 0, -1)
		%Ore.erase_cell(cell)
		return true
	_update_cracks(cell, damage[cell] / block.hardness)
	return false

const CRACK_STAGES := 4

func _update_cracks(cell: Vector2i, ratio: float) -> void:
	var stage := mini(int(ratio * CRACK_STAGES), CRACK_STAGES - 1)
	%Cracks.set_cell(cell, 0, Vector2i(stage, 0))

func _dig(target: Vector2i, delta: float) -> void:
	if target != dig_target:
		dig_target = target
		dig_progress = 0.0
		sprite.set_frame_and_progress(0, 0.0)
	_mining_animation()
	dig_progress += delta
	if dig_progress >= dig_time:
		hit(target)
		energy -= energy_cost
		energy_changed.emit(energy)
		_reset_dig()

func _reset_dig() -> void:
	dig_progress = 0.0
	dig_target = Vector2i(-1,-1)
	

func _is_mining_pressed() -> bool:
	return Input.is_action_pressed("ui_left") \
		or Input.is_action_pressed("ui_right") \
		or Input.is_action_pressed("ui_down")

func dead() -> void:
	%AnimatedSprite2D.play("dead")
