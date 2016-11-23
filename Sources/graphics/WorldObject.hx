package graphics;

class WorldObject {
	public var position:kha.math.Vector3;
	public var scale:kha.math.FastVector2;
	public var id:String;
	
	public function new() {
		position = new kha.math.Vector3();
		scale = new kha.math.FastVector2(1.0, 1.0);
	}
}