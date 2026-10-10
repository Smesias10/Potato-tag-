extends Node

signal room_cleared(room_number: int)

@export_range(1, 3) var room_number: int = 1
@export var enemy_scene: PackedScene
@export var boss_scene: PackedScene

@export var spawn_points_path: NodePath = ^"../SpawnPoints"
@export var enemies_path: NodePath = ^"../Enemies"

@export var wave_sizes: Array[int] = [3, 5]

@onready var spawn_points: Node2D = get_node_or_null(spawn_points_path)
@onready var enemies_container: Node2D = get_node_or_null(enemies_path)

var wave_index: int = 0
var alive_enemies: int = 0
var boss_spawned: bool = false
var finished: bool = false


func _ready() -> void:
	if enemy_scene == null:
		push_error("WaveManager: falta asignar enemy_scene.")
		return

	if spawn_points == null:
		push_error("WaveManager: spawn_points es null. Revisa spawn_points_path. Esperado: ../SpawnPoints")
		return

	if enemies_container == null:
		push_error("WaveManager: enemies_container es null. Revisa enemies_path. Esperado: ../Enemies")
		return

	if spawn_points.get_child_count() == 0:
		push_error("WaveManager: agrega Marker2D a SpawnPoints.")
		return

	start_waves()


func start_waves() -> void:
	await get_tree().create_timer(1.0).timeout
	spawn_wave()


func spawn_wave() -> void:
	if finished:
		return

	if wave_index >= wave_sizes.size():
		if room_number == 3 and boss_scene != null:
			spawn_boss()
		else:
			finish_room()
		return

	var amount: int = wave_sizes[wave_index]
	amount += (room_number - 1) * 2

	for i in range(amount):
		spawn_enemy()

	print("Habitación ", room_number,
		" - Oleada ", wave_index + 1,
		" - Enemigos: ", amount)


func spawn_enemy() -> void:
	var enemy = enemy_scene.instantiate()

	if not enemy.has_signal("died"):
		push_error("Enemy debe tener la señal died.")
		enemy.queue_free()
		return

	enemies_container.add_child(enemy)

	var points = spawn_points.get_children()
	var marker = points[randi_range(0, points.size() - 1)]

	enemy.global_position = marker.global_position
	enemy.died.connect(_on_enemy_died)

	alive_enemies += 1


func _on_enemy_died(_enemy: Node) -> void:
	alive_enemies -= 1

	if alive_enemies <= 0:
		alive_enemies = 0
		call_deferred("_advance_wave")


func _advance_wave() -> void:
	if finished or alive_enemies > 0:
		return

	if boss_spawned:
		finish_room()
		return

	wave_index += 1
	await get_tree().create_timer(1.5).timeout
	spawn_wave()


func spawn_boss() -> void:
	if boss_scene == null:
		finish_room()
		return

	boss_spawned = true
	var boss = boss_scene.instantiate()

	if not boss.has_signal("died"):
		push_error("El jefe debe emitir la señal died.")
		boss.queue_free()
		return

	enemies_container.add_child(boss)
	boss.global_position = spawn_points.get_child(0).global_position
	boss.died.connect(_on_boss_died)

	alive_enemies = 1
	print("¡JEFE FINAL!")


func _on_boss_died(_boss: Node) -> void:
	alive_enemies = 0
	finish_room()


func finish_room() -> void:
	if finished:
		return

	finished = true
	print("Habitación ", room_number, " completada.")
	room_cleared.emit(room_number)
