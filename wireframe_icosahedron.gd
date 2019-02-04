tool
extends MeshInstance

export(float) var subdivision = 1 setget _subdivision
export(float) var split = 0 setget _split

var X = 0.525731112119133606
var Z = 0.850650808352039932
var vdata = [[ -X, 0.0, Z ],[ X, 0.0, Z ],[ -X, 0.0, -Z ],[ X, 0.0, -Z ],[ 0.0, Z, X ],[ 0.0, Z, -X ],[ 0.0, -Z, X ],[ 0.0, -Z, -X ],[ Z, X, 0.0 ],[ -Z, X, 0.0 ],[ Z, -X, 0.0 ],[ -Z, -X, 0.0 ]]
var tindices = [[ 0, 4, 1 ],[ 0, 9, 4 ],[ 9, 5, 4 ],[ 4, 5, 8 ],[ 4, 8, 1 ],[ 8, 10, 1 ],[ 8, 3, 10 ],[ 5, 3, 8 ],[ 5, 2, 3 ],[ 2, 7, 3 ],[ 7, 10, 3 ],[ 7, 6, 10 ],[ 7, 11, 6 ],[ 11, 0, 6 ],[ 0, 1, 6 ],[ 6, 1, 10 ],[ 9, 0, 11 ],[ 9, 11, 2 ],[ 9, 2, 5 ], [ 7, 2, 11 ]]

var processed_once = false
var icosahedron_tris = null
var edges = null
var vertices = null

func _subdivision( subd ):
	subdivision = subd
#	if processed_once:
	ico_create()

func _split( s ):
	if s < 0:
		s = 0
	elif s > 0.5:
		s = 0.5
	split = s
	if processed_once:
		ico_create()

func vec3( d ):
	return Vector3( d[0], d[1], d[2] )

func contains_edge( i0, i1 ):
	for e in edges:
		if ( e[0] == i0 and e[1] == i1 ) or ( e[0] == i1 and e[1] == i0 ):
			return true
	edges.append( [i0,i1] )
	return false

func ico_subdivide( tri, lvl ):
	
	if ( lvl == 0 ):
		icosahedron_tris.append( [tri[0], tri[1], tri[2] ] )
		return
	
	var v01 = ( tri[0] + tri[1] ) * 0.5
	var v12 = ( tri[1] + tri[2] ) * 0.5
	var v20 = ( tri[2] + tri[0] ) * 0.5
	
	v01 = v01.normalized()
	v12 = v12.normalized()
	v20 = v20.normalized()
	
	ico_subdivide([tri[0], v01, v20], lvl - 1)
	ico_subdivide([tri[1], v12, v01], lvl - 1)
	ico_subdivide([tri[2], v20, v12], lvl - 1)
	ico_subdivide([v01, v12, v20], lvl - 1)
	
	pass

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

func ico_create():
	
	icosahedron_tris = []
	edges = []
	vertices = []
	
	for indices in tindices:
		ico_subdivide( [ vec3( vdata[indices[0]] ), vec3( vdata[indices[1]] ), vec3( vdata[indices[2]] )], subdivision)
	
	for tri in icosahedron_tris:
		if !contains_edge( tri[0], tri[1] ):
			vertices.append( tri[0] )
			vertices.append( tri[1] )
		if !contains_edge( tri[1], tri[2] ):
			vertices.append( tri[1] )
			vertices.append( tri[2] )
		if !contains_edge( tri[2], tri[0] ):
			vertices.append( tri[2] )
			vertices.append( tri[0] )
	
	split_vertices()
	
	var _mesh = Mesh.new()
	var _surf = SurfaceTool.new()
	
	_surf.begin(Mesh.PRIMITIVE_LINES)
	for v in vertices:
		_surf.add_vertex(v)
	_surf.index()
	_surf.commit( _mesh )
	set_mesh( _mesh )
	
	# releasing memory
	icosahedron_tris = null
	edges = null
	vertices = null

func _ready():
	ico_create()
	
func _process(delta):
	processed_once = true
	