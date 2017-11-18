extends Sprite

func _ready():
	pass

func update_frame(percentage):
	#print(int(round(24 * percentage)))
	set("frame", int(round(24 * percentage)))