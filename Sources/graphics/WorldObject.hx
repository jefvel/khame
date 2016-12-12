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
	
	public var spriteSheet:kek.graphics.TileSheet;
	public var currentAnimation:String;
	
	var animationStart:Float;
	var cAnimation:kek.graphics.TileSheet.Animation;
	var animationInQueue:String;
	var queueStartLoop:Int;
	
	var animationLoops = 0;
				
	public function new() {
		rotation = 0.0;
		origin = new kha.math.FastVector2(0.5, 0.5);
		position = new kha.math.Vector3();
		scale = new kha.math.FastVector2(1.0, 1.0);
	}
	
	public function getCurrentFrame() {
		// Return first frame if no animation specified.
		if(cAnimation == null) {
			return spriteSheet.getFrame(0);
		}

		
		var animationRunningLength = Std.int((haxe.Timer.stamp() - animationStart) * 1000);
		
		animationLoops = Std.int(animationRunningLength / cAnimation.totalLength);
		if(animationInQueue != null && animationLoops > queueStartLoop) {
			//if(animationRunningLength > cAnimation.totalLength) {
				animationRunningLength -= cAnimation.totalLength;
				cAnimation = spriteSheet.getAnimation(animationInQueue);
				currentAnimation = animationInQueue;
				animationInQueue = null;
			//}
		}

		
		var d = Std.int(cAnimation.to - cAnimation.from);
		if(d == 0) {
			return spriteSheet.getFrame(cAnimation.from);
		}
		
		var cf = animationRunningLength % cAnimation.totalLength;
		
		var totalTime = 0; 
		for(f in 0...d + 1) {
			var frame = spriteSheet.frames[f + cAnimation.from];
			totalTime += frame.duration;
			if(cf <= totalTime) {
				return frame;
			}
		}
		
		return spriteSheet.frames[0];
	}
	
	public function playAnimation(name:String, force:Bool = false) {
		if(spriteSheet == null) {
			return;
		}
		
		if(currentAnimation == name || animationInQueue == name) {
			return;
		}
		
		if(force || cAnimation == null) {
			animationInQueue = null;
			changeAnimation(name);
		} else {
			animationInQueue = name;
			queueStartLoop = animationLoops;
		}
	}
	
	function changeAnimation(name:String) {
		animationLoops = 0;
		animationStart = haxe.Timer.stamp();
		currentAnimation = name;
		cAnimation = spriteSheet.getAnimation(name);	
	}
}