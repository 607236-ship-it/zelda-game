extends CharacterBody2D

@export var SPEED: float = 40.0
@export var HEALTH: int = 2

@onready var hitbox: Area2D = $Hitbox

var player: CharacterBody2D = null
var knockback_velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	# Find player node in the scene tree automatically
	player = get_tree().get_first_node_in_group("Player") 

func _physics_process(delta: float) -> void:
	# Decay knockback force over time
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 300 * delta)
	
	if knockback_velocity != Vector2.ZERO:
		velocity = knockback_velocity
	elif player:
		# Simple vector tracking AI
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()

func take_damage(amount: int) -> void:
	HEALTH -= amount
	if player:
		# Push enemy back directly away from player
		var knockback_dir = (global_position - player.global_position).normalized()
		knockback_velocity = knockback_dir * 150.0
		
	if HEALTH <= 0:
		queue_free() # Destroy enemy

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Hero" or body.is_in_group("Player"):
		GameManager.damage_player(1) # Deals half a heart
