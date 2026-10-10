extends CharacterBody2D

const SPEED = 300.0
@onready var area_ataque = $AreaAtaque

func _ready():
	# Desactivamos el área de ataque al inicio
	area_ataque.monitoring = false

func _physics_process(_delta):
	# Movimiento WASD
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_dir * SPEED
	move_and_slide()

	# Ataque con Barra Espaciadora o Clic Izquierdo
	if Input.is_action_just_pressed("ui_accept"):
		atacar()

func atacar():
	print("¡Ataque ejecutado!")
	area_ataque.monitoring = true
	
	# Detectar enemigos atrapados en el área
	var cuerpos = area_ataque.get_overlapping_bodies()
	for cuerpo in cuerpos:
		if cuerpo.has_method("recibir_danio"):
			cuerpo.recibir_danio(10)
			
	# Esperar 0.2 segundos y desactivar el área
	await get_tree().create_timer(0.2).timeout
	area_ataque.monitoring = false
