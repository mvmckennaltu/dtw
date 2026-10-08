extends SplitContainer
const PARTY_MEMBER_STATUS = preload(
	"uid://dbv2uewflycon"
)

var status_panels: Dictionary = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func setup_party(battlers: Array[Battler]) -> void:
	for battler in battlers:
		var status = PARTY_MEMBER_STATUS.instantiate()
		
		add_child(status)
		status.set_battler(battler)
		
		status_panels[battler] = status

	

func _on_battle_controller_battler_hp_changed(battler: Battler) -> void:
	var panel = status_panels.get(battler)
	
	if panel:
		panel.update_display()
