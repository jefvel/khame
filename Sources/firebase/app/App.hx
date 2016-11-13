package firebase.app;

extern class App {
	public var name(default, null):String;
	public var options:Dynamic;
	public function auth():firebase.auth.Auth;
	public function database():firebase.database.Database;
	public function delete():Dynamic;
	public function storage():Dynamic;
}
