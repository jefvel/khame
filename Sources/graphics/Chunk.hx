package graphics;

import kha.graphics4.VertexData;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;

import kek.math.RayIntersections;
import kha.math.Vector3;

class Chunk {
	public static inline var MAX_HEIGHT = 20.0;
	public static inline var CHUNK_WIDTH = 16;
	public static inline var CHUNK_HEIGHT = 16;
	
	public static inline var CHUNK_VERTS_X = CHUNK_WIDTH + 1;
	public static inline var CHUNK_VERTS_Y = CHUNK_HEIGHT + 1;
	
	public var buffers:Array<kha.graphics4.VertexBuffer>;
	
	public var x:Int;
	public var y:Int;
	public var worldX:Int;
	public var worldY:Int;
	
	public var vertexBuffer:VertexBuffer;
	public var normalBuffer:VertexBuffer;
	
	var heights:Array<Float>;
	
	static var noise:kek.math.PerlinNoise;
	static var largeNoise:kek.math.PerlinNoise;
	
	public var maxHeightInChunk:Float;
	
	public function new(wx:Int = 0, wy:Int = 0)  {
		var vStructure = new kha.graphics4.VertexStructure();
		vStructure.add("pos", VertexData.Float3);
		vStructure.add("normal", VertexData.Float3);
		
		vertexBuffer = new VertexBuffer(CHUNK_WIDTH * CHUNK_HEIGHT * 6 * 2, vStructure, Usage.DynamicUsage);
		
		if(noise == null) {
			noise = new kek.math.PerlinNoise(453, 5, 0.7);
			largeNoise = new kek.math.PerlinNoise(499, 2);
		}
		
		updatePos(wx, wy);
	}
	
	public inline function chunkId():String {
		return '$x@$y';
	}
	
	public function updatePos(wx:Int, wy:Int) {
		maxHeightInChunk = 0.0;
		
		worldX = wx;
		worldY = wy;
		
		if(wx < 0) {
			x = Std.int((wx + 1) / CHUNK_WIDTH) - 1;
		}else {
			x = Std.int(wx / CHUNK_WIDTH);
		}
		
		if(wy < 0) {
			y = Std.int((wy + 1) / CHUNK_HEIGHT) - 1;
		}else {
			y = Std.int(wy / CHUNK_HEIGHT);
		}
		
		generateMesh();
		
		load();
	}
	
	var treeRef:firebase.database.Reference;
	public function unload() {
		treeRef.off();
		treeRef = null;
	}
	
	private function load() {
		var id = chunkId();
		treeRef = firebase.Firebase.database().ref('chunks/$id');
		treeRef.on(firebase.EventType.Value, function(data, i){
			var v = data.val();
		});
	}
	
	public static inline function coordsToIndex(x:Int, y:Int) {
		return x + y * (CHUNK_VERTS_X);
	}
	
	var scale = 1.12;
	private function height(worldX:Float, worldY:Float) {
		worldX *= scale;
		worldY *= scale;
		var largeScale = largeNoise.noise2D(worldX * 0.5, worldY * 0.5);
		
		var h = largeScale * noise.noise2D(worldX, worldY) * MAX_HEIGHT;
		
		return h;
	}
	
	var v1:Vector3 = new Vector3();
	var v2:Vector3 = new Vector3();
	var v3:Vector3 = new Vector3();
	public inline function getLocalHeight(x:Int, y:Int) {
		var h = heights[x + y * CHUNK_VERTS_X];
		if(h == null) {
			return 0.0;
		}
		
		return h;
	}
	
	public function intersects(ray:kha.math.Vector3, dir:kha.math.Vector3) {
		var hit = false;
		
		hit = RayIntersections.rayBoxIntersection(
			worldX, worldX + CHUNK_WIDTH,
			worldY, worldY + CHUNK_HEIGHT,
			0.0, maxHeightInChunk, ray, dir);
			
		if(!hit) {
			return null;
		}

		var result:Vector3 = new Vector3();
		for(y in 0...CHUNK_HEIGHT) {
			for(x in 0...CHUNK_WIDTH) {
				v1.x = x + worldX;
				v1.y = y + worldY;
				v1.z = getLocalHeight(x, y);
				
				v2.x = x + worldX;
				v2.y = y + 1 + worldY;
				v2.z = getLocalHeight(x, y + 1);

				v3.x = x + 1 + worldX;
				v3.y = y + worldY;
				v3.z = getLocalHeight(x + 1, y);
				
				hit = RayIntersections.rayTriangleIntersection(v1, v2, v3, ray, dir, result);
				
				if(hit) {
					break;
				}
				
				v1.x = x + worldX + 1;
				v1.y = y + worldY + 1;
				v1.z = getLocalHeight(x + 1, y + 1);
				
				hit = RayIntersections.rayTriangleIntersection(v1, v2, v3, ray, dir, result);
				
				if(hit) {
					break;
				}
			}
			
			if(hit) {
				break;
			}
		}
		
		if(hit) {
			return result;
		}

		return null;
	}
	
	inline function addVert(x:Int, y:Int, normal:Vector3, verts:Array<Float>) {
		verts.push(x);
		verts.push(y);
		
		var h = getLocalHeight(x, y);
		verts.push(h);
		
		verts.push(normal.x);
		verts.push(normal.y);
		verts.push(normal.z);
		
		return h;
	}
	
	public function generateMesh() {
		heights = new Array<Float>();
		var indices = new Array<Int>();
		var verts = new Array<Float>();
		
		var bx = 0;
		for(y in 0...CHUNK_VERTS_Y) {
			for(x in 0...CHUNK_VERTS_X) {
				var h = height(x + worldX, y + worldY);
				maxHeightInChunk = Math.max(maxHeightInChunk, h);
				heights.push(h);
			}
		}
		
		for(y in 0...CHUNK_HEIGHT) {
			for(x in 0...CHUNK_WIDTH) {
				v1.x = 1;
				v1.y = 0;
				v1.z = getLocalHeight(x + 1, y) - getLocalHeight(x, y);
				
				v2.x = 0;
				v2.y = 1;
				v2.z = getLocalHeight(x, y + 1) - getLocalHeight(x, y);
				kek.math.Vector3Utils.cross3(v3, v1, v2);
				v3.normalize();
				
				addVert(x, y, v3, verts);
				addVert(x, y + 1, v3, verts);
				addVert(x + 1, y, v3, verts);
				
				v1.x = 1;
				v1.y = 0;
				v1.z = getLocalHeight(x + 1, y + 1) - getLocalHeight(x, y + 1);
				
				v2.x = 0;
				v2.y = 1;
				v2.z = getLocalHeight(x + 1, y + 1) - getLocalHeight(x + 1, y);
				kek.math.Vector3Utils.cross3(v3, v1, v2);
				v3.normalize();
				
				addVert(x + 1, y, v3, verts);
				addVert(x, y + 1, v3, verts);
				addVert(x + 1, y + 1, v3, verts);
			}
		}
		
		var vbData = vertexBuffer.lock();
		for (i in 0...vbData.length) {
			vbData.set(i, verts[i]);
		}
		vertexBuffer.unlock();
	}

	public function draw(f:kha.Framebuffer) {
		var g4 = f.g4;
	}
}