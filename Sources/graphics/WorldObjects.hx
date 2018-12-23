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
	
	var offsetLocation:ConstantLocation;
	var scaleLocation:ConstantLocation;
	var textureOriginLocation:ConstantLocation;
	var rotationLocation:ConstantLocation;
	var tileDataLocation:ConstantLocation;
	
	var screenDataLocation:ConstantLocation;
	
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
		
		offsetLocation = pipeline.getConstantLocation("offset");
		scaleLocation = pipeline.getConstantLocation("scale");
		textureOriginLocation = pipeline.getConstantLocation("spriteOrigin");
		rotationLocation = pipeline.getConstantLocation("rotation");
		tileDataLocation = pipeline.getConstantLocation("tileData");
		screenDataLocation = pipeline.getConstantLocation("screenData");
		
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
		vStructure.add("pos", VertexData.Float2);
		vStructure.add("uv", VertexData.Float2);
		vertexBuffer = new VertexBuffer(4, vStructure, Usage.StaticUsage);
		
		var s = 1.0;
		var m = 0.0;
		
		var verts = [
			m,   s,
			0.0, 0.0,
			
			m,   m,
			0.0, 1.0,
			
			s,   m,
			1.0, 1.0,
			
			s,   s,
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
	
	public function render(g:kek.graphics.PostprocessingBuffer) {
		var g4 = g.graphics;
		var time = kha.Scheduler.realTime() - firstTime;
		
		g4.setPipeline(pipeline);
		g4.setMatrix(cameraLocation, renderState.cameraMatrix);
		g4.setMatrix(perspectiveLocation, renderState.perspectiveMatrix);
		
		g4.setFloat4(screenDataLocation,
			g.width, g.height,
			g.pixelSize, g.pixelSize);
			
		var offset = new kha.math.FastVector3();
		var hit:kha.math.Vector3 = null;
		var tileData = new kha.math.FastVector4();
		
		g4.setIndexBuffer(indexBuffer);
		g4.setVertexBuffer(vertexBuffer);
		
		var spriteSize = new kha.math.FastVector2();
		
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
							spriteSize.x = treeTex.width;
							spriteSize.y = treeTex.height;
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
					
					spriteSize.x = t.w;
					spriteSize.y = t.h;
				}
				
				g4.setVector4(tileDataLocation, tileData);
				
				g4.setVector3(offsetLocation, offset);
				
				spriteSize.x *= object.scale.x;
				spriteSize.y *= object.scale.y;
				/*
				spriteSize.x *= g.pixelSize;
				spriteSize.y *= g.pixelSize;
				*/
				g4.setVector2(scaleLocation, spriteSize);
				g4.setVector2(textureOriginLocation, object.origin);
				g4.setFloat(rotationLocation, object.rotation);
				
				g4.drawIndexedVertices();
			}
		}
		
		//g4.end();
	}
	
	public function addObject(o:WorldObject) {
		entityList.push(o);
	}
	
	public function removeObject(o:WorldObject) {
		entityList.remove(o);
	}
}