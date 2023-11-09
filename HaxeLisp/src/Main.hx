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

      var scope = LispEnvironment.CreateDefaultScope();
      var ast = LispParser.Parse("(+ 1 2 3 4)");
      //var ast = LispParser.Parse("(fuel 1 2 3 4)");
      trace("AST:");
      trace(ast);
      var interpRes = LispInterpreter.EvalAst(ast, scope);
      trace("RESULT:",interpRes, "value=",interpRes.Value);
    }
}
