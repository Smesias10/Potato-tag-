extends CharacterBody2D

@export var speed: float = 200.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input * speed
	move_and_slide()
	_update_animation(input)

func _update_animation(input: Vector2) -> void:
	if input.length() > 0.1:
		anim.play("walk")
	else:
		anim.play("idle")
