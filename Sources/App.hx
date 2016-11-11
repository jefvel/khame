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
		var mouse = kha.input.Mouse.get();
		mouse.notify(mouseDown, null, null, null);
	}
	
	function mouseDown(x:Int, y:Int, i:Int) {
		trace('$x, $y, $i');
	}

	function update(): Void {
		
	}

	function render(framebuffer: Framebuffer): Void {		
		var g2 = framebuffer.g4;
		g2.begin();
		g2.setPipeline(pipeline);
		g2.clear(kha.Color.fromFloats(0.2, 0.4, 0.7));
		g2.end();
		//g2.begin(true, kha.Color.fromFloats(0.2, 0.4, 0.6));
		//g2.end();
	}
}
