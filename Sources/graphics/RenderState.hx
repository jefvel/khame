package graphics;
import kha.math.Vector3;
import kha.math.FastMatrix4;
import kha.math.FastVector3;
import kha.math.FastVector4;

class RenderState {
	public var cameraMatrix:FastMatrix4;
	public var perspectiveMatrix:FastMatrix4;
	public var offset:FastVector3;
	
	public var cameraPosition:Vector3;
	public var cameraDirection:Vector3;
	
	public var cameraTargetPos:Vector3;
	public var cursorWorldPosition:Vector3;
	
	public var near:Float = 0.1;
	public var far:Float = 37.0;
	public var fov:Float = 90.0 * (Math.PI / 180.0);
	public var ratio:Float = 1.0;
	
	public var frustum:kek.graphics.Frustum;

	public var screenWidth:Int;
	public var screenHeight:Int;
	public var mouseX:Int;
	public var mouseY:Int;
	public var frameBuffer:kek.graphics.PostprocessingBuffer;
	
	var state:game.GameState;
	public function new(g:game.GameState) {
		frustum = new kek.graphics.Frustum();
		state = g;
		cameraTargetPos = new Vector3();
		cameraDirection = new Vector3();
		cameraPosition = new Vector3();
		cursorWorldPosition = new Vector3();
		
		inverseMatrix = kha.math.FastMatrix4.empty();
	}
	
	public var chunkOffsetX:Float;
	public var chunkOffsetY:Float;
	
	public function update(framebuffer:kha.Framebuffer) {
		screenWidth = framebuffer.width;
		screenHeight = framebuffer.height;
		
		var eye = new Vector3(0.0, 0.0, 15);
		var dir = new Vector3(0, 8, 0);
		var up = new Vector3(0, 0, 1.0);
		
		ratio = framebuffer.width / framebuffer.height;
		
		eye.x = cameraTargetPos.x;
		eye.y = cameraTargetPos.y - 3;
		eye.z = cameraTargetPos.z + 6;
		
		cameraPosition.x = eye.x;
		cameraPosition.y = eye.y;
		cameraPosition.z = eye.z;
		
		cameraMatrix = kha.math.FastMatrix4.lookAt(
			FastVector3.fromVector3(eye), 
			FastVector3.fromVector3(cameraTargetPos), 
			FastVector3.fromVector3(up));
		
		perspectiveMatrix = kha.math.FastMatrix4.perspectiveProjection(fov, ratio, near, far);
		
		frustum.setCamInternals(fov, ratio, near, far);
		frustum.setCamDef(eye, cameraTargetPos, up);
		
		dir = cameraTargetPos.sub(eye);
		dir.normalize();
		
		inverseMatrix.setFrom(perspectiveMatrix);
		inverseMatrix = inverseMatrix.multmat(kha.math.FastMatrix4.lookAt(
			new FastVector3(0, 0, 0),
			FastVector3.fromVector3(dir), 
			FastVector3.fromVector3(up)));
		inverseMatrix = inverseMatrix.inverse();
		
		kek.math.Vector3Utils.copy3(cameraDirection, dir);
	}
	
	var inverseMatrix:kha.math.FastMatrix4;
	
	var p1:FastVector4 = new FastVector4();
	var p2:FastVector4 = new FastVector4();
	public function screenToWorldRay(x:Float, y:Float, ray:Vector3) {
		var dx = (2.0 * (x / screenWidth)) - 1.0;
		var dy = 1.0 - (2.0 * (y / screenHeight));
		
		p1.x = dx;
		p1.y = dy;
		p1.z = 1.0;
		p1.w = 1.0;
		
		p1 = inverseMatrix.multvec(p1);
		
		p1.w = 1.0 / p1.w;
		p1.x *= p1.w;
		p1.y *= p1.w;
		p1.z *= p1.w;
		
		ray.x = p1.x;
		ray.y = p1.y;
		ray.z = p1.z;
		
		ray.normalize();
	}
}