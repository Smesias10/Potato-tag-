# res://scripts/weapons/MythicSword.gd
class_name MythicSword
extends Arma

const MAX_HOLD_TIME: float = 20.0
const COOLDOWN_TIME: float = 10.0
const ATTACK_RANGE: float = 60.0

var current_hold_time: float = 0.0
var current_cooldown: float = 0.0
var is_equipped: bool = false
var is_on_cooldown: bool = false

var player: Node2D = null
var ui_manager: Node = null


func _ready() -> void:
	damage = 75
	attack_cooldown = 0.5
	add_to_group("pickups")  # ← para que Player._try_equip_nearby_weapon la detecte

	var uis := get_tree().get_nodes_in_group("ui_manager")
	if uis.size() > 0:
		ui_manager = uis[0]


func _process(delta: float) -> void:
	super._process(delta)   # cooldown de ataque del Arma base

	if is_on_cooldown and not is_equipped:
		current_cooldown -= delta
		if ui_manager and ui_manager.has_method("update_sword_cooldown"):
			ui_manager.update_sword_cooldown(current_cooldown)
		if current_cooldown <= 0.0:
			is_on_cooldown = false
			current_cooldown = 0.0
			if ui_manager and ui_manager.has_method("hide_sword_ui"):
				ui_manager.hide_sword_ui()
			print("Espada Mítica lista para recoger de nuevo.")

	if is_equipped and is_instance_valid(player):
		current_hold_time += delta
		var time_left := MAX_HOLD_TIME - current_hold_time
		if ui_manager and ui_manager.has_method("update_sword_timer"):
			ui_manager.update_sword_timer(time_left)
		if current_hold_time >= MAX_HOLD_TIME:
			detonate_explosion()


## Implementación del método abstracto de Arma.
func atacar() -> void:
	if not is_equipped:
		return
	if not puede_atacar():
		return
	_cooldown_timer = attack_cooldown
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		if enemy.global_position.distance_to(global_position) <= ATTACK_RANGE:
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage)


func detonate_explosion() -> void:
	print("¡BOOM! El jugador explota por retener la espada más de 20s.")
	if is_instance_valid(player) and player.has_method("take_damage"):
		player.take_damage(9999)
	drop()


func equip(p: Node2D) -> bool:
	if is_on_cooldown or is_equipped:
		return false
	player = p
	is_equipped = true
	current_hold_time = 0.0
	if ui_manager and ui_manager.has_method("show_sword_timer"):
		ui_manager.show_sword_timer()
	print("Mythic Sword equipada. 20 segundos antes de explotar.")
	return true


func drop() -> void:
	if not is_equipped:
		return
	is_equipped = false
	is_on_cooldown = true
	current_cooldown = COOLDOWN_TIME
	player = null
	if ui_manager and ui_manager.has_method("hide_sword_ui"):
		ui_manager.hide_sword_ui()
	print("Mythic Sword soltada. Cooldown de 10s.")
