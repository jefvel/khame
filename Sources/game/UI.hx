package game;

class UI {

	var font:kha.Font;
	var state:GameState;
	var avatar:kha.Image;
	
	public function new(font:kha.Font, gameState:GameState){
		this.font = font;
		this.state = gameState;
	}
	
	var creditIncrease = 0.0;
	var lastCredits = 0.0;
	
	public function loadAvatar(url:String) {
		kha.Assets.loadImageFromPath(url, true,
		function(image) {
			this.avatar = image;
		});
	}
	
	public function render(f:kha.Framebuffer) {
		var g2 = f.g2;
		
		g2.begin(false);
		
		g2.color = kha.Color.White;
		g2.fillRect(0, f.height - 108, f.width, 108);
		
		if(state.userName != null && font != null) {
			g2.font = font;
			
			// User Name 
			///////////////
			if(state.userName != null) {
				g2.fontSize = 24;
				g2.color = kha.Color.Black;
				g2.drawString(state.userName, 64 + 20 + 20, f.height - 24 - 20 - 32);
			}
			
			// Credits
			//////////////
			var creditScaleIncrease = 0;
			if(state.credits != null) {
				creditIncrease = ((state.credits - lastCredits) * 0.1);
				lastCredits += creditIncrease;
				creditScaleIncrease = Std.int(Math.min(Math.abs(creditIncrease) * 10.0, 10.0) * (1 + Math.random() * 0.4));
				
				g2.fontSize = 16 + creditScaleIncrease;
				g2.drawString("" + Std.int(Math.round(lastCredits)), 64 + 20 + 20, f.height - 24 - 20 - 4);
			}
			

			// Own Avatar
			////////////////
			if(avatar != null) {
				g2.color = kha.Color.White;
				g2.drawScaledImage(avatar, 20, f.height - 20 - 64, 64, 64);
			}
		}
		
		g2.end();
	}
}