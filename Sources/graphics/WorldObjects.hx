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
	var rotationLocation:ConstantLocation;
	var tileDataLocation:ConstantLocation;
	
	public var entityList:Array<WorldObject>;
	
	var state:game.GameState;
	var firstTime:Float;
	
	var renderState:graphics.RenderState;
	
	var vertexBuffer:VertexBuffer;
	var indexBuffer:IndexBuffer;
	
	var elfTex:kha.Image;
	var treeTex:kha.Image;
	var texLocation:kha.graphics4.TextureUnit;
	
	public function new(g:game.GameState, rs:graphics.RenderState) {
		renderState = rs;
		firstTime = kha.Scheduler.realTime();
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
		rotationLocation = pipeline.getConstantLocation("rotation");
		tileDataLocation = pipeline.getConstantLocation("tileData");
		
		texLocation = pipeline.getTextureUnit("tex");
		
		generateMesh();
		
		kha.Assets.loadImage(kha.Assets.images.elfName, function(img) {
			elfTex = img;
		});
		
		kha.Assets.loadImage(kha.Assets.images.treeleavesName, function(img) {
			treeTex = img;
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
	
	var aa = 0;
	public function render(g4:kha.graphics4.Graphics) {
		var time = kha.Scheduler.realTime() - firstTime;
		aa = Std.int(time * 16.0);
		
		g4.begin();
		
		g4.setPipeline(pipeline);
		g4.setMatrix(cameraLocation, renderState.cameraMatrix);
		g4.setMatrix(perspectiveLocation, renderState.perspectiveMatrix);
		g4.setFloat(timeLocation, time);
		
		var offset = new kha.math.FastVector3();
		var hit:kha.math.Vector3 = null;
		var tileData = new kha.math.FastVector4();
		g4.setIndexBuffer(indexBuffer);
		g4.setVertexBuffer(vertexBuffer);
		
		
		if(elfTex != null && treeTex != null){
			for(object in entityList) {
				offset.x = object.position.x;
				offset.y = object.position.y;
				offset.z = object.position.z;
			
				if(object.spriteSheet != null && object.spriteSheet.image != null) {
					g4.setTexture(texLocation, object.spriteSheet.image);
				}else{
					switch(object.sprite) {
						case Tree: 
							g4.setTexture(texLocation, treeTex);
						case Elf:
							g4.setTexture(texLocation, elfTex);
					}
				}
			
			
				g4.setTextureParameters(texLocation, 
					TextureAddressing.Repeat, TextureAddressing.Repeat,
					TextureFilter.PointFilter, TextureFilter.PointFilter,
					kha.graphics4.MipMapFilter.NoMipFilter
				);
				
				
				if(object.spriteSheet == null) {
					tileData.x = tileData.y = 0;
					tileData.z = tileData.w = 1.0;
				} else {
					var t = object.getCurrentFrame();
					tileData.x = t.uvx;
					tileData.y = t.uvy;
					tileData.z = object.spriteSheet.tilesX;
					tileData.w = object.spriteSheet.tilesY;
				}
				
				g4.setVector4(tileDataLocation, tileData);
				
				g4.setVector3(offsetLocation, offset);
				g4.setVector2(scaleLocation, object.scale);
				g4.setVector2(textureOriginLocation, object.origin);
				g4.setFloat(rotationLocation, object.rotation);
				
				g4.drawIndexedVertices();
			}
		}
		g4.end();
	}
	
	public function addObject(o:WorldObject) {
		entityList.push(o);
	}
	
	public function removeObject(o:WorldObject) {
		entityList.remove(o);
	}
}