package graphics;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexData;

class ChunkManager {
	var chunks:Map<String, Chunk>;
	var unusedChunks:Array<Chunk>;
	
	var pipeline:PipelineState;
	var structure:VertexStructure;
	
	var camera:kha.math.FastMatrix4;
	var cameraLocation:kha.graphics4.ConstantLocation;
	var perspective:kha.math.FastMatrix4;
	var perspectiveLocation:kha.graphics4.ConstantLocation;
	var timeLocation:kha.graphics4.ConstantLocation;
	
	var chunk:Chunk;
	
	public function new() {
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
		
		chunk = new Chunk();
		chunk.generateMesh();
		
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
		camera = kha.math.FastMatrix4.lookAt(
			new kha.math.FastVector3(16, 12, -10),
			new kha.math.FastVector3(16 + Math.sin(time), 16 + Math.cos(time), 0), 
			new kha.math.FastVector3(0, 1, 0));
			
		perspective = kha.math.FastMatrix4.perspectiveProjection(90, framebuffer.width / framebuffer.height, 0.01, 100.0);
		
		var g4 = framebuffer.g4;
		g4.begin();
		//g4.clear(kha.Color.Green, 1.0);
		g4.setPipeline(pipeline);
		g4.setMatrix(cameraLocation, camera);
		g4.setMatrix(perspectiveLocation, perspective);
		g4.setFloat(timeLocation, time);
		
		chunk.draw(framebuffer);
		
		g4.end();
	}
	
	public function centerOn(worldX:Int = 0, worldY:Int = 0) {
		trace(chunkName(-Chunk.CHUNK_WIDTH, -Chunk.CHUNK_HEIGHT));
		for(i in 0...21) {
			trace(chunkName(i - 10, 0));
		}
	}
}