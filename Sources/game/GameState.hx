package game;

class GameState {
	
	public var credits:Int = -1;
	
	public var playerX:Float;
	public var playerY:Float;
	
	public var targetX:Float;
	public var targetY:Float;
	
	public var cameraX:Float;
	public var cameraY:Float;
	
	public var trees:Array<graphics.Tree>;
	
	public function new() {
		trees = new Array<graphics.Tree>();
		createState();
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
		this.targetX = 100;
		this.targetY = 100;
		saveState();
	}
	
	inline function checkPlayerReference() {
	}
	
	public function loadState(?cb:GameState -> Void) {
	}
	
	public function saveState() {
	}
}