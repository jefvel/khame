package graphics;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexData;
import kha.graphics4.ConstantLocation;
import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;
import kha.graphics4.Usage;

import kha.math.FastVector3;
import kha.math.Vector3;

class ChunkManager {
	var chunks:Map<String, Chunk>;
	var unusedChunks:Array<Chunk>;
	
	var pipeline:PipelineState;
	var structure:VertexStructure;
	
	var camera:kha.math.FastMatrix4;
	var cameraLocation:ConstantLocation;
	
	var perspective:kha.math.FastMatrix4;
	var perspectiveLocation:ConstantLocation;
	
	var timeLocation:ConstantLocation;
	var offsetLocation:ConstantLocation;
	var cursorLocation:ConstantLocation;
	
	var state:game.GameState;
	var renderState:RenderState;
	
	var baryBuffer:VertexBuffer;
	var indexBuffer:IndexBuffer;
	
	public function new(g:game.GameState, rs:RenderState) {
		state = g;
		renderState = rs;
		chunks = new Map<String, Chunk>();
		pipeline = new PipelineState();
		
		var layout = new VertexStructure();
		layout.add("pos", VertexData.Float3);
		
		var bary = new VertexStructure();
		bary.add("barycentric", VertexData.Float3);
		
		pipeline.inputLayout = [layout, bary];
		pipeline.vertexShader = kha.Shaders.ground_vert;
		pipeline.fragmentShader = kha.Shaders.ground_frag;
		pipeline.depthWrite = true;
		pipeline.depthMode = kha.graphics4.CompareMode.LessEqual;
		pipeline.compile();
		
		structure = new VertexStructure();
		structure.add("pos", VertexData.Float3);
		structure.add("barycentric", VertexData.Float3);
		cameraLocation = pipeline.getConstantLocation("camera");
		perspectiveLocation = pipeline.getConstantLocation("perspective");
		
		timeLocation = pipeline.getConstantLocation("time");
		offsetLocation = pipeline.getConstantLocation("offset");
		cursorLocation = pipeline.getConstantLocation("cursorPos");
		
		unusedChunks = new Array<Chunk>();
		
		firstTime = haxe.Timer.stamp();
		
		var bStructure = new kha.graphics4.VertexStructure();
		bStructure.add("barycentric", VertexData.Float3);
		
		baryBuffer = new VertexBuffer(Chunk.CHUNK_VERTS_X * Chunk.CHUNK_VERTS_Y, bStructure, Usage.StaticUsage);
		indexBuffer = new IndexBuffer(((Chunk.CHUNK_VERTS_X - 1) * (Chunk.CHUNK_VERTS_Y - 1)) * 6, Usage.StaticUsage);
		
		generateMesh();
	}
	
	inline function generateMesh() {
		var indices = new Array<Int>();
		var baryCoords = new Array<Float>();
		
		var barys = [
			[1.0, 0.0, 0.0],
			[0.0, 1.0, 0.0],
			[0.0, 0.0, 1.0]
		];
		
		var bx = 0;
		for(y in 0...Chunk.CHUNK_VERTS_Y) {
			for(x in 0...Chunk.CHUNK_VERTS_X) {
				baryCoords.push(barys[(bx + x) % 3][0]);
				baryCoords.push(barys[(bx + x) % 3][1]);
				baryCoords.push(barys[(bx + x) % 3][2]);
				
				if(x < Chunk.CHUNK_VERTS_X - 1) {
					if(y < Chunk.CHUNK_VERTS_Y - 1) {
						indices.push(Chunk.coordsToIndex(x, y));
						indices.push(Chunk.coordsToIndex(x, y + 1));
						indices.push(Chunk.coordsToIndex(x + 1, y));
						
						indices.push(Chunk.coordsToIndex(x + 1, y));
						indices.push(Chunk.coordsToIndex(x, y + 1));
						indices.push(Chunk.coordsToIndex(x + 1, y + 1));
					}
				}
			}
			 
			bx += 2;
		}

		var vbData = baryBuffer.lock();
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
	
	var _vx:Int;
	var _vy:Int;
	public inline function chunkNameFromWorldCoord(worldX:Int, worldY:Int) {
		if(worldX < 0) {
			_vx = Std.int((worldX + 1) / Chunk.CHUNK_WIDTH) - 1;
		} else {
			_vx = Std.int(worldX / Chunk.CHUNK_WIDTH);
		}
		
		if(worldY < 0) {
			_vy = Std.int((worldY + 1) / Chunk.CHUNK_HEIGHT) - 1;
		} else {
			_vy = Std.int(worldY / Chunk.CHUNK_HEIGHT);
		}

		return '$_vx@$_vy';
	}

	public inline function getChunk(x:Int, y:Int) {
		var id = '$x@$y';
		var chunk = chunks.get(id);
		
		if(chunk == null) {
			if(unusedChunks.length > 0) {
				chunk = unusedChunks.splice(0, 1)[0];
				chunk.updatePos(x * Chunk.CHUNK_WIDTH, y * Chunk.CHUNK_HEIGHT);
			} else {
				chunk = new Chunk(x * Chunk.CHUNK_WIDTH, y * Chunk.CHUNK_HEIGHT);
			}
			
			chunks.set(chunk.chunkId(), chunk);
		}
		
		return chunk;
	}
	
	public inline function unloadChunk(chunk:Chunk) {
		chunks.remove(chunk.chunkId());
		chunk.unload();
		unusedChunks.push(chunk);
	}
	
	var firstTime = 0.0;
	public function render(framebuffer:kha.Framebuffer) {
		var time = haxe.Timer.stamp() - firstTime;
		var g4 = framebuffer.g4;
		
		g4.begin();
		g4.setPipeline(pipeline);
		g4.setMatrix(cameraLocation, renderState.cameraMatrix);
		g4.setMatrix(perspectiveLocation, renderState.perspectiveMatrix);
		g4.setFloat(timeLocation, time);
		
		var halfWidth = Chunk.CHUNK_WIDTH * 0.5;
		var halfHeight = Chunk.CHUNK_HEIGHT * 0.5;
		
		var w:Int = Std.int(Math.ceil((renderState.frustum.maxPoint.x - renderState.frustum.minPoint.x) / Chunk.CHUNK_WIDTH)) + 1;
		var h:Int = Std.int(Math.ceil((renderState.frustum.maxPoint.y - renderState.frustum.minPoint.y) / Chunk.CHUNK_HEIGHT)) + 1;
		var startX:Int = Std.int(Math.floor((renderState.frustum.minPoint.x) / Chunk.CHUNK_WIDTH));
		var startY:Int = Std.int(Math.floor((renderState.frustum.minPoint.y) / Chunk.CHUNK_HEIGHT));
		
		var hit:kha.math.Vector3 = null;
		var offset = new kha.math.FastVector2();
		
		for(chunk in chunks) {
			if(chunk.y < startY || chunk.y > startY + h || chunk.x < startX ||chunk.x > startX + w) {
				unloadChunk(chunk);
				var px = chunk.x;
				var py = chunk.y;
				continue;
			}
			
			hit = chunk.intersects(renderState.cameraPosition, renderState.cameraDirection);
			if(hit != null) {
				break;
			}
		}
		
		if(hit != null) {
			kek.math.Vector3Utils.copy3(renderState.cameraTargetPos, hit);
		}
		
		g4.setVector3(cursorLocation, FastVector3.fromVector3(renderState.cameraTargetPos));
		
		for(y in 0...h) {
			for(x in 0...w) {
				var chunk = getChunk(x + startX, y + startY);
				offset.x = chunk.worldX;
				offset.y = chunk.worldY;
				
				g4.setVector2(offsetLocation, offset);
				
				chunk.draw(framebuffer);
				var buffers = [chunk.vertexBuffer, baryBuffer];
				g4.setVertexBuffers(buffers);
				g4.setIndexBuffer(indexBuffer);
				g4.drawIndexedVertices();
			}
		}
		
		g4.end();
	}
}