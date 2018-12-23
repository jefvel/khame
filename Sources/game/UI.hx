package game;

class UI {

	var font:kha.Font;
	var state:GameState;
	var avatar:kha.Image;
	
	public function new(gameState:GameState){
		this.state = gameState;
	}
	
	public function setFont(font:kha.Font) {
		this.font = font;
	}
	
	var creditIncrease = 0.0;
	var lastCredits = 0.0;
	
	public function loadAvatar(url:String) {
		kha.Assets.loadImageFromPath(url, true,
		function(image) {
			this.avatar = image;
		});
	}
	
	public function render(f:kek.graphics.PostprocessingBuffer) {
		var g2 = f.g2;
		return;
		
		g2.begin(false);
		
		// UI Background
		///////////////////
		g2.color = kha.Color.White;
		g2.fillRect(0, f.height - 108, f.width, 108);
		
		if(font == null) {
			return;
		}
		
		
		g2.end();
	}
}