import utest.Assert;
import utest.Async;

class LispTokenizerTest extends utest.Test {
    public function testTokenizer1() {
        var tokens = LispTokenizer.LispTokenizer.Tokenize("");
        Assert.equals(0, tokens.length);
        var tokens = LispTokenizer.LispTokenizer.Tokenize("     \t \n   ");
        Assert.equals(0, tokens.length);
    }
    public function testTokenizer2() {
        var tokens = LispTokenizer.LispTokenizer.Tokenize("()");
        Assert.equals(2, tokens.length);
        var tokens = LispTokenizer.LispTokenizer.Tokenize("  (  \n    )  ");
        Assert.equals(2, tokens.length);
        Assert.equals("(", tokens.first().ToString());
        Assert.equals(")", tokens.last().ToString());
    }
    public function testTokenizer3() {
        var tokens = LispTokenizer.LispTokenizer.Tokenize("(+ 1 #t 3.1415 \"asdf blub\" #f )");
        var arrTokens:Array<LispToken> = new Array<LispToken>();
        for(tok in tokens) {
            arrTokens.push(tok);
        }
        Assert.equals(8, tokens.length);
        Assert.equals("(", tokens.first().ToString());
        Assert.equals(")", tokens.last().ToString());
        Assert.equals("+", arrTokens[1].ToString());
        Assert.equals(1, arrTokens[2].Value);
        Assert.equals(true, arrTokens[3].Value);
        Assert.equals(3.1415, arrTokens[4].Value);
        Assert.equals("asdf blub", arrTokens[5].Value);
        Assert.equals(false, arrTokens[6].Value);
    }
    public function testTokenizer4() {
        var tokens = LispTokenizer.LispTokenizer.Tokenize("(do (print (* 9 9)))");
        var arrTokens:Array<LispToken> = new Array<LispToken>();
        for(tok in tokens) {
            arrTokens.push(tok);
        }
        Assert.equals(11, tokens.length);
        Assert.equals("(", tokens.first().ToString());
        Assert.equals(")", tokens.last().ToString());
        Assert.equals("do", arrTokens[1].ToString());
        Assert.equals("(", arrTokens[2].ToString());
        Assert.equals("print", arrTokens[3].ToString());
        Assert.equals("(", arrTokens[4].ToString());
        Assert.equals("*", arrTokens[5].ToString());
        Assert.equals(9, arrTokens[6].Value);
        Assert.equals(9, arrTokens[7].Value);
        Assert.equals(")", arrTokens[8].ToString());
        Assert.equals(")", arrTokens[9].ToString());
        Assert.equals(")", arrTokens[10].ToString());
    }
}
