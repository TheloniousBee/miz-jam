extends Node

const Intro = preload("res://scene/Intro.tscn")
const Menu = preload("res://scene/Menu.tscn")
const PettingGame = preload("res://scene/PettingGame.tscn")
const FeedingGame = preload("res://scene/FeedingGame.tscn")
const TrapdoorGame = preload("res://scene/TrapdoorGame.tscn")
const Loss = preload("res://scene/LossScreen.tscn")
const Win = preload("res://scene/WinScreen.tscn")

const EVOLUTION_THRESHOLD_LEVEL_2 = 2
const EVOLUTION_THRESHOLD_LEVEL_3 = 4

class Need:
	var size : int
	var name : String
	var last = LastReduction
	var bar : Node

enum LastReduction {SMALL, MEDIUM, LARGE}

export var starting_need = 20
export var difficulty = 1

onready var current_scene = get_node("Title")
onready var hunger = Need.new()
onready var love = Need.new()
onready var bloodlust = Need.new()

var needs = []
var pet_name : String

var current_evolution_level = 1
var evolution_points = 0
var lost_from : String
var has_won = false

# Called when the node enters the scene tree for the first time.
func _ready():
	initialize_needs()
	pass

func remove_current_scene():
	remove_child(current_scene)
	current_scene.call_deferred("free")
	return

func load_intro():
	remove_current_scene()
	var intro_scene = Intro.instance()
	add_child(intro_scene)
	current_scene = intro_scene
	return

func load_menu():
	remove_current_scene()
	var menu_scene = Menu.instance()
	add_child(menu_scene)
	current_scene = menu_scene
	return

func load_petting_game():
	remove_current_scene()
	var petting_game_scene = PettingGame.instance()
	add_child(petting_game_scene)
	current_scene = petting_game_scene
	return
	
func load_feeding_game():
	remove_current_scene()
	var feeding_game_scene = FeedingGame.instance()
	add_child(feeding_game_scene)
	current_scene = feeding_game_scene
	return
	
func load_trapdoor_game():
	remove_current_scene()
	var trapdoor_game_scene = TrapdoorGame.instance()
	add_child(trapdoor_game_scene)
	current_scene = trapdoor_game_scene
	pass
	
func load_lose_screen():
	remove_current_scene()
	var loss_scene = Loss.instance()
	var loss_message = loss_scene.get_node("LossMessage")
	match(lost_from):
		"Hunger":
			loss_message.text = pet_name+" has starved..."
		"Love":
			loss_message.text = pet_name+" has abandoned you..."
		"Bloodlust":
			loss_message.text = pet_name+" has left to go on a rampage..."
	add_child(loss_scene)
	current_scene = loss_scene
	return
	
func load_win_screen():
	remove_current_scene()
	var win_scene = Win.instance()
	var win_message = win_scene.get_node("WinMessage")
	win_message.text = "Congratulations! "+pet_name+" has become an unstoppable machine of death!"
	add_child(win_scene)
	current_scene = win_scene
	return

func initialize_needs():
	hunger.name = "Hunger"
	hunger.last = LastReduction.SMALL
	hunger.size = starting_need
	love.name = "Love"
	love.last = LastReduction.MEDIUM
	love.size = starting_need
	bloodlust.name = "Bloodlust"
	bloodlust.last = LastReduction.LARGE
	bloodlust.size = starting_need
	needs.append(hunger)
	needs.append(love)
	needs.append(bloodlust)
	return

func won_game(need):
	return_to_menu()
	var menu = get_node("Menu")
	var victory_amount = 10
	if need == "Hunger":
		hunger.size += victory_amount
		if hunger.size > starting_need:
			hunger.size = starting_need
	elif need == "Love":
		love.size += victory_amount
		if love.size > starting_need:
			love.size = starting_need
	elif need == "Bloodlust":
		bloodlust.size += victory_amount
		if bloodlust.size > starting_need:
			bloodlust.size = starting_need

	evolution_points += 1
	if evolution_points == EVOLUTION_THRESHOLD_LEVEL_2 and current_evolution_level == 1:
		current_evolution_level = 2
		evolution_points = 0
		print("Achieved level 2")
		menu.evolve(false)
		
	elif evolution_points == EVOLUTION_THRESHOLD_LEVEL_3 and current_evolution_level == 2:
		current_evolution_level = 3
		evolution_points = 0
		print("Achieved level 3")
		menu.evolve(true)
	return
	
func return_to_menu():
	load_menu()
	get_node("Menu").reduce_needs()
	return

func restart_game():
	needs.clear()
	initialize_needs()
	load_intro()
	return
