import utest.Assert;
import utest.Async;

class LispTokenTest extends utest.Test {
    public function testToken1() {
        var token = new LispToken.LispToken("1.2", 0, 2, 7);
        Assert.equals(1.2, token.Value);
    }
}