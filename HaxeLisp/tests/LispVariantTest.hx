import utest.Assert;
import utest.Async;

class LispVariantTest extends utest.Test {
    public function testVariant1() {
        var value = LispVariant.LispVariant.forValue(42);
        Assert.equals(LispVariant.LispType.Int, value.Type);
        Assert.equals(42, value.Value);
        var value = LispVariant.LispVariant.forValue(2.54);
        Assert.equals(LispVariant.LispType.Double, value.Type);
        Assert.equals(2.54, value.Value);
        var value = LispVariant.LispVariant.forValue("hello");
        Assert.equals(LispVariant.LispType.String, value.Type);
        Assert.equals("hello", value.Value);
        var value = LispVariant.LispVariant.forValue(false);
        Assert.equals(LispVariant.LispType.Bool, value.Type);
        Assert.equals(false, value.Value);
        var value = LispVariant.LispVariant.forValue(null);
        Assert.equals(LispVariant.LispType.Nil, value.Type);
        Assert.equals(null, value.Value);
    }
}
