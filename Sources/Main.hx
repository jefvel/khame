package;

import kha.System;

class Main {
	public static function main() {
		System.start({title: "Khame", width: 800, height: 600}, function(window) {
			new App();
		});
	}
}
