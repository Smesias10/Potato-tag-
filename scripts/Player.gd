# res://scripts/Player.gd
extends CharacterBody2D

signal health_changed(current: float, max_health: float)
signal died

@export var speed: float = 220.0
@export var max_health: float = 300.0

# ⚠️ PÚBLICA y tipo float — HealingHallway la modifica directamente.
var health: float = 300.0
var is_dead: bool = false

# Arma actual equipada.
var current_weapon: Node2D = null

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var weapon_holder: Node2D = $WeaponHolder


func _ready() -> void:
	add_to_group("player")   # ← CRÍTICO: enemigos, espada y pasillo lo buscan así.
	health = max_health
	health_changed.emit(health, max_health)

	if weapon_holder.get_child_count() > 0:
		current_weapon = weapon_holder.get_child(0)


func _physics_process(_delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# ─── Movimiento 2D (WASD + flechas) ───
	var dir := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	if dir.length() > 1.0:
		dir = dir.normalized()

	velocity = dir * speed
	move_and_slide()

	# ─── Animaciones ───
	_update_animation(dir)

	# ─── Rotar el arma hacia donde mira el jugador ───
	if dir != Vector2.ZERO:
		weapon_holder.rotation = dir.angle()

	# ─── Ataque ───
	if Input.is_action_just_pressed("attack") and current_weapon:
		if current_weapon.has_method("atacar"):
			current_weapon.atacar()

	# ─── Interactuar (equipar la espada mítica) ───
	if Input.is_action_just_pressed("interact"):
		_try_equip_nearby_weapon()


func _update_animation(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		if sprite.animation != "idle":
			sprite.play("idle")
	else:
		if sprite.animation != "walk":
			sprite.play("walk")
		if absf(dir.x) > 0.01:
			sprite.flip_h = dir.x < 0


# ═══════════════════════════════════════════
# SISTEMA DE VIDA Y DAÑO
# ═══════════════════════════════════════════

func take_damage(amount: int) -> void:
	if is_dead:
		return
	health = maxf(0.0, health - float(amount))
	health_changed.emit(health, max_health)
	_flash_hit()
	if health <= 0.0:
		_die()


func heal(amount: float) -> void:
	if is_dead:
		return
	health = minf(max_health, health + amount)
	health_changed.emit(health, max_health)


func _flash_hit() -> void:
	sprite.modulate = Color(1.0, 0.35, 0.35)
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)


func _die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("hit"):
		sprite.play("hit")
	died.emit()


# ═══════════════════════════════════════════
# SISTEMA DE ARMAS
# ═══════════════════════════════════════════

func equip_weapon(new_weapon: Node2D) -> void:
	if current_weapon and current_weapon.get_parent() == weapon_holder:
		current_weapon.queue_free()
	current_weapon = new_weapon
	if new_weapon.get_parent() != weapon_holder:
		new_weapon.reparent(weapon_holder, false)
	new_weapon.position = Vector2(20, 0)
	new_weapon.rotation = 0


## Busca un arma en el grupo "pickups" cerca y la equipa.
func _try_equip_nearby_weapon() -> void:
	var pickups := get_tree().get_nodes_in_group("pickups")
	for pickup in pickups:
		if not is_instance_valid(pickup):
			continue
		if not pickup.has_method("equip"):
			continue
		if pickup.global_position.distance_to(global_position) <= 60.0:
			if pickup.equip(self):
				pickup.reparent(weapon_holder, false)
				pickup.position = Vector2(20, 0)
				pickup.rotation = 0
				current_weapon = pickup
				return
