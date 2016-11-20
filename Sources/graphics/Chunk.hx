package graphics;

import kha.graphics4.VertexData;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;

class Chunk {
	public static inline var CHUNK_WIDTH = 32;
	public static inline var CHUNK_HEIGHT = 32;
	
	public var worldX:Int;
	public var woldY:Int;
	
	var vertexBuffer:VertexBuffer;
	var baryBuffer:VertexBuffer;
	var indexBuffer:IndexBuffer;
	
	var buffers:Array<VertexBuffer>;
	
	public function new()  {
		var vStructure = new kha.graphics4.VertexStructure();
		vStructure.add("pos", VertexData.Float3);
		vertexBuffer = new VertexBuffer(CHUNK_WIDTH * CHUNK_HEIGHT, vStructure, Usage.DynamicUsage);
		
		var bStructure = new kha.graphics4.VertexStructure();
		bStructure.add("barycentric", VertexData.Float3);
		baryBuffer = new VertexBuffer(CHUNK_WIDTH * CHUNK_HEIGHT, bStructure, Usage.DynamicUsage);
		
		indexBuffer = new IndexBuffer(((CHUNK_WIDTH - 1) * (CHUNK_HEIGHT - 1)) * 2 * 3, Usage.StaticUsage);
		
		buffers = [vertexBuffer, baryBuffer];
	}
	
	private inline function coordsToIndex(x:Int, y:Int) {
		return x + y * (CHUNK_WIDTH);
	}
	
	public function generateMesh() {
		var indices = new Array<Int>();
		var verts = new Array<Float>();
		var baryCoords = new Array<Float>();
		
		var barys = [
			[1.0, 0.0, 0.0],
			[0.0, 1.0, 0.0],
			[0.0, 0.0, 1.0]
		];

		
		var bx = 0;
		for(y in 0...CHUNK_WIDTH) {
			for(x in 0...CHUNK_HEIGHT) {
				verts.push(x);
				verts.push(y);
				verts.push(Math.random());
				
				baryCoords.push(barys[(bx + x) % 3][0]);
				baryCoords.push(barys[(bx + x) % 3][1]);
				baryCoords.push(barys[(bx + x) % 3][2]);
				
				if(x < CHUNK_WIDTH - 1) {
					if(y < CHUNK_HEIGHT - 1) {
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