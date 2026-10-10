extends Node2D

@onready var tile_map = $TileMap

func _ready():
	generar_matriz_base()

func generar_matriz_base():
	var tamano = 100
	
	for x in range(tamano):
		for y in range(tamano):
			# Coloca el bloque de Godot en cada celda
			tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
