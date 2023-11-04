import utest.Assert;
import utest.Async;

class LispTokenTest extends utest.Test {
    public function testToken1() {
        var token = new LispToken.LispToken("1.2", 0, 2, 7);
        Assert.equals(1.2, token.Value);
        Assert.equals(Type.enumConstructor(token.Type), "Double");
        Assert.equals(0, token.StartPos);
    }
    public function testToken2() {
        var token = new LispToken.LispToken("1.2abc", 0, 5, 7);
        Assert.equals("1.2abc", token.Value);
        Assert.equals(Type.enumConstructor(token.Type), "Symbol");
        Assert.equals(0, token.StartPos);
    }
    public function testToken3() {
        var token = new LispToken.LispToken("421", 0, 2, 7);
        Assert.equals(421, token.Value);
        Assert.equals(Type.enumConstructor(token.Type), "Int");
        Assert.equals(0, token.StartPos);
    }
    public function testToken4() {
        var token1 = new LispToken.LispToken("1.2", 0, 2, 7);
        var token2 = new LispToken.LispToken("3.4", 0, 2, 7);
        Assert.equals(token1.Type, token2.Type);
    }
    public function testToken5() {
        var token1 = new LispToken.LispToken("1.2", 0, 2, 7);
        var token2 = new LispToken.LispToken("3", 0, 1, 7);
        Assert.notEquals(token1.Type, token2.Type);
    }
}
