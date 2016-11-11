package;

import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

import kha.graphics4.VertexStructure;
import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexData;
import kha.graphics4.Usage;
import kek.physics.SpringSystem;

class App {
	var pipeline:PipelineState;
	var springs:SpringSystem;
	var mouse:kha.input.Mouse;

	public function new() {
		springs = new SpringSystem();
		System.notifyOnRender(render);
		Scheduler.addFrameTask(update, 0);
		pipeline = new PipelineState();
		var layout = new VertexStructure();
		layout.add("pos", VertexData.Float3);
		pipeline.inputLayout = [layout];
		pipeline.vertexShader = kha.Shaders.test_vert;
		pipeline.fragmentShader = kha.Shaders.test_frag;
		pipeline.depthWrite = true;
		pipeline.depthMode = kha.graphics4.CompareMode.LessEqual;
		pipeline.compile();
		mouse = kha.input.Mouse.get();
		mouse.notify(mouseDown, mouseUp, mouseMove, null);
	}
	
	var friction:Float = 0.9;
	var firstdown:Bool = false;
	var mdown = false;
	var moveX:Float = 0;
	var moveY:Float = 0;
	var x:Float = 0;
	var y:Float = 0;
	
	function mouseMove(x:Int, y:Int, dx:Int, dy:Int) {
		trace('Mouse: $x, $y. Move: $dx, $dy');
		if(mdown && !firstdown) {
			moveX += dx;
			moveY += dy;
		}
		
		firstdown = false;
	}
	
	function mouseUp(x:Int, y:Int, i:Int) {
		trace('Up: $x, $y, $i');
		kha.SystemImpl.unlockMouse();
		mouse.showSystemCursor();
		mdown = false;
		firstdown = false;
	}
	
	function mouseDown(x:Int, y:Int, i:Int) {
		trace('Down: $x, $y, $i');
		kha.SystemImpl.lockMouse();
		mouse.hideSystemCursor();
		mdown = true;
		firstdown = true;
	}

	function update(): Void {
		
	}

	function render(framebuffer: Framebuffer): Void {		
		var g2 = framebuffer.g2;
		g2.begin();
		y += (moveY);
		x += (moveX);
		
		if(mdown) {
			moveY = 0;
			moveX = 0;
		}else{
			moveX *= friction;
			moveY *= friction;
		}
		
		//g2.setPipeline(pipeline);
		g2.clear(kha.Color.White); 
		g2.color = kha.Color.fromFloats(0.2, 0.4, 0.7);
		g2.drawLine(0, 0, 20 + x, 20 + y, 3);
		g2.end();
		//g2.begin(true, kha.Color.fromFloats(0.2, 0.4, 0.6));
		//g2.end();
	}
}
