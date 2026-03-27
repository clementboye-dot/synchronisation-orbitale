#Simule la révolution des lunes autour de Jupiter
extends Node3D
class_name Astre

@export var centre_rotation : RigidBody3D
@export var autre_point : RigidBody3D
@export var periode_relative : float

@export_group("Paramètre de conversion simulation")
@export var min_distance_simulee : float
@export var max_distance_simulee : float
@export var min_distance_reelle : float
@export var max_distance_reelle : float

@export_group("Simulation gravitationnelle")
@export var masse : float
@export var masse_jupiter : float
@export var rayon_initial : float
@export var vitesse_initiale : float


@export_group("Paramètres de la méthode d'Euler")
@export var etapes_calcul_par_ecran : int

#---CONSTANTES---#
var G : float = 6.673e-11
var R_p : float = 664862000 #((m)
var V_p : float = 14.193e3 #(m/s)
var K : float = 1e14 #(N/m)
var D : float = 24.97e6 #(m)
var Zeta : float = 4e16 #(N⋅s/m)

var r_i : Vector3 
var v_i : Vector3

var periode : float



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#---POSITION INITIALE---#
	r_i = rayon_initial * Vector3(1, 0, 0)
	
	position = conv_position_reelle_a_simulee(r_i)
	
	#---VITESSE INITIALE---#
	print(vitesse_initiale)
	v_i = vitesse_initiale * Vector3(0, 0, 1)
	
	periode = 2 * PI * r_i.length() / v_i.length()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	appliquer_euler(delta)
	position = conv_position_reelle_a_simulee(r_i)
	if centre_rotation != null:
		position += centre_rotation.position

func acceleration_totale() -> Vector3:
	"""Calcule et retourne l'accélération instantannée du point de la lune Europe à l'aide de la 2e loi 
	de Newton et des forces subies par le point de la lune, soit la force gravitationnelle, la force de friction
	entre les 2 points et la force de rappel due à l'élasticité de la lune
	"""
	var newton = force_gravitationnelle(r_i) + force_friction(v_i) + force_elastique(r_i)
	var acceleration = newton / masse
	return acceleration 

func force_gravitationnelle(position_reelle : Vector3) -> Vector3:
	"""Calcule la force gravitationnelle excercée sur le point d'Europe par Jupiter
	
	Paramètre:
	position_reelle --  position du point de la lune Europe par rapport à Jupiter
	
	Retour:
	La force gravitationnelle de Jupiter sur le point de la lune Europe.
	"""
	var force_g = -1 * G * masse * masse_jupiter  / (position_reelle.length()**3)
	force_g = force_g * position_reelle
	return force_g

func force_elastique(position_reelle : Vector3) -> Vector3:
	"""Calcule la force de ressort entre les 2 points de la lune Europe
	
	Paramètre:
	position_reelle -- position du point de la lune Europe par rapport à Jupiter
	
	Retour:
	La force de rappel subie par le point de la lune.
	"""
	var position_relative = autre_point.r_i - position_reelle
	var ressort = K * (position_relative.length() - D) * position_relative.normalized()
	return ressort

func force_friction( vitesse_lune : Vector3) -> Vector3:
	"""Calcule la force de friction instantannée.
	Paramètre :
	vitesse_lune -- vitesse instantannée du point de la lune Europe
		
	Retour:
	La force de friction sur le point de la lune Europe.
	"""
	var vitesse_relative = autre_point.v_i - vitesse_lune
	var friction = Zeta * vitesse_relative 
	return friction

func appliquer_euler(temps_dernier_ecran : float) -> void:
	"""Applique la méthode d'Euler pour déterminer la position et la vitesse selon le temps de rendu
	de la simulation.
	
	Paramètre :
	temps_dernier_ecran -- le temps écoulé depuis le dernier écran.
	"""
	#Nombre de période à simuler dans l'écran
	var nb_periode = temps_dernier_ecran  * periode / periode_relative
	#Pas de la simulation
	var h = nb_periode / etapes_calcul_par_ecran

	for i in range(etapes_calcul_par_ecran):
		
		var a_i = acceleration_totale()

		var r_i_plus_1 = r_i + h * v_i
		var v_i_plus_1 = v_i + h * a_i
		
		r_i = r_i_plus_1
		v_i = v_i_plus_1

func conv_position_reelle_a_simulee(position_reelle : Vector3) -> Vector3:
	"""Effectue la conversion d'une position réelle à une position de l'espace 
	de la simulation
	
	Paramètres:
	position_reelle -- la position réelle à convertir
	
	Retour :
	la position dans le monde de la simulation à utiliser
	"""
	
	var distance_relle = position_reelle.length()
	var ratio_distance = inverse_lerp(min_distance_reelle, max_distance_reelle, 
		distance_relle)
	var facteur_distance_simulee = lerp (min_distance_simulee, max_distance_simulee,
		 ratio_distance)
	
	return position_reelle.normalized() * facteur_distance_simulee
