extends CanvasLayer

var world: Node

func display_winner_name(winner_name : String):
	$Image/Label.text = winner_name + " Wins"
	
	
