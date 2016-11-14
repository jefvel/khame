package game;

class GameState {
	public var userName:String;
	public var userId:String;
	
	public var playerFaction:game.WorldPowers.Faction;
	
	public var loggedInOnFacebook:Bool;
	public var loggedInOnFirebase:Bool;
	
	public var credits:Int;
	
	public var playerX:Float;
	public var playerY:Float;
	
	public var cameraX:Float;
	public var cameraY:Float;
	
	public var powerCounts:Map<game.WorldPowers.Faction, Int>;
	
	public function new() {

	}
	
	public function addCredits() {
		this.credits += 50;
		saveState();
	}
	
	inline function defaultOrValue(?value:Dynamic, def:Dynamic):Dynamic {
		if(value == null){
			return def;
		}
		
		return value;
	}
	
	public function createState() {
		this.credits = 0;
		this.playerX = 100;
		this.playerY = 100;
		saveState();
	}
	
	public function loadState() {
		if(userId != null) {
			firebase.Firebase.database().ref('players/$userId').once(firebase.EventType.value).then(function(e){
				var value = e.val();
				
				if(value == null) {
					createState();
					return;
				}
				
				this.credits = defaultOrValue(value.credits, 0);
				this.playerX = defaultOrValue(value.playerX, 100);
				this.playerY = defaultOrValue(value.playerY, 100);
				this.userName = defaultOrValue(value.userName, null);
				
				if(this.playerFaction == null) {
					this.playerFaction = defaultOrValue(value.playerFaction, WorldPowers.Faction.None);
				}
			});
		}
	}
	
	public function saveState() {
		if(userId != null) {
			firebase.Firebase.database().ref('players/$userId').set({
				userName: this.userName,
				credits: this.credits,
				playerX: this.playerX,
				playerY: this.playerY,
				playerFaction: this.playerFaction
			});
		}
	}
}