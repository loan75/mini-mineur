extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -200.0
var mining_action: bool = false
var dig_time: float = 1.0
var dig_progress: float = 0.0
var dig_target: Vector2i = Vector2i(-1, -1)
var facing: Vector2i = Vector2i(-1, -1)
var gold: Vector2i = Vector2i(3, 0)
var score: int = 0
@export var energy_cost: int = 5
@export var energy: int

signal new_score(score: int)
signal energy_changed(energy: int)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	_walk_animation()
	_pikeaxe_interaction()
	if mining_action:
		_mining_action(delta)
	
	move_and_slide()

func _walk_animation() -> void:
	if not mining_action:
		if velocity.x > 0:
			%AnimatedSprite2D.flip_h = false
			%AnimatedSprite2D.play("walk_right")
		elif velocity.x < 0:
			%AnimatedSprite2D.flip_h = true
			%AnimatedSprite2D.play("walk_right")
		else:
			%AnimatedSprite2D.play("default")

func _mining_animation() -> void:
	if mining_action and _is_mining_pressed():
		if Input.is_action_pressed("ui_right"):
			%AnimatedSprite2D.flip_h = false
			%AnimatedSprite2D.play("mine_right")
			facing = Vector2i(1,0)
		elif Input.is_action_pressed("ui_left"):
			%AnimatedSprite2D.flip_h = true
			%AnimatedSprite2D.play("mine_right")
			facing = Vector2i(-1,0)
		elif Input.is_action_pressed("ui_down"):
			%AnimatedSprite2D.play("mine_down")
			facing = Vector2i(0,1)
	else:
		%AnimatedSprite2D.play("default")

func _pikeaxe_interaction() -> void:
	if Input.is_action_just_pressed("ui_down"):
		$PickaxeHitbox.position = Vector2(0,6)
	elif Input.is_action_just_pressed("ui_left"):
		$PickaxeHitbox.position = Vector2(-4,0)
	elif Input.is_action_just_pressed("ui_right"):
		$PickaxeHitbox.position = Vector2(+4,0)

func _mining_action(delta) -> void:
	if not _is_mining_pressed():
		_mining_animation()
		_reset_dig()
		return
	if not %PickaxeEffect.playing:
		%PickaxeEffect.play()
	_mining_animation()
	
	var target = %Mine.local_to_map(%Mine.to_local(global_position)) + facing
	var ore_target = %Ore.local_to_map(%Ore.to_local(global_position)) + facing

	if %Mine.get_cell_source_id(target) == -1:
		_reset_dig()
		return

	# Changed target while holding: start again
	if target != dig_target:
		dig_target = target
		dig_progress = 0.0

	dig_progress += delta
	# dig_progress / DIG_TIME goes from 0 to 1: use it for a progress bar or cracks

	if dig_progress >= dig_time:
		if %Ore.get_cell_atlas_coords(ore_target) == gold:
			score += 1
			new_score.emit(score)
			%CPUParticles2D.emitting = true
		energy -= energy_cost
		energy_changed.emit(energy)
		%Mine.set_cells_terrain_connect([target], 0, -1)   # remove the block
		%Ore.erase_cell(ore_target)
		_reset_dig()

func _reset_dig() -> void:
	dig_progress = 0.0
	dig_target = Vector2i(-1,-1)
	%PickaxeEffect.stop()
	

func _is_mining_pressed() -> bool:
	return Input.is_action_pressed("ui_left") \
		or Input.is_action_pressed("ui_right") \
		or Input.is_action_pressed("ui_down")

func _on_pickaxe_hitbox_body_entered(body: Node2D) -> void:
	mining_action = true

func _on_pickaxe_hitbox_body_exited(body: Node2D) -> void:
	mining_action = false
	_reset_dig()

func dead() -> void:
	mining_action = false
	%AnimatedSprite2D.play("dead")
