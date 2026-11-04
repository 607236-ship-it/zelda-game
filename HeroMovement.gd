extends CharacterBody2D

const SPEED = 70
@onready var animated_sprite = $AnimatedSprite2D
@onready var sword_area = $SwordArea                 # Assign your Area2D child node here
@onready var sword_collision = $SwordArea/CollisionShape2D

enum State { MOVE, ATTACK }
var current_state: State = State.MOVE

var input_direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.DOWN 

func _ready() -> void:
	sword_area.body_entered.connect(_on_sword_hit)
	sword_collision.disabled = true # Turn off sword initially

func _get_input_direction() -> Vector2:
	var x = -int(Input.is_action_pressed("ui_left")) + int(Input.is_action_pressed("ui_right"))
	var y = -int(Input.is_action_pressed("ui_up")) + int(Input.is_action_pressed("ui_down"))
	return Vector2(x, y).normalized()

func _physics_process(_delta: float) -> void:
	match current_state:
		State.MOVE:
			_state_move()
		State.ATTACK:
			_state_attack()

func _state_move() -> void:
	input_direction = _get_input_direction()
	if input_direction != Vector2.ZERO:
		last_direction = input_direction
		
	velocity = input_direction * SPEED
	move_and_slide()
	_update_animation()

	if Input.is_action_just_pressed("ui_accept"): # Map spacebar/enter to swing
		_start_attack()

func _start_attack() -> void:
	current_state = State.ATTACK
	velocity = Vector2.ZERO # Stop moving when attacking
	
	# Reposition sword hitbox based on facing direction
	if abs(last_direction.x) > abs(last_direction.y):
		animated_sprite.play("attack_side")
		animated_sprite.flip_h = last_direction.x < 0
		sword_area.position = Vector2(12 if last_direction.x > 0 else -12, 0)
	else:
		animated_sprite.flip_h = false
		if last_direction.y > 0:
			animated_sprite.play("attack_down")
			sword_area.position = Vector2(0, 12)
		else:
			animated_sprite.play("attack_up")
			sword_area.position = Vector2(0, -12)

	sword_collision.disabled = false
	
	# Wait for standard attack animation length (e.g., 0.25 seconds) before returning to move state
	await get_tree().create_timer(0.25).timeout
	sword_collision.disabled = true
	current_state = State.MOVE

func _state_attack() -> void:
	pass # Handle hit pause frames if needed

func _update_animation() -> void:
	if input_direction == Vector2.ZERO:
		if abs(last_direction.x) > abs(last_direction.y):
			animated_sprite.play("idle_side")
			animated_sprite.flip_h = last_direction.x < 0
		else:
			animated_sprite.flip_h = false
			if last_direction.y > 0:
				animated_sprite.play("idle_down")
			else:
				animated_sprite.play("idle_up")
		return

	if abs(input_direction.x) > abs(input_direction.y):
		animated_sprite.play("walk_side")
		animated_sprite.flip_h = input_direction.x < 0
	else:
		animated_sprite.flip_h = false
		if input_direction.y > 0:
			animated_sprite.play("walk_down")
		else:
			animated_sprite.play("walk_up")

func _on_sword_hit(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(1)
