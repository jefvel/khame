package graphics;
import kha.math.Vector3;
import kha.math.FastMatrix4;
import kha.math.FastVector3;

class RenderState {
	public var cameraMatrix:FastMatrix4;
	public var perspectiveMatrix:FastMatrix4;
	public var offset:FastVector3;
	
	public var cameraPosition:Vector3;
	public var cameraDirection:Vector3;
	
	public var cameraTargetPos:Vector3;
	
	var state:game.GameState;
	public function new(g:game.GameState) {
		state = g;
		cameraTargetPos = new Vector3();
	}
	
	public function update(framebuffer:kha.Framebuffer) {
		var eye = new Vector3(Math.cos(haxe.Timer.stamp()), Math.sin(haxe.Timer.stamp()), 10);
		eye.x = 0;
		eye.y = 0;
		var dir = new Vector3(0, 3, 0);
		var up = new Vector3(0, 0, 1.0);
		
		eye.x += state.cameraX;
		eye.y += state.cameraY;
		dir.x += state.cameraX;
		dir.y += state.cameraY;
		
		cameraMatrix = kha.math.FastMatrix4.lookAt(
			FastVector3.fromVector3(eye), 
			FastVector3.fromVector3(dir), 
			FastVector3.fromVector3(up));
		
		dir = dir.sub(eye);
		dir.normalize();
		
		cameraDirection = dir;
		cameraPosition = eye;
		
		perspectiveMatrix = kha.math.FastMatrix4.perspectiveProjection(90, framebuffer.width / framebuffer.height, 0.01, 100.0);
	}
}