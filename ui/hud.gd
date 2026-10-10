extends Control

# Referencias a nuestros nodos visuales
@onready var barra_vida = $CanvasLayer/BarraVida
@onready var label_tiempo = $CanvasLayer/LabelTiempo

# Variables del juego
var tiempo_restante: float = 20.0
var el_tiempo_corre: bool = false

func _ready():
	# Configuración inicial al cargar la escena
	barra_vida.value = 100
	# Para probarlo ahora mismo, encendemos el cronómetro
	el_tiempo_corre = true 

func _process(delta):
	# Si el cronómetro está activo y aún queda tiempo
	if el_tiempo_corre and tiempo_restante > 0:
		# Restamos el tiempo que pasó desde el último frame
		tiempo_restante -= delta 
		
		# Actualizamos el texto en pantalla (mostrando 1 decimal)
		label_tiempo.text = str("%.1f" % tiempo_restante)
		
		# ¿Qué pasa cuando el tiempo llega a cero?
		if tiempo_restante <= 0:
			tiempo_restante = 0
			el_tiempo_corre = false
			label_tiempo.text = "0.0"
			print("¡Se acabó el tiempo de la espada!")
			# Más adelante aquí conectaremos la lógica de Game Over

# Esta función la usaremos después desde el jugador para bajarle vida
func actualizar_vida(nueva_vida):
	barra_vida.value = nueva_vida
