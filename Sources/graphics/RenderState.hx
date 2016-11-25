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
	
	public var near:Float = 0.1;
	public var far:Float = 20.0;
	public var fov:Float = 90.0;
	public var ratio:Float = 1.0;
	
	public var frustum:kek.graphics.Frustum;
	
	var state:game.GameState;
	public function new(g:game.GameState) {
		frustum = new kek.graphics.Frustum();
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
		
		frustum.setCamInternals(fov, ratio, near, far);
		frustum.setCamDef(eye, dir, up);
		
		dir = dir.sub(eye);
		dir.normalize();
		
		cameraDirection = dir;
		cameraPosition = eye;
		
		ratio = framebuffer.width / framebuffer.height;
		perspectiveMatrix = kha.math.FastMatrix4.perspectiveProjection(fov, ratio, near, far);
	}
}