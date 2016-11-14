package;

import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

import kha.graphics4.VertexStructure;
import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexData;
import kha.graphics4.Usage;
import kek.physics.SpringSystem;

class App {
	var pipeline:PipelineState;
	var springs:SpringSystem;
	var mouse:kha.input.Mouse;
	
	var userAvatar:js.html.ImageElement;
	var user:firebase.User;
	
	var font:kha.Font;
	var ui:game.UI;
	
	var gameState:game.GameState;
	
	var inited = false;
	
	public function new() {
		userAvatar = cast js.Browser.document.getElementById("avatar-img");
		gameState = new game.GameState();
		
		springs = new SpringSystem();
		System.notifyOnRender(render);
		Scheduler.addFrameTask(update, 0);
		
		pipeline = new PipelineState();
		var layout = new VertexStructure();
		layout.add("pos", VertexData.Float3);
		pipeline.inputLayout = [layout];
		pipeline.vertexShader = kha.Shaders.test_vert;
		pipeline.fragmentShader = kha.Shaders.test_frag;
		pipeline.depthWrite = true;
		pipeline.depthMode = kha.graphics4.CompareMode.LessEqual;
		pipeline.compile();
		mouse = kha.input.Mouse.get();
		
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
			#elseif(sys_html5)
				trace("authenticating with facebook");
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
							trace(e);
						});
					} else {
						gameState.loggedInOnFacebook = false;
					}
				});
				
				gameState.userId = user.uid;
				
				var email = user.email;
				
				if(user.displayName != null) {
					gameState.userName = user.displayName;
				}else{
					gameState.userName = generateName();
				}
				
				gameState.loadState();
				
				updateAvatar();
				
				if(!inited){
					mouse.notify(mouseDown, mouseUp, mouseMove, null);
				}
				
				inited = true;
				
				gameState.loggedInOnFirebase = true;
			}
		});
		
		
		kha.Assets.loadEverything(function() {
			this.font = kha.Assets.fonts.Archive;
			ui = new game.UI(this.font, gameState);
		});
		
		updateAvatar();
	}
	
	var img:kha.Image;
	function generateName() {
		return "Elf Boy";
	}
	
	function updateAvatar() {
		if(gameState.userName != null) {
			var avatarUrl;
			var userName = gameState.userName;
			avatarUrl = 'https://api.adorable.io/avatars/64/$userName.io';
			
			if(user.photoURL != null) {
				avatarUrl = user.photoURL;
			}
			
			ui.loadAvatar(avatarUrl);
		}
	}
	
	var friction:Float = 0.9;
	var firstdown:Bool = false;
	var mdown = false;
	var moveX:Float = 0;
	var moveY:Float = 0;
	
	function mouseMove(x:Int, y:Int, dx:Int, dy:Int) {
		//trace('Mouse: $x, $y. Move: $dx, $dy');
		if(mdown && !firstdown) {
			moveX += dx;
			moveY += dy;
		}
		
		firstdown = false;
	}
	
	function mouseUp(x:Int, y:Int, i:Int) {
		kha.SystemImpl.unlockMouse();
		mouse.showSystemCursor();
		mdown = false;
		firstdown = false;
	}
	
	function mouseDown(x:Int, y:Int, i:Int) {
		kha.SystemImpl.lockMouse();
		gameState.addCredits();
		mouse.hideSystemCursor();
		mdown = true;
		firstdown = true;
	}

	function update(): Void {
		springs.update();
	}

	function render(framebuffer: Framebuffer): Void {		
		var g2 = framebuffer.g2;
		g2.begin();
		g2.clear(kha.Color.White); 
		g2.color = kha.Color.White;
		
		gameState.playerX += (moveX);
		gameState.playerY += (moveY);
		
		if(mdown) {
			moveY = 0;
			moveX = 0;
		}else{
			moveX *= friction;
			moveY *= friction;
		}
		
		g2.color = kha.Color.fromFloats(0.2, 0.4, 0.7);
		g2.drawLine(0, 0, gameState.playerX, gameState.playerY, 3);
		g2.end();
		
		if(ui != null) {
			ui.render(framebuffer);
		}
	}
}
