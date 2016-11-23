package graphics;

import kha.graphics4.VertexData;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;

import kek.math.TriangleRayIntersection;
import kha.math.Vector3;

class Chunk {
	public static inline var CHUNK_WIDTH = 32;
	public static inline var CHUNK_HEIGHT = 32;
	
	static inline var CHUNK_VERTS_X = CHUNK_WIDTH + 1;
	static inline var CHUNK_VERTS_Y = CHUNK_HEIGHT + 1;
	
	public var worldX:Int;
	public var worldY:Int;
	
	var vertexBuffer:VertexBuffer;
	var baryBuffer:VertexBuffer;
	var indexBuffer:IndexBuffer;
	
	var buffers:Array<VertexBuffer>;
	var heights:Array<Float>;
	static var noise:kek.math.PerlinNoise;
	
	public function new(wx:Int = 0, wy:Int = 0)  {
		worldX = wx;
		worldY = wy;
		
		
		var vStructure = new kha.graphics4.VertexStructure();
		vStructure.add("pos", VertexData.Float3);
		vertexBuffer = new VertexBuffer(CHUNK_VERTS_X * CHUNK_VERTS_Y, vStructure, Usage.DynamicUsage);
		
		var bStructure = new kha.graphics4.VertexStructure();
		bStructure.add("barycentric", VertexData.Float3);
		baryBuffer = new VertexBuffer(CHUNK_VERTS_X * CHUNK_VERTS_Y, bStructure, Usage.StaticUsage);
		
		indexBuffer = new IndexBuffer(((CHUNK_VERTS_X - 1) * (CHUNK_VERTS_Y - 1)) * 2 * 3, Usage.StaticUsage);
		
		buffers = [vertexBuffer, baryBuffer];
		
		if(noise == null) {
			noise = new kek.math.PerlinNoise();
		}
	}
	
	private inline function coordsToIndex(x:Int, y:Int) {
		return x + y * (CHUNK_VERTS_X);
	}
	
	var scale = 6.12;
	private function height(worldX:Float, worldY:Float) {
		
		worldX *= scale;
		worldY *= scale;
		
		var h = noise.noise2D(worldX, worldY) * 10.0;
		
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
				
				hit = TriangleRayIntersection.intersection(v1, v2, v3, ray, dir, result);
				
				if(hit) {
					break;
				}
				
				v1.x = x + worldX + 1;
				v1.y = y + worldY + 1;
				v1.z = getLocalHeight(x + 1, y + 1);
				
				hit = TriangleRayIntersection.intersection(v1, v2, v3, ray, dir, result);
				
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
	
	public function generateMesh() {
		heights = new Array<Float>();
		var indices = new Array<Int>();
		var verts = new Array<Float>();
		var baryCoords = new Array<Float>();
		
		var barys = [
			[1.0, 0.0, 0.0],
			[0.0, 1.0, 0.0],
			[0.0, 0.0, 1.0]
		];
		
		var bx = 0;
		for(y in 0...CHUNK_VERTS_Y) {
			for(x in 0...CHUNK_VERTS_X) {
				verts.push(x);
				verts.push(y);
				var h = height(x + worldX, y + worldY);
				heights.push(h);
				verts.push(h);
				
				
				baryCoords.push(barys[(bx + x) % 3][0]);
				baryCoords.push(barys[(bx + x) % 3][1]);
				baryCoords.push(barys[(bx + x) % 3][2]);
				
				if(x < CHUNK_VERTS_X - 1) {
					if(y < CHUNK_VERTS_Y - 1) {
						indices.push(coordsToIndex(x, y));
						indices.push(coordsToIndex(x, y + 1));
						indices.push(coordsToIndex(x + 1, y));
						
						indices.push(coordsToIndex(x + 1, y));
						indices.push(coordsToIndex(x, y + 1));
						indices.push(coordsToIndex(x + 1, y + 1));
					}
				}
			}
			 
			bx += 2;
		}
		
		var vbData = vertexBuffer.lock();
		for (i in 0...vbData.length) {
			vbData.set(i, verts[i]);
		}
		
		vertexBuffer.unlock();

		vbData = baryBuffer.lock();
		for (i in 0...vbData.length) {
			vbData.set(i, baryCoords[i]);
		}
		
		baryBuffer.unlock();
		
		var iData = indexBuffer.lock();
		for (i in 0...iData.length) {
			iData[i] = indices[i];
		}
		
		indexBuffer.unlock();
	}

	public function draw(f:kha.Framebuffer) {
		var g4 = f.g4;
		
		g4.setVertexBuffers(buffers);
		g4.setIndexBuffer(indexBuffer);
		g4.drawIndexedVertices();
	}
}