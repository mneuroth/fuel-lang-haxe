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
        var token1 = new LispToken.LispToken("1.2", 0, 2, 7);
        var token2 = new LispToken.LispToken("3.4", 0, 2, 7);
        Assert.equals(token1.Type, token2.Type);
    }
    public function testToken3() {
        var token1 = new LispToken.LispToken("1.2", 0, 2, 7);
        var token2 = new LispToken.LispToken("3", 0, 2, 7);
        //Assert.notEquals(token1.Type, token2.Type);
    }
}
