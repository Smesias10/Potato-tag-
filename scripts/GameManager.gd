
extends Node

@export var room_scene: PackedScene

@export var player_path: NodePath = ^"../Player"
@export var current_room_path: NodePath = ^"../CurrentRoom"

@onready var player: Node2D = get_node_or_null(player_path) as Node2D
@onready var current_room: Node2D = get_node_or_null(current_room_path) as Node2D

var current_room_number: int = 0
var changing_room: bool = false


func _ready() -> void:
	if room_scene == null:
		push_error("GameManager: asigna Room.tscn.")
		return

	if player == null:
		push_error("GameManager: no se encontró Player.")
		return

	if current_room == null:
		push_error("GameManager: no se encontró CurrentRoom.")
		return

	call_deferred("load_room", 1)


func load_room(room_number: int) -> void:
	if changing_room:
		return

	if room_number < 1 or room_number > 3:
		push_error("GameManager: número de habitación inválido.")
		return

	changing_room = true
	current_room_number = room_number

	var room = room_scene.instantiate()

	var wave_manager = room.get_node_or_null("WaveManager")
	var spawn_points = room.get_node_or_null("SpawnPoints") as Node2D

	if wave_manager == null or not wave_manager.has_signal("room_cleared"):
		push_error("Room debe contener un WaveManager válido.")
		room.free()
		changing_room = false
		return

	if spawn_points == null or spawn_points.get_child_count() == 0:
		push_error("Room necesita SpawnPoints con al menos un Marker2D.")
		room.free()
		changing_room = false
		return

	# Configurar la habitación antes de incorporarla al árbol.
	wave_manager.set("room_number", room_number)
	wave_manager.connect(
		"room_cleared",
		_on_room_cleared
	)

	# Retirar la habitación anterior.
	for child in current_room.get_children():
		current_room.remove_child(child)
		child.queue_free()

	# Añadir la nueva habitación.
	current_room.add_child(room)

	# Colocar al jugador en el primer punto de aparición.
	player.global_position = spawn_points.get_child(0).global_position

	changing_room = false
	print("Entrando a la habitación ", room_number)


func _on_room_cleared(room_number: int) -> void:
	if room_number != current_room_number:
		return

	if room_number < 3:
		load_room(room_number + 1)
	else:
		print("¡POTATO TAG completado!")
		print("El jefe final ha sido derrotado.")
