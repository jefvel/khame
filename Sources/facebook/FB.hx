package facebook;

enum ApiMethod {
    get;
    post;
    delete;
}

#if (sys_html5 || sys_debug_html5)
@:native("FB") extern class FB {
    public static function init(config:Dynamic):Void;
    public static function login(?cb:Dynamic -> Void, options:Dynamic):Void;
    public static function api(path:String, method:ApiMethod = get, ?params:Dynamic, ?callback:Dynamic -> Void):Void;
    public static function getLoginStatus(cb:Dynamic -> Void):Void;
}
#end