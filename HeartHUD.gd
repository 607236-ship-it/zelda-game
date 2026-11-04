extends HBoxContainer

# Add custom textures inside Inspector panel
@export var heart_full: Texture2D
@export var heart_half: Texture2D
@export var heart_empty: Texture2D

func _ready() -> void:
	GameManager.player_health_changed.connect(update_hearts)
	update_hearts(GameManager.current_health, GameManager.max_health)

func update_hearts(current: int, max_h: int) -> void:
	# Clear out old heart textures
	for child in get_children():
		child.queue_free()
		
	var total_hearts = max_h / 2
	
	for i in range(total_hearts):
		var heart_rect = TextureRect.new()
		heart_rect.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		
		# Math to check if heart element is full, half, or empty
		if current >= (i + 1) * 2:
			heart_rect.texture = heart_full
		elif current == (i * 2) + 1:
			heart_rect.texture = heart_half
		else:
			heart_rect.texture = heart_empty
			
		add_child(heart_rect)
