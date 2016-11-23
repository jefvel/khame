package graphics;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexData;
import kha.graphics4.ConstantLocation;

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
	
	var chunkList:Array<Chunk>;
	
	var state:game.GameState;
	var renderState:RenderState;
	
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
		
		chunkList = new Array<Chunk>();
		for(_x in 0...4) {
			for(_y in 0...4) {
				var x = _x;
				var y = _y;
				var chunk = new Chunk(x * Chunk.CHUNK_WIDTH, y * Chunk.CHUNK_HEIGHT);
				chunk.generateMesh();
				chunkList.push(chunk);
			}
		}
		
		firstTime = haxe.Timer.stamp();
	}
	
	var _vx:Int;
	var _vy:Int;
	public inline function chunkName(worldX:Int, worldY:Int) {
		_vx = worldX;
		_vy = worldY;
		_vx = Std.int(_vx / Chunk.CHUNK_WIDTH);
		if(worldX < 0) {
			_vx -= 1;
		}
		
		_vy = Std.int(_vy / Chunk.CHUNK_HEIGHT);
		if(worldY < 0) {
			_vy -= 1;
		}

		return '$_vx.$_vy';
	}

	var firstTime = 0.0;
	public function render(framebuffer:kha.Framebuffer) {
		var time = haxe.Timer.stamp() - firstTime;
		var eye = new Vector3(16, 15, -3);
		var dir = new Vector3(16, 16, 0);
		var up = new Vector3(0, 1, 0);
			
		
		var g4 = framebuffer.g4;
		g4.begin();
		//g4.clear(kha.Color.Green, 1.0);
		g4.setPipeline(pipeline);
		g4.setMatrix(cameraLocation, renderState.cameraMatrix);
		g4.setMatrix(perspectiveLocation, renderState.perspectiveMatrix);
		g4.setFloat(timeLocation, time);
		
		var offset = new kha.math.FastVector2();
		var hit:kha.math.Vector3 = null;
		for(chunk in chunkList) {
			offset.x = chunk.worldX;
			offset.y = chunk.worldY;
			g4.setVector2(offsetLocation, offset);
			chunk.draw(framebuffer);
			
			if(hit == null) {
				hit = chunk.intersects(renderState.cameraPosition, renderState.cameraDirection);
			}
		}
		
		g4.end();
		
		if(hit != null){
			renderState.cameraTargetPos.x = hit.x;
			renderState.cameraTargetPos.y = hit.y;
			renderState.cameraTargetPos.z = hit.z;
		}
	}
	
	public function centerOn(worldX:Int = 0, worldY:Int = 0) {
		//trace(chunkName(-Chunk.CHUNK_WIDTH, -Chunk.CHUNK_HEIGHT));
		for(i in 0...21) {
			//trace(chunkName(i - 10, 0));
		}
	}
}