package game;

class GameState {
	public var userName:String;
	public var userId:String;
	
	public var playerFaction:game.WorldPowers.Faction;
	
	public var loggedInOnFacebook:Bool;
	public var loggedInOnFirebase:Bool;
	
	public var credits:Int = -1;
	
	public var playerX:Float;
	public var playerY:Float;
	
	public var targetX:Float;
	public var targetY:Float;
	
	public var cameraX:Float;
	public var cameraY:Float;
	
	public var powerCounts:Map<game.WorldPowers.Faction, Int>;
	public var trees:Array<graphics.Tree>;
	
	#if (sys_html5 || sys_debug_html5)
	var playerRef:firebase.database.Reference;
	#end
	
	public function new() {
		trees = new Array<graphics.Tree>();
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
	
	inline function checkPlayerReference() {
	#if (sys_html5 || sys_debug_html5)
		if(playerRef == null) {
			if(userId != null) {
				playerRef = firebase.Firebase.database().ref('players/$userId');
			}
		}
	#end
	}
	
	public function loadState(?cb:GameState -> Void) {
	#if (sys_html5 || sys_debug_html5)
		checkPlayerReference();
		if(playerRef != null) {
			playerRef.once(Value).then(function(e){
				var value = e.val();
				
				if(value == null) {
					createState();
					return;
				}
				
				this.credits = defaultOrValue(value.credits, 0);
				this.playerX = defaultOrValue(value.playerX, 100);
				this.playerY = defaultOrValue(value.playerY, 100);
				
				this.targetX = defaultOrValue(value.targetX, 100);
				this.targetY = defaultOrValue(value.targetY, 100);
				
				this.userName = defaultOrValue(value.userName, null);
				
				if(this.playerFaction == null) {
					this.playerFaction = defaultOrValue(value.playerFaction, WorldPowers.Faction.None);
				}
				
				if(value.trees != null) {
					var t:Array<Dynamic> = value.trees;
					for(tree in t) {
						trees.push(new graphics.Tree(tree.x, tree.y, tree.z, tree.size));
					}
				}
				
				this.loggedInOnFirebase = true;
				if(cb != null) {
					cb(this);
				}
			});
		}
	#end
	}
	
	public function saveState() {
	#if (sys_html5 || sys_debug_html5)
		checkPlayerReference();
		
		if(playerRef != null) {
			playerRef.update({
				userName: this.userName,
				credits: this.credits,
				playerX: this.playerX,
				playerY: this.playerY,
				targetX: this.targetX,
				targetY: this.targetY,
				playerFaction: this.playerFaction,
				trees: this.trees
			});
		}
	#end
	}
}