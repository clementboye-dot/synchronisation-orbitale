#Simule la révolution des lunes autour de Jupiter
extends Node3D
#class_name Astre

@export var centre_rotation : RigidBody3D
@export var periode_relative : float

@export_group("Paramètre de conversion simulation")
@export var min_distance_simulee : float
@export var max_distance_simulee : float
@export var min_distance_reelle : float
@export var max_distance_reelle : float

@export_group("Simulation gravitationnelle")
@export var masse : float
@export var masse_jupiter : float


@export_group("Paramètres de la méthode d'Euler")
@export var etapes_calcul_par_ecran : int

#---CONSTANTES---#
var G : float = 6.673e-11
var R_p : float = 664862000 #((m)
var V_p : float = 14.193e3 #(m/s)
var K : float = 1e14 #(N/m)
var D : float = 24.97e6 #(m)
var Zeta : float = 4e16 #(N⋅s/m)


var r_i1 : Vector3 
var r_i2 : Vector3
var v_i1 : Vector3
var v_i2 : Vector3

var periode : float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#---POSITIONS INITIALES---#
	r_i1 = (R_p - D/2) * Vector3(1, 0, 0)
	r_i2 = (R_p + D/2) * Vector3(1, 0, 0)
	position = conv_position_reelle_a_simulee(r_i1)
	position = conv_position_reelle_a_simulee(r_i2)
	#---VITESSES INITIALES---#
	v_i1 = (3.0/4.0) * V_p * Vector3(0, 0, 1)
	v_i2 = (5.0/4.0) * V_p * Vector3(0, 0, 1)
	
	periode = 2 * PI * r_i1.length() / v_i1.length()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	appliquer_euler(delta)
	position = conv_position_reelle_a_simulee(r_i1)
	position = conv_position_reelle_a_simulee(r_i2)
	

func force_gravitationnelle(position_reelle : Vector3) -> Vector3:
	"""Calcule la force gravitationnelle excercée sur le point d'Europe par Jupiter
	
	Paramètre:
		position_reelle -- position du point de la lune Europe dans l'espace
	
	Retour:
		La force gravitationnelle de Jupiter sur le point de la lune Europe.
	"""
	var force_g = -1 * G * masse * masse_jupiter * position_reelle / (position_reelle.length()**3)
	return force_g

func appliquer_euler(temps_dernier_ecran : float) -> void:
	"""
	Applique la méthode d'Euler pour déterminer la position et la vitesse selon le temps de rendu
	de la simulation.
		
	Paramètre :
	temps_dernier_ecran -- le temps écoulé depuis le dernier écran.
	"""
	#Nombre de période à simuler dans l'écran
	var nb_periode = temps_dernier_ecran  * periode / periode_relative
	#Pas de la simulation
	var h = nb_periode / etapes_calcul_par_ecran

	for i in range(etapes_calcul_par_ecran):

		var fg1 : Vector3 = force_gravitationnelle(r_i1)
		var fg2 : Vector3 = force_gravitationnelle(r_i2)
		var a1 = fg1 / masse
		var a2 = fg2 / masse

		var r_i1_plus_1 = r_i1 + h * v_i1
		var v_i1_plus_1 = v_i1 + h * a1
		var r_i2_plus_1 = r_i2 + h * v_i2
		var v_i2_plus_1 = v_i2 + h * a2
		r_i1 = r_i1_plus_1
		v_i1 = v_i1_plus_1
		r_i2 = r_i2_plus_1
		v_i2 = v_i2_plus_1

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
