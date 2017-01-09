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
		var g2 = f.getGraphics2();
		return;
		
		g2.begin(false);
		
		// UI Background
		///////////////////
		g2.color = kha.Color.White;
		g2.fillRect(0, f.height - 108, f.width, 108);
		
		if(font == null) {
			return;
		}
		
		if(state.userName != null && font != null) {
			g2.font = font;
			
			// User Name 
			///////////////
			if(state.userName != null) {
				g2.fontSize = 24;
				g2.color = kha.Color.fromString("#ff404040");
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
			
			// World Powers
			//////////////////
			if(this.state.powerCounts != null) {
				g2.color = kha.Color.fromString("#ff4E8EBE");
				var statusText = "";
				for(faction in this.state.powerCounts.keys()){
					statusText += faction + ": ";
					statusText += this.state.powerCounts[faction];
					statusText += ", ";
				}
				
				statusText = statusText.substr(0, statusText.length - 2);
				g2.fontSize = 16;
				var tWidth = this.font.width(16, statusText);
				
				g2.drawString(statusText, f.width - tWidth - 40, f.height - 6 - 54);

			}
		}
		
		g2.end();
	}
}