tool
extends MeshInstance

export(float) var split = 0 setget _split

var processed_once = false
var vertices = null

func _split( s ):
	if s < 0:
		s = 0
	elif s > 0.5:
		s = 0.5
	split = s
	if processed_once:
		cube_asteriscus()

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

func cube_asteriscus():
	
	vertices = []

	var c = cos( 2 * PI / 3 )	
	var s = sin( 2 * PI / 3 )
	
	# top
	vertices.append( Vector3( 0, 1, 0 ) )
	vertices.append( Vector3( 0, -1, 0 ) )
	
	var v00 = Vector3( s, c, 0 )
	var v01 = Vector3( -s, -c, 0 )
	
	var v10 = Vector3( -s, c, 0 )
	var v11 = Vector3( s, -c, 0 )
	
	vertices.append( v00 )
	vertices.append( v01 )
	
	vertices.append( v10 )
	vertices.append( v11 )
	
	var b = Basis()
	var b0 = b.rotated( Vector3( 0,1,0 ), 2 * PI / 3 )
	vertices.append( b0.xform(v00) )
	vertices.append( b0.xform(v01) )
	vertices.append( b0.xform(v10) )
	vertices.append( b0.xform(v11) )
	
	b0 = b.rotated( Vector3( 0,1,0 ), -2 * PI / 3 )
	vertices.append( b0.xform(v00) )
	vertices.append( b0.xform(v01) )
	vertices.append( b0.xform(v10) )
	vertices.append( b0.xform(v11) )
	
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
	cube_asteriscus()
	
func _process(delta):
	processed_once = true
	