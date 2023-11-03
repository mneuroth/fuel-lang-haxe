/**
    Multi-line comments for documentation.
**/

class Main {
    static public function main():Void {
      trace("Hello World");
      var token = new LispToken.LispToken("1.2", 0, 2, 7);
      trace(token);
      var token2 = new LispToken.LispToken("42", 0, 2, 7);
      trace(token2);
      trace(Std.parseFloat("1.234d"));
      trace(haxe.Json.parse("1.234"));
    }
}
