extends Control
class_name Interface

@export_group("Lune")
@onready var europe1 = get_parent().get_node("node_3d/Europe1")
@onready var europe2 = get_parent().get_node("node_3d/Europe2")
@onready var jupiter = get_parent().get_node("node_3d/Jupiter")

@export var label_plus_proche : Label
@export var distance : Label
@export var slider_temps : HSlider



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	slider_temps.value_changed.connect(_on_slider_changed)

func _on_slider_changed(valeur: float)-> void:
	Engine.time_scale = valeur
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not europe1 or not europe2 or not jupiter:
		return
	var d1 = (europe1.r_i - jupiter.r_i).length()
	var d2 = (europe2.r_i - jupiter.r_i).length()

	if d1 < d2 :
		label_plus_proche.text = "Point 1 plus proche"
	else:
		label_plus_proche.text = "Point 2 plus proche"
	
	var dist = (europe1.r_i - europe2.r_i).length()
	distance.text = "Distance: " + format_scientifique(dist)
	
func format_scientifique(valeur : float) -> String:
	"""Converti en format scientifique les nombres décimaux avec 3 décimales
	
	Parametre:
	valeur -- la valeur à afficher de façon scientifique
	
	Retour:
	une chaîne de caractères représentant ce nombre
	"""
	if valeur == 0:
		return "0"
	var nombre_decimales = int(log(valeur) / log(10))
	var nombre_presente = valeur / 10**nombre_decimales
	return "%.3f" % nombre_presente + "e" + "%s" % nombre_decimales
