package graphics;

enum SpriteType {
	Tree;
	Elf;
}

class WorldObject {
	public var position:kha.math.Vector3;
	public var scale:kha.math.FastVector2;
	public var origin:kha.math.FastVector2;
	public var id:String;
	public var rotation:Float;
	
	public var t:Float = 0.0;
	
	public var sprite:SpriteType = Tree;
	
	public function new() {
		rotation = 0.0;
		origin = new kha.math.FastVector2(0.5, 0.5);
		position = new kha.math.Vector3();
		scale = new kha.math.FastVector2(1.0, 1.0);
	}
}