extends Node

@export var room_scene: PackedScene

@export var player_path: NodePath = ^"../Player"
@export var current_room_path: NodePath = ^"../CurrentRoom"

@onready var player: Node2D = get_node(player_path)
@onready var current_room: Node2D = get_node(current_room_path)

var current_room_number: int = 0


func _ready() -> void:
	if room_scene == null:
		push_error("GameManager: asigna Room.tscn en el Inspector.")
		return

	if current_room == null:
		push_error("GameManager: current_room es null. Revisa current_room_path.")
		return

	if player == null:
		push_error("GameManager: player es null. Revisa player_path.")
		return

	# Espera un frame para que todo esté montado
	await get_tree().process_frame
	load_room(1)


func load_room(room_number: int) -> void:
	current_room_number = room_number

	# 1. Limpiar cuarto anterior
	for child in current_room.get_children():
		child.queue_free()

	# 2. Instanciar el nuevo cuarto
	var room = room_scene.instantiate()

	# 3. Añadirlo PRIMERO al árbol (clave)
	current_room.add_child(room)

	# 4. Esperar un frame para que sus nodos estén listos
	await get_tree().process_frame

	# 5. AHORA sí, acceder a los nodos internos
	var wave_manager = room.get_node_or_null("WaveManager")
	if wave_manager == null:
		push_error("GameManager: no se encontró 'WaveManager' dentro del cuarto.")
		return

	wave_manager.room_number = room_number
	wave_manager.room_cleared.connect(_on_room_cleared)

	# 6. Reposicionar al jugador
	var spawn_points = room.get_node_or_null("SpawnPoints")
	if spawn_points != null and spawn_points.get_child_count() > 0:
		player.global_position = spawn_points.get_child(0).global_position
	else:
		push_warning("GameManager: no se encontró SpawnPoints o está vacío.")

	print("Entrando a la habitación ", room_number)


func _on_room_cleared(room_number: int) -> void:
	if room_number < 3:
		load_room(room_number + 1)
	else:
		print("¡POTATO TAG completado!")
		print("El jefe final ha sido derrotado.")
