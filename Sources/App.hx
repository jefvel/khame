package;
import kha.math.Vector3;

import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

import kek.physics.SpringSystem;

class App {
	var springs:SpringSystem;
	var mouse:kha.input.Mouse;
	
	#if (sys_html5 || sys_debug_html5)
	var user:firebase.User;
	#end
	
	var font:kha.Font;
	var ui:game.UI;
	
	var gameState:game.GameState;
	var renderState:graphics.RenderState;
	var worldPowers:game.WorldPowers;
	
	var chunks:graphics.ChunkManager;
	var objects:graphics.WorldObjects;
	
	var inited = false;
	
	var entity:graphics.WorldObject;
	var guyTileSheet:kek.graphics.TileSheet;
	var presentTileSheet:kek.graphics.TileSheet;

	var frameBuffer:kek.graphics.PostprocessingBuffer;
	
	public function new() {
		frameBuffer = new kek.graphics.PostprocessingBuffer();
		gameState = new game.GameState();
		renderState = new graphics.RenderState(gameState);
		renderState.frameBuffer = frameBuffer;
		worldPowers = new game.WorldPowers(gameState);
		ui = new game.UI(gameState);
		
		chunks = new graphics.ChunkManager(gameState, renderState);
		
		objects = new graphics.WorldObjects(gameState, renderState);
		entity = new graphics.WorldObject();
		entity.origin.y = 0.0;
		entity.sprite = Elf;
		objects.addObject(entity);
		
		springs = new SpringSystem();
		System.notifyOnFrames(render);
		Scheduler.addFrameTask(update, 0);
		
		mouse = kha.input.Mouse.get();
		
		#if (sys_html5 || sys_debug_html5)
		var config = {
			apiKey: "AIzaSyDNW3ithvOf417WyzGUJl5bY30S7B_IH98",
			authDomain: "christmas2016-2e122.firebaseapp.com",
			databaseURL: "https://christmas2016-2e122.firebaseio.com",
			storageBucket: "christmas2016-2e122.appspot.com",
			messagingSenderId: "819275584692"
		};
		
		var app = firebase.Firebase.initializeApp(config);
		
		firebase.Firebase.auth().onAuthStateChanged(function(user) {
			this.user = user;
			
			if(this.user == null) {
			
			#if sys_debug_html5
				app.auth().signInWithEmailAndPassword("test@test.com", "testtest");
			#elseif sys_html5
				var authProvider = new firebase.auth.FacebookAuthProvider();
				authProvider.addScope("public_profile,user_posts");
				app.auth().signInWithRedirect(authProvider);
			#end
			
			} else {
				facebook.FB.init({
					appId      : '96688622773',
					xfbml      : true,
					version    : 'v2.8',
					cookie: true,
				});
				
				facebook.FB.getLoginStatus(function(e) {
					if(e.status == 'connected') {
						gameState.loggedInOnFacebook = true;
						worldPowers.refreshPowers();
					} else {
						gameState.loggedInOnFacebook = false;
					}
				});
				
				gameState.userId = user.uid;
				
				if(user.displayName != null) {
					gameState.userName = user.displayName;
				}else{
					gameState.userName = generateName();
				}
				
				gameState.loadState(function(data) {
					for(tree in data.trees) {
						var e = new graphics.WorldObject();
						
						e.origin.y = 0.11;
						e.scale.x = tree.size;
						e.scale.y = tree.size;
						
						e.position.x = tree.x;
						e.position.y = tree.y;
						e.position.z = tree.z;
						
						e.t = Math.random() * 10.0;
						objects.addObject(e);
					}
				});
				
				updateAvatar();
				
				if(!inited){
					mouse.notify(mouseDown, mouseUp, mouseMove, null);
				}
				
				inited = true;
			}
		});
		#end

		kha.Assets.loadEverything(function() {
			this.font = kha.Assets.fonts.Archive;
			ui.setFont(this.font);
			guyTileSheet = new kek.graphics.TileSheet(kha.Assets.images.elf, kha.Assets.blobs.elf_json);
			
			presentTileSheet = new kek.graphics.TileSheet(kha.Assets.images.present, kha.Assets.blobs.present_json);
			presentTileSheet.getAnimation("Spawn").looping = false;
			
			entity.spriteSheet = guyTileSheet;
		});
		
		kha.input.Keyboard.get().notify(function(k) {
			keydown = true;
		}, function(k) {
			keydown = false;
		});
		
		updateAvatar();
	}
	
	var keydown = false;
	
	function generateName() {
		return "Elf Boy";
	}
	
	function updateAvatar() {
		#if (sys_html5 || sys_debug_html5)
		if(gameState.userName != null) {
			var avatarUrl;
			var userName = gameState.userName;
			avatarUrl = 'https://api.adorable.io/avatars/64/$userName.io';
			
			if(user.photoURL != null) {
				avatarUrl = user.photoURL;
			}
			
			ui.loadAvatar(avatarUrl);
		}
		#end
	}
	
	var friction:Float = 0.9;
	var firstdown:Bool = false;
	
	var mdown = false;
	var moveX:Float = 0;
	var moveY:Float = 0;
	
	function mouseMove(x:Int, y:Int, dx:Int, dy:Int) {
	
		if(mdown && !firstdown) {
			renderState.mouseX = x;
			renderState.mouseY = y;
		
			moveX += dx;
			moveY += dy;
		}
		
		firstdown = false;
	}
	
	function mouseUp(i:Int, x:Int, y:Int) {
		mdown = false;
		firstdown = false;
	}
	
	function mouseDown(i:Int, x:Int, y:Int) {
		if(i == 1) {
			var e = new graphics.WorldObject();
			e.origin.y = 0.5;
			e.scale.x = 1.0;// + Math.random();
			e.scale.y = e.scale.x;
			
			var p = new Vector3();
			renderState.screenToWorldRay(x, y, p);
			
			p = chunks.intersection(renderState.cameraPosition, p);
			e.position = p;
			e.spriteSheet = presentTileSheet;
			e.t = Math.random() * 10.0;
			e.playAnimation("Spawn");
			objects.addObject(e);
			
			gameState.trees.push(new graphics.Tree(e.position.x, e.position.y, e.position.z, e.scale.x));

			return;
		}
		
		gameState.addCredits();
		mdown = true;
		firstdown = true;
		
		renderState.mouseX = x;
		renderState.mouseY = y;
	}

	function update(): Void {
		springs.update();
		
		if(mdown) {
			moveY = 0;
			moveX = 0;
			var r = new Vector3();
			renderState.screenToWorldRay(renderState.mouseX, renderState.mouseY, r);
			var p = chunks.intersection(renderState.cameraPosition, r);
			
			if(p != null) {
				
				gameState.targetX = p.x;
				gameState.targetY = p.y;
				
				renderState.cursorWorldPosition.x = p.x;
				renderState.cursorWorldPosition.y = p.y;
				renderState.cursorWorldPosition.z = p.z;
			}
			
		}else{
			moveX *= friction;
			moveY *= friction;
		}
		
		//gameState.playerX -= (moveX) * 0.1;
		//gameState.playerY += (moveY) * 0.1;
		
		
		var time = kha.Scheduler.realTime();
		for(tree in objects.entityList) {
			tree.rotation = Math.sin(tree.t + time) * 0.1;
		}
		
		var v = new kha.math.Vector2(gameState.targetX - gameState.playerX, gameState.targetY - gameState.playerY);
		var l = v.length;
		if(l < 0.1) {
			renderState.cursorWorldPosition.z -= 0.07;
		}
		
		if(l < 0.02) {
			entity.playAnimation("Stand", true);
		} else {
			entity.playAnimation("Walk", true);
		}
		
		var speed = 0.06;
		l *= 0.2;
		
		l = Math.min(l, speed);
		v.normalize();
		v = v.mult(l);
		
		gameState.playerX += v.x;
		gameState.playerY += v.y;
		
		#if (sys_debug_html5 || sys_html5)
		if(!gameState.loggedInOnFirebase) {
			return;
		}
		#end
		
		entity.position.x = gameState.playerX;
		entity.position.y = gameState.playerY;
		entity.position.z = 50.0;
		
		var direction = new Vector3(0, 0, -1.0);

		var hit = chunks.intersection(entity.position, direction);
		if(hit != null) {
			entity.origin.y = 1.0;
			entity.position.z = hit.z;
		}
		
		entity.origin.x = 0.5;
		entity.origin.y = 0.0;
		entity.rotation = 0.0;
		
		if(v.x > 0) {
			entity.scale.x = 1.0;
		}else if(v.x < 0) {
			entity.scale.x = -1.0;
		}
		entity.scale.y = 1.0;
		
		renderState.cameraTargetPos.x = entity.position.x;
		renderState.cameraTargetPos.y = entity.position.y;
		renderState.cameraTargetPos.z = entity.position.z;
		
		gameState.cameraX = gameState.playerX;
		gameState.cameraY = gameState.playerY;
		//entity.rotation = l * 0.2 * Math.sin(time * l * 300.0);
		//entity.origin.y = 0 -  0.3* l * Math.abs(Math.sin(time * l));
	}

	function render(framebuffers: Array<Framebuffer>): Void {
		var framebuffer = framebuffers[0];
		this.frameBuffer.begin(framebuffer);
		this.frameBuffer.clear(kha.Color.White, 1.0);
		
		#if (sys_html5 || sys_debug_html5)
		if(!gameState.loggedInOnFirebase) {
			return;
		}
		#end
		
		renderState.update(framebuffer);
		chunks.render(this.frameBuffer);
		objects.render(this.frameBuffer);
		
		if(ui != null) {
			ui.render(this.frameBuffer);
		}
		
		this.frameBuffer.end(framebuffer);
	}
}
