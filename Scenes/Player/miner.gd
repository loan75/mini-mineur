extends CharacterBody2D

const PROBE := 2.0   # pixels au-delà du bord du corps
const DIG_PARTICLES := preload("uid://dqcdtnt3m2aaa")
const SPEED = 100.0
const JUMP_VELOCITY = -200.0
const gold: Vector2i = Vector2i(3, 0)
var dig_time: float = 1.0
var dig_progress: float = 0.0
var dig_target: Vector2i = Vector2i(-1, -1)
var facing: Vector2i = Vector2i(1, 0)
var score: int = 0
@export var energy_cost: int = 5
@export var energy: int
@onready var body_shape: RectangleShape2D = $CollisionShape2D.shape

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

func _mining_animation() -> void:
	if facing.y == 1:
		%AnimatedSprite2D.play("mine_down")
	else:
		%AnimatedSprite2D.flip_h = facing.x < 0
		%AnimatedSprite2D.play("mine_right")

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

func _spawn_dig_particles(cell: Vector2i) -> void:
	var fx := DIG_PARTICLES.instantiate()
	fx.global_position = %Mine.to_global(%Mine.map_to_local(cell))   # centre de la case
	get_parent().add_child(fx)   # ajouté au niveau, pas au joueur

func _dig(target: Vector2i, delta: float) -> void:
	_mining_animation()
	if not %PickaxeEffect.playing:
		%PickaxeEffect.play()
	if target != dig_target:
		dig_target = target
		dig_progress = 0.0
	dig_progress += delta
	if dig_progress >= dig_time:
		if %Ore.get_cell_atlas_coords(target) == gold:
			score += 1
			new_score.emit(score)
			_spawn_dig_particles(target)
		energy -= energy_cost
		energy_changed.emit(energy)
		%Mine.set_cells_terrain_connect([target], 0, -1)   # remove the block
		%Ore.erase_cell(target)
		_reset_dig()

func _reset_dig() -> void:
	dig_progress = 0.0
	dig_target = Vector2i(-1,-1)
	%PickaxeEffect.stop()
	

func _is_mining_pressed() -> bool:
	return Input.is_action_pressed("ui_left") \
		or Input.is_action_pressed("ui_right") \
		or Input.is_action_pressed("ui_down")

func dead() -> void:
	%AnimatedSprite2D.play("dead")
