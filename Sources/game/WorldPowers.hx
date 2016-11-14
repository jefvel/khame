package game;

@:enum
abstract Faction(String) {
	var None = "NONE";
	var Like = "LIKE";
	var Love = "LOVE";
	var Wow = "WOW";
	var Haha = "HAHA";
	var Sad = "SAD";
	var Angry = "ANGRY";
	var Thankful = "THANKFUL";
}

class WorldPowers {
	public var powerCounts:Map<Faction, Int>;
	public var gameState:game.GameState;
	public function new(state:GameState) {
		powerCounts = new Map<Faction, Int>();
		gameState = state;
	}
	
	public function refreshPowers() {
		if(gameState.loggedInOnFacebook) {
			var postId = "";
			
			//Own
			postId = "10154575577633260";
			
			// INet test
			postId = "207342968259_10154575577633260";
			
			//Treeplant test
			postId = "529364633940911_529365643940810";
			
			facebook.FB.api("/" + postId, get, {
				fields: 'reactions.type(LIKE).limit(0).summary(true).as(like),
						reactions.type(LOVE).limit(0).summary(true).as(love),
						reactions.type(WOW).limit(0).summary(true).as(wow),
						reactions.type(HAHA).limit(0).summary(true).as(haha),
						reactions.type(SAD).limit(0).summary(true).as(sad),
						reactions.type(ANGRY).limit(0).summary(true).as(angry),
						reactions.type(THANKFUL).limit(0).summary(true).as(thankful)'
			}, function(e) {
			
				powerCounts[Angry] = e.angry.summary.total_count;
				powerCounts[Like] = e.like.summary.total_count;
				powerCounts[Love] = e.love.summary.total_count;
				powerCounts[Wow] = e.wow.summary.total_count;
				powerCounts[Haha] = e.haha.summary.total_count;
				powerCounts[Thankful] = e.thankful.summary.total_count;
				powerCounts[Sad] = e.sad.summary.total_count;
				
				switch(e.like.summary.viewer_reaction) {
					case "LIKE":
						gameState.playerFaction = Like;
					case "LOVE":
						gameState.playerFaction = Love;
					case "WOW":
						gameState.playerFaction = Wow;
					case "HAHA":
						gameState.playerFaction = Haha;
					case "THANKFUL":
						gameState.playerFaction = Thankful;
					case "SAD":
						gameState.playerFaction = Sad;
					case "ANGRY":
						gameState.playerFaction = Angry;
				}
				
				gameState.powerCounts = this.powerCounts;
				
				trace(powerCounts);
				trace(gameState.playerFaction);
				
			});
		}
	}
}