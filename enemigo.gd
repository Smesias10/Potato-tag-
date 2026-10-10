extends CharacterBody2D

const VELOCIDAD = 100.0
var vida = 20
var jugador: CharacterBody2D = null

func _ready():
	# Buscar al jugador en la escena por su nombre
	jugador = get_tree().current_scene.get_node_or_null("Asmodeus")

func _physics_process(_delta):
	if jugador:
		# Calcular dirección hacia el jugador
		var direccion = (jugador.global_position - global_position).normalized()
		velocity = direccion * VELOCIDAD
		move_and_slide()

func recibir_danio(cantidad):
	vida -= cantidad
	print("Enemigo recibió daño. Vida restante: ", vida)
	
	# Efecto visual de parpadeo
	modulate = Color(0.5, 0, 0)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
	
	if vida <= 0:
		die()

func die():
	print("¡Enemigo derrotado!")
	queue_free()
