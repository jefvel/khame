package graphics;

import kha.graphics4.TextureAddressing;
import kha.graphics4.TextureFilter;
import kha.graphics4.TextureFormat;

import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexData;
import kha.graphics4.ConstantLocation;

import kha.math.FastVector3;
import kha.math.Vector3;

class WorldObjects {
	var pipeline:PipelineState;
	
	var camera:kha.math.FastMatrix4;
	var cameraLocation:ConstantLocation;
	
	var perspective:kha.math.FastMatrix4;
	var perspectiveLocation:ConstantLocation;
	
	var timeLocation:ConstantLocation;
	var offsetLocation:ConstantLocation;
	var scaleLocation:ConstantLocation;
	var textureOriginLocation:ConstantLocation;
	
	var entityList:Array<WorldObject>;
	
	var state:game.GameState;
	var firstTime:Float;
	
	var renderState:graphics.RenderState;
	
	var vertexBuffer:VertexBuffer;
	var indexBuffer:IndexBuffer;
	
	var tex:kha.Image;
	var texLocation:kha.graphics4.TextureUnit;
	
	public function new(g:game.GameState, rs:graphics.RenderState) {
		renderState = rs;
		firstTime = haxe.Timer.stamp();
		entityList = new Array<WorldObject>();
		state = g;
		pipeline = new PipelineState();
		
		var layout = new VertexStructure();
		layout.add("pos", VertexData.Float3);
		layout.add("uv", VertexData.Float2);
		
		pipeline.inputLayout = [layout];
		pipeline.vertexShader = kha.Shaders.entity_vert;
		pipeline.fragmentShader = kha.Shaders.entity_frag;
		pipeline.depthWrite = true;
		
		pipeline.blendOperation = kha.graphics4.BlendingOperation.Add;
		pipeline.blendSource = kha.graphics4.BlendingFactor.SourceAlpha;
		pipeline.blendDestination = kha.graphics4.BlendingFactor.InverseSourceAlpha;
		
		pipeline.depthMode = kha.graphics4.CompareMode.LessEqual;
		pipeline.compile();
		
		cameraLocation = pipeline.getConstantLocation("camera");
		perspectiveLocation = pipeline.getConstantLocation("perspective");
		
		timeLocation = pipeline.getConstantLocation("time");
		offsetLocation = pipeline.getConstantLocation("offset");
		scaleLocation = pipeline.getConstantLocation("scale");
		textureOriginLocation = pipeline.getConstantLocation("spriteOrigin");
		
		texLocation = pipeline.getTextureUnit("tex");
		
		generateMesh();
		
		kha.Assets.loadImage(kha.Assets.images.treeleavesName, function(img) {
			tex = img;
		});
	}
	
	function generateMesh() {
		var vStructure = new kha.graphics4.VertexStructure();
		vStructure.add("pos", VertexData.Float3);
		vStructure.add("uv", VertexData.Float2);
		vertexBuffer = new VertexBuffer(4, vStructure, Usage.StaticUsage);
		
		var s = 1.0;
		
		var verts = [
			0.0, 0,   s,
			0.0, 0.0,
			
			0.0, 0,   0.0,
			0.0, 1.0,
			
			s,   0.0, 0.0,
			1.0, 1.0,
			
			s,   0,   s,
			1.0, 0.0
		];
		
		var indices = [0, 1, 3,
					   1, 2, 3];
		
		indexBuffer = new IndexBuffer(6, Usage.StaticUsage);
		
		var vbData = vertexBuffer.lock();
		for (i in 0...vbData.length) {
			vbData.set(i, verts[i]);
		}
		vertexBuffer.unlock();
		
		var iData = indexBuffer.lock();
		for (i in 0...iData.length) {
			iData[i] = indices[i];
		}
		
		indexBuffer.unlock();
	}
	
	public function render(framebuffer:kha.Framebuffer) {
		var time = haxe.Timer.stamp() - firstTime;
		var g4 = framebuffer.g4;
		
		g4.begin();
		
		g4.setPipeline(pipeline);
		g4.setMatrix(cameraLocation, renderState.cameraMatrix);
		g4.setMatrix(perspectiveLocation, renderState.perspectiveMatrix);
		g4.setFloat(timeLocation, time);
		
		var offset = new kha.math.FastVector3();
		var hit:kha.math.Vector3 = null;
		g4.setIndexBuffer(indexBuffer);
		g4.setVertexBuffer(vertexBuffer);
		
		if(tex != null){
			g4.setTexture(texLocation, tex);
			g4.setTextureParameters(texLocation, TextureAddressing.Repeat, TextureAddressing.Repeat,
			TextureFilter.PointFilter, TextureFilter.PointFilter, kha.graphics4.MipMapFilter.NoMipFilter);
		}
		
		for(object in entityList) {
			offset.x = object.position.x;
			offset.y = object.position.y;
			offset.z = object.position.z;
			
			
			g4.setVector3(offsetLocation, offset);
			g4.setVector2(scaleLocation, object.scale);
			g4.setVector2(textureOriginLocation, object.origin);
			
			g4.drawIndexedVertices();
		}
		
		g4.end();
	}
	
	public function addObject(o:WorldObject) {
		entityList.push(o);
	}
}