
extends CharacterBody2D

signal died(enemy: Node)

@export var speed: float = 100.0
@export var max_health: int = 30
@export var damage: int = 10
@export var attack_range: float = 28.0
@export var attack_cooldown: float = 1.0

var health: int
var attack_timer: float = 0.0
var player: Node2D = null
var is_dead: bool = false


func _ready() -> void:
	health = max_health
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player") as Node2D


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node2D

	if not is_instance_valid(player):
		velocity = Vector2.ZERO
		move_and_slide()
		return

	attack_timer = maxf(0.0, attack_timer - delta)

	var distance = global_position.distance_to(
		player.global_position
	)

	if distance > attack_range:
		var direction = global_position.direction_to(
			player.global_position
		)
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO

		if attack_timer <= 0.0:
			attack_player()

	move_and_slide()


func attack_player() -> void:
	attack_timer = attack_cooldown

	if is_instance_valid(player) and player.has_method("take_damage"):
		player.take_damage(damage)


func take_damage(amount: int) -> void:
	if is_dead:
		return

	health -= amount

	if health <= 0:
		is_dead = true
		died.emit(self)
		queue_free()
