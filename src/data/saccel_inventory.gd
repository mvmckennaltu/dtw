extends Resource
class_name SAccel_Inventory

@export var saccels_list : Array[SAccel] = []

func add_saccel_to_inventory(accel: SAccel):
	for entry in saccels_list:
		if accel.saccel_name == entry.saccel_name:
			print("You can only have one of each unique Soul Accelerator at a time.")
			return
		else:
			saccels_list.append(accel)
func remove_accel_from_inventory(accel: SAccel, is_being_transferred: bool):
	for entry in saccels_list:
		if accel.saccel_name == entry.saccel_name:
			var removed_accel = entry
			saccels_list.erase(entry)
			if is_being_transferred:
				return removed_accel
			else:
				return
		else:
			return
