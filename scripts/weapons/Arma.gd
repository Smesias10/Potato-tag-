# res://scripts/weapons/Arma.gd
class_name Arma
extends Node2D

## Clase base abstracta de todas las armas del juego.
## NO se debe instanciar directamente. Cada arma concreta debe:
##   1. Heredar con "extends Arma"
##   2. Sobrescribir el método atacar()

@export var damage: int = 10
@export var attack_cooldown: float = 0.5

var _cooldown_timer: float = 0.0

func _process(delta: float) -> void:
	if _cooldown_timer > 0.0:
		_cooldown_timer = maxf(0.0, _cooldown_timer - delta)

## Devuelve true si el arma puede atacar (cooldown terminado).
func puede_atacar() -> bool:
	return _cooldown_timer <= 0.0

## MÉTODO ABSTRACTO — cada arma debe implementarlo.
func atacar() -> void:
	push_error("Arma.atacar() es abstracto. Sobrescríbelo en la subclase.")
