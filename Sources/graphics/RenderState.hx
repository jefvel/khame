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
	public var far:Float = 37.0;
	public var fov:Float = 90.0 * (Math.PI / 180.0);
	public var ratio:Float = 1.0;
	
	public var frustum:kek.graphics.Frustum;
	
	var state:game.GameState;
	public function new(g:game.GameState) {
		frustum = new kek.graphics.Frustum();
		state = g;
		cameraTargetPos = new Vector3();
		cameraDirection = new Vector3();
		cameraPosition = new Vector3();
	}
	
	public var chunkOffsetX:Float;
	public var chunkOffsetY:Float;
	
	public function update(framebuffer:kha.Framebuffer) {
		var eye = new Vector3(0.0, 0.0, 15);
		var dir = new Vector3(0, 8, 0);
		var up = new Vector3(0, 0, 1.0);
		
		ratio = framebuffer.width / framebuffer.height;
		
		eye.x += state.cameraX;
		eye.y += state.cameraY;
		
		dir.x = eye.x;
		dir.y = eye.y + 9;
		
		
		cameraMatrix = kha.math.FastMatrix4.lookAt(
			FastVector3.fromVector3(eye), 
			FastVector3.fromVector3(dir), 
			FastVector3.fromVector3(up));
		
		perspectiveMatrix = kha.math.FastMatrix4.perspectiveProjection(fov, ratio, near, far);
		
		frustum.setCamInternals(fov, ratio, near, far);
		frustum.setCamDef(eye, dir, up);
		
		dir = dir.sub(eye);
		dir.normalize();
		
		kek.math.Vector3Utils.copy3(cameraDirection, dir);
		kek.math.Vector3Utils.copy3(cameraPosition, eye);
	}
}