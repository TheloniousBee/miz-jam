extends Node

signal feed_button_pressed
signal kill_button_pressed
signal pet_button_pressed
signal fadeout_complete
signal evolution_complete
signal ui_button_pressed

var rng = RandomNumberGenerator.new()
var move_to_win_screen = false

onready var pet_name = get_parent().pet_name

func _ready():
	rng.randomize()
	
	self.connect("ui_button_pressed", get_parent(), "play_ui_sound")
	
	self.connect("fadeout_complete", get_parent(), "load_lose_screen")
	self.connect("evolution_complete", get_parent(), "load_win_screen")
	
	self.connect("feed_button_pressed", get_parent(), "load_feeding_game")
	self.connect("kill_button_pressed", get_parent(), "load_trapdoor_game")
	self.connect("pet_button_pressed", get_parent(), "load_petting_game")
	var feed_button = get_node("TopLayer/GUI/NeedButtonContainer/Feed")
	var pet_button = get_node("TopLayer/GUI/NeedButtonContainer/Pet")
	var kill_button = get_node("TopLayer/GUI/NeedButtonContainer/Kill")
	feed_button.text = "Feed "+pet_name+"."
	pet_button.text = "Pet "+pet_name+"."
	kill_button.text = "Let "+pet_name+" kill."
	
	$Pet.type = get_parent().pet_type
	$Pet.evolution = get_parent().current_evolution_level
	$EvolutionChange.text = "Congratulations! "+get_parent().pet_name+" has evolved!"

	
	get_parent().hunger.bar = get_node("TopLayer/GUI/GridContainer/HungerBar")
	get_parent().love.bar = get_node("TopLayer/GUI/GridContainer/LoveBar")
	get_parent().bloodlust.bar = get_node("TopLayer/GUI/GridContainer/BloodlustBar")
	
	get_parent().hunger.previous_bar = get_node("BottomLayer/GUI/GridContainer/HungerBar")
	get_parent().love.previous_bar = get_node("BottomLayer/GUI/GridContainer/LoveBar")
	get_parent().bloodlust.previous_bar = get_node("BottomLayer/GUI/GridContainer/BloodlustBar")
	return
	
func _process(delta):
	if !$FadeoutTimer.is_stopped():
		#Fadeout our pet over the time
		var pet = get_node("Pet")
		var previous_color = pet.modulate
		previous_color[3] = previous_color[3] - delta / $FadeoutTimer.wait_time
		pet.modulate = previous_color
		
	if !$ReturnTimer.is_stopped():
		#Fadein our pets evolution over the time
		var pet_evo : Node
		match $Pet.evolution:
			2:
				pet_evo = get_node("Pet/Evolution2")
			3:
				pet_evo = get_node("Pet/Evolution3")
			4:
				pet_evo = get_node("Pet/Evolution4")
		var previous_color = pet_evo.modulate
		previous_color[3] = previous_color[3] + delta / $FadeoutTimer.wait_time
		pet_evo.modulate = previous_color
	return	

func _on_Feed_pressed():
	emit_signal("ui_button_pressed")
	emit_signal("feed_button_pressed")
	return

func _on_Kill_pressed():
	emit_signal("ui_button_pressed")
	emit_signal("kill_button_pressed")
	return

func _on_Pet_pressed():
	emit_signal("ui_button_pressed")
	emit_signal("pet_button_pressed")
	return

func _on_FadeoutTimer_timeout():
	emit_signal("fadeout_complete")
	return

func evolve(has_won):
	get_node("BottomLayer/GUI").visible = false
	get_node("TopLayer/GUI").visible = false
	$EvolutionChange.visible = true
	get_node("Pet/EvolutionSparkle").emitting = true
	match get_parent().current_evolution_level:
		2:
			get_node("Pet/Evolution2").modulate = Color(1, 1, 1, 0)
		3:
			get_node("Pet/Evolution3").modulate = Color(1, 1, 1, 0)
		4:
			get_node("Pet/Evolution4").modulate = Color(1, 1, 1, 0)
	$Pet.evolution = get_parent().current_evolution_level
	$Evolution.play()
	move_to_win_screen = has_won
	$ReturnTimer.start()
	return

func _on_ReturnTimer_timeout():
	if move_to_win_screen:
		emit_signal("evolution_complete")
	get_node("BottomLayer/GUI").visible = true
	get_node("TopLayer/GUI").visible = true
	$EvolutionChange.visible = false
	get_node("Pet/EvolutionSparkle").emitting = false
	return

#Reduce the need bars
func reduce_needs():
	var total = rng.randi_range(7, 10)
	var remainder = total
	var largest = total / 2
	var medium = total / 3
	remainder -= largest + medium
	var small = remainder
	
	for i in get_parent().needs:
		i.previous_bar.change_segment_number(float(i.size) / 20.0)
		if(i.last == get_parent().LastReduction.SMALL):
			i.last = get_parent().LastReduction.LARGE
			i.size -= largest
		elif(i.last == get_parent().LastReduction.MEDIUM):
			i.last = get_parent().LastReduction.SMALL
			i.size -= small
		else:
			i.last = get_parent().LastReduction.MEDIUM
			i.size -= medium
		
		if(i.size > 0):
			i.bar.change_segment_number(float(i.size) / 20.0)
		else:
			i.bar.change_segment_number(0.0)
			get_parent().lost_from = i.name
			get_node("TopLayer/GUI/NeedButtonContainer/Feed").visible = false
			get_node("TopLayer/GUI/NeedButtonContainer/Pet").visible = false
			get_node("TopLayer/GUI/NeedButtonContainer/Kill").visible = false
			$FadeoutTimer.start()
			break
	return
