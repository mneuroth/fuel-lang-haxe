import utest.Assert;
import utest.Async;

class LispParserTest extends utest.Test {
    public function testParser1() {
        var result = LispParser.LispParser.Parse("()");
        Assert.equals(0, result.length);
    }
    public function testParser2() {
        var result = LispParser.LispParser.Parse("(print 1 2.54 \"string\")");
        Assert.equals(4, result.length);
        Assert.equals("print", result[0].Value);
        Assert.equals(LispVariant.LispType.Symbol, result[0].Type);
        Assert.equals(1, result[1].Value);
        Assert.equals(LispVariant.LispType.Int, result[1].Type);
        Assert.equals(2.54, result[2].Value);
        Assert.equals(LispVariant.LispType.Double, result[2].Type);
        Assert.equals("string", result[3].Value);
        Assert.equals(LispVariant.LispType.String, result[3].Type);
    }
    public function testParser3() {
        var result = LispParser.LispParser.Parse("(do (print #t 2.54 \"string\"))");
        Assert.equals(2, result.length);
        Assert.equals("do", result[0].Value);
        Assert.equals(LispVariant.LispType.Symbol, result[0].Type);
        var temp = result[1].copy();    // copy() because of a bug in Haxe ??? Array access is not allowed on Unknown<0>
        Assert.isTrue(temp is Array);
        Assert.equals(4, temp.length);     
        Assert.equals("print", temp[0].Value);
        Assert.equals(LispVariant.LispType.Symbol, temp[0].Type);
        Assert.equals(true, temp[1].Value);
        Assert.equals(LispVariant.LispType.Bool, temp[1].Type);
        Assert.equals(2.54, temp[2].Value);
        Assert.equals(LispVariant.LispType.Double, temp[2].Type);
        Assert.equals("string", temp[3].Value);
        Assert.equals(LispVariant.LispType.String, temp[3].Type);
    }
}
