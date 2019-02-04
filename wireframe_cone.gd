tool
extends MeshInstance

export(bool) var fan = true setget _fan
export(bool) var base = true setget _base
export(float) var definition = 16 setget _definition
export(float) var split = 0 setget _split

var processed_once = false
var vertices = null

func _fan( f ):
	fan = f
	if processed_once:
		cone_create()

func _base( b ):
	base = b
	if processed_once:
		cone_create()

func _definition( def ):
	definition = def
	if processed_once:
		cone_create()

func _split( s ):
	if s < 0:
		s = 0
	elif s > 0.5:
		s = 0.5
	split = s
	if processed_once:
		cone_create()

func split_vertices():
	if split != 0:
		var tmp = []
		for v in vertices:
			tmp.append( v )
		vertices = []
		for i in range( 0, len( tmp ) / 2 ):
			var a = tmp[i*2]
			var b = tmp[i*2 + 1]
			var mid = b - a
			vertices.append( a )
			vertices.append( a + mid * split )
			vertices.append( b )
			vertices.append( b - mid * split )

func cone_create():
	
	vertices = []
	
	var a = 0.0
	var cosa = 1
	var sina = 0

	for i in range( 0, definition ):
		
		var b = a + PI * 2 / definition
		var cosb = cos( b )
		var sinb = sin( b )
		
		vertices.append( Vector3( 0, 1, 0 ) )
		vertices.append( Vector3( cosa, -1, sina ) )
		
		if fan and i < definition / 2:
			vertices.append( Vector3( cosa, -1, sina ) )
			vertices.append( Vector3( -cosa, -1, -sina ) )
		
		if base:
			vertices.append( Vector3( cosa, -1, sina ) )
			vertices.append( Vector3( cosb, -1, sinb ) )
		
		a = b
		cosa = cosb
		sina = sinb
	
	split_vertices()
	
	var _mesh = Mesh.new()
	var _surf = SurfaceTool.new()
	
	_surf.begin(Mesh.PRIMITIVE_LINES)
	for v in vertices:
		_surf.add_vertex(v)
	_surf.index()
	_surf.commit( _mesh )
	set_mesh( _mesh )
	
	vertices = null
	

func _ready():
	cone_create()
	
func _process(delta):
	processed_once = true
	