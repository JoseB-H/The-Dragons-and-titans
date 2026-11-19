extends "res://scripts/frontier_landscape.gd"

func _ready() -> void:
	var tile := BoxMesh.new()
	var stone := _material(Color("#655952"))
	var slate := _material(Color("#515459"))
	var trim := _material(Color("#947a51"))
	for i in range(-23,24):
		for j in range(-3,4):
			_boulder(tile,stone if (i+j)%3==0 else slate,Vector3(i*2.1,0,j*1.45),Vector3(2.05,.24,1.40),0)
		for side in [-1,1]:
			_boulder(tile,trim,Vector3(i*2.1,.38,side*5.3),Vector3(2.07,.8,.75),0)
			if i%3==0:
				_boulder(tile,stone,Vector3(i*2.1,1.15,side*5.7),Vector3(1.6,2.7,1.8),0)
	_plane(Vector2(220,110),-7,preload("res://assets/nether_water.gdshader"))
