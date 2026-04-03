extends Interactable

@export var item_name: String = "Kunci"

func interact(player):
	if player.has_method("add_to_inventory"):
		player.add_to_inventory(item_name)
		queue_free()
