package;

import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

class App {
	public function new() {
		System.notifyOnRender(render);
		Scheduler.addFrameTask(update, 0);
	}

	function update(): Void {
		
	}

	function render(framebuffer: Framebuffer): Void {		
	}
}
