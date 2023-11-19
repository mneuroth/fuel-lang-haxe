/*
 * FUEL(isp) is a fast usable embeddable lisp interpreter.
 *
 * Copyright (c) 2023 Michael Neuroth
 *
 * Permission is hereby granted, free of charge, to any person obtaining 
 * a copy of this software and associated documentation files (the "Software"), 
 * to deal in the Software without restriction, including without limitation 
 * the rights to use, copy, modify, merge, publish, distribute, sublicense, 
 * and/or sell copies of the Software, and to permit persons to whom the 
 * Software is furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included 
 * in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR 
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR 
 * OTHER DEALINGS IN THE SOFTWARE.
 * 
 * */

import utest.Assert;
import utest.Async;

class LispInterpreterTest extends utest.Test {
    public function testInterpreter1() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(fuel)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals("fuel version v0.99.4 from 11.11.2023", result.Value);
    }
    public function testInterpreter2() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(+ 1 2 3 4)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(10, result.Value);
    }
    public function testInterpreter3() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(- 42 2 1)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(39, result.Value);
    }
    public function testInterpreter4() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(* 2 3 5)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(30, result.Value);
    }
    public function testInterpreter5() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(* 2.4 3.2)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(7.68, result.Value);
    }
    public function testInterpreter6() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(/ 24 2)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(12, result.Value);
    }
    public function testInterpreter7() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(% 7 2)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(1, result.Value);
    }
    public function testInterpreter8() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(< 7 2)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(false, result.Value);
        var ast = LispParser.Parse("(< 2 7)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(true, result.Value);
        var ast = LispParser.Parse("(< 3 3)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(false, result.Value);
    }
    public function testInterpreter9() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(> 7 2)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(true, result.Value);
        var ast = LispParser.Parse("(> 2 7)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(false, result.Value);
        var ast = LispParser.Parse("(> 3 3)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(false, result.Value);
    }
    public function testInterpreter10() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(<= 7 2)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(false, result.Value);
        var ast = LispParser.Parse("(<= 2 7)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(true, result.Value);
        var ast = LispParser.Parse("(<= 3 3)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(true, result.Value);
    }
    public function testInterpreter11() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(>= 7 2)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(true, result.Value);
        var ast = LispParser.Parse("(>= 2 7)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(false, result.Value);
        var ast = LispParser.Parse("(>= 3 3)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(true, result.Value);
    }
    public function testInterpreter12() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(equal 7 7)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(true, result.Value);
        var ast = LispParser.Parse("(equal 8 7)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(false, result.Value);
        var ast = LispParser.Parse("(= 17 17)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(true, result.Value);
        var ast = LispParser.Parse("(== 18 17)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(false, result.Value);
    }
    public function testInterpreter13() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(!= 17 7)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(true, result.Value);
        var ast = LispParser.Parse("(!= 8 8)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(false, result.Value);
    }
    public function testInterpreter14() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(do (defn f (x) (+ x 1) ) (f 7))");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(8, result.Value);
    }
    public function testInterpreter15() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(do (if (== 4 5) -1 1))");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(1, result.Value);
    }
    public function testInterpreter16() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(do (def i 1) (while (< i 5) (setf i (+ i 1))))");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(5, result.Value);
    }
    public function testInterpreter17() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(do (def i 1) (setf i (+ i 1)))");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(2, result.Value);
    }
    public function testInterpreter18() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(do (or #f #f))");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(false, result.Value);
        ast = LispParser.Parse("(do (or #t #f))");
        result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(true, result.Value);
        ast = LispParser.Parse("(do (or #f #t))");
        result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(true, result.Value);
        ast = LispParser.Parse("(do (or #t #t))");
        result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(true, result.Value);
    }
    public function testInterpreter19() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(do (and #f #f))");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(false, result.Value);
        ast = LispParser.Parse("(do (and #t #f))");
        result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(false, result.Value);
        ast = LispParser.Parse("(do (and #f #t))");
        result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(false, result.Value);
        ast = LispParser.Parse("(do (and #t #t))");
        result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(true, result.Value);
    }
    public function testInterpreter20() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(! #f)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(true, result.Value);
        var ast = LispParser.Parse("(! #t)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(false, result.Value);
        var ast = LispParser.Parse("(not #f)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals(true, result.Value);
    }
    public function testInterpreter21() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(list 1 2 3 4)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals("(1 2 3 4)", result.ToString());
        var ast = LispParser.Parse("(quote (1 2 3 4))");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals("(1 2 3 4)", result.ToString());
        var res = Lisp.Eval("'(1 2 3)");
        Assert.equals("(1 2 3)", res.ToString());
        var res = Lisp.Eval("'(1 2 3 4)");
        Assert.equals("(1 2 3 4)", res.ToString());
        //var ast2 = LispParser.Parse("'(1 2 3 4)");
        //var result2 = LispInterpreter.EvalAst(ast2, scope);
        //Assert.equals("(1 2 3 4)", result2.ToString());
    }
    public function testInterpreter22() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(map (lambda (x) (* x x)) (list 1 2 3 4))");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals("(1 4 9 16)", result.ToString());
    }
    public function testInterpreter23() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(reduce (lambda (x y) (+ x y)) (list 1 2 3 4) 0)");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals("10", result.ToString());
    }
    public function testInterpreter24() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(cons 8 (list 4 3 2 1))");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals("(8 4 3 2 1)", result.ToString());
    }
    public function testInterpreter25() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(len (list 4 3 2 1))");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals("4", result.ToString());
        var ast = LispParser.Parse("(len \"Hello\")");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals("5", result.ToString());
// TODO -> len for Dictionary        
    }
    public function testInterpreter26() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(car (list 17 4 3 2 1))");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals("17", result.ToString());
        var ast = LispParser.Parse("(car \"Hello\")");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals("H", result.ToString());
        var ast = LispParser.Parse("(first (list 42.2 4 3 2 1))");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals("42.2", result.ToString());
    }
    public function testInterpreter27() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(last (list 17 4 3 2 1))");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals("1", result.ToString());
        var ast = LispParser.Parse("(last \"Hello\")");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals("o", result.ToString());
    }
    public function testInterpreter28() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(rest (list 17 4 3 2 1))");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals("(4 3 2 1)", result.ToString());
        var ast = LispParser.Parse("(rest \"Hello\")");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals("ello", result.ToString());
        var ast = LispParser.Parse("(cdr (list 2 1))");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals("(1)", result.ToString());
    }
    public function testInterpreter29() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(nth 2 (list 17 4 3 2 1))");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals("3", result.ToString());
        var ast = LispParser.Parse("(nth -1 (list 17 4 3 2 1))");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals("NIL", result.ToString());
        var ast = LispParser.Parse("(nth 10 (list 17 4 3 2 1))");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals("NIL", result.ToString());
    }
    public function testInterpreter30() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(push 42 (list 4 3 2 1))");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals("(42 4 3 2 1)", result.ToString());
    }
    public function testInterpreter31() {
        var scope = LispEnvironment.CreateDefaultScope();
        var ast = LispParser.Parse("(pop (list 4 3 2 1))");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals("4", result.ToString());
        var ast = LispParser.Parse("(do (def l (list 5 4 3 2 1)) (pop l) (print l))");
        var result = LispInterpreter.EvalAst(ast, scope);
        Assert.equals("(4 3 2 1)", result.ToString());
        var res = Lisp.Eval("(pop (list 4 6 1))");
        Assert.equals("4", res.ToString());
    }
    public function testInterpreter32() {
        var res = Lisp.Eval("(append (list 1 2 3 4) (list 9 8 7))");
        Assert.equals("(1 2 3 4 9 8 7)", res.ToString());
        var res = Lisp.Eval("(append (list 1 2 3 4) (list 42) (list 99 -1))");
        Assert.equals("(1 2 3 4 42 99 -1)", res.ToString());
    }
    public function testInterpreter33() {
        var res = Lisp.Eval("(reverse (list 1 2 3 4))");
        Assert.equals("(4 3 2 1)", res.ToString());
        var res = Lisp.Eval("(reverse \"hello!\")");
        Assert.equals("!olleh", res.ToString());
    }
    public function testInterpreter34() {
        var res = Lisp.Eval("(str (+ 1 2))");
        Assert.equals("3", res.ToString());
    }
    public function testInterpreter35() {
        var res = Lisp.Eval("(str (+ 1 2))");
        Assert.equals("3", res.ToString());
    }
    public function testInterpreter36() {
        var res = Lisp.Eval("(quote (+ 1 2))");
        Assert.equals("(+ 1 2)", res.ToString());
        var res = Lisp.Eval("'(+ 1 2 4 2.3)");
        Assert.equals("(+ 1 2 4 2.3)", res.ToString());
    }
    public function testInterpreter37() {
        var res = Lisp.Eval("(do (defn test (x y) (argscount)) (def x (test 4 5)))");
        Assert.equals("2", res.ToString());
    }
    public function testInterpreter38() {
        var res = Lisp.Eval("(do (defn test (x y) (args)) (def x (test 4 5)))");
        Assert.equals("(4 5)", res.ToString());
    }
    public function testInterpreter39() {
        var res = Lisp.Eval("(do (defn test (x y) (arg 1)) (def x (test 4 5)))");
        Assert.equals("5", res.ToString());
        var res = Lisp.Eval("(do (defn test (x y) (arg 0)) (def x (test 4 5)))");
        Assert.equals("4", res.ToString());
        //var res = Lisp.Eval("(do (defn test (x y) (arg 3)) (def x (test 4 5)))");     //TODO -> check for exception
        //Assert.equals("4", res.ToString());
    }
    public function testInterpreter40() {
        var res = Lisp.Eval("(do (defn test (x y) (+ x y 1)) (apply test '(4 5)))");
        Assert.equals("10", res.ToString());
    }
    public function testInterpreter41() {
        var res = Lisp.Eval("(eval '(+ 1 2 3))");
        Assert.equals("6", res.ToString());
    }
    public function testInterpreter42() {
        var res = Lisp.Eval("(evalstr \"(* 4 2 3)\")");
        Assert.equals("24", res.ToString());
    }
    public function testInterpreter43() {
        var res = Lisp.Eval("(upper-case \"Hallo 2 Welt! öÄü\")");
        Assert.equals("HALLO 2 WELT! ÖÄÜ", res.ToString());
        var res = Lisp.Eval("(lower-case \"Hallo 2 Welt! öÄü\")");
        Assert.equals("hallo 2 welt! öäü", res.ToString());

        // var res = Lisp.Eval("(upper-case \"Hallo 2 Welt!\")");
        // Assert.equals("HALLO 2 WELT!", res.ToString());
        // var res = Lisp.Eval("(lower-case \"Hallo 2 Welt!\")");
        // Assert.equals("hallo 2 welt!", res.ToString());
    }
    public function testInterpreter44() {
        var res = Lisp.Eval("(trim \"  hallo Welt  \")");
        Assert.equals("hallo Welt", res.ToString());
    }
    public function testInterpreter45() {
        var res = Lisp.Eval("(replace \"Hallo Welt\" \"Welt\" \"earth\")");
        Assert.equals("Hallo earth", res.ToString());
    }
    public function testInterpreter46() {
        var res = Lisp.Eval("(slice \"Hallo my World\" 6 2)");
        Assert.equals("my", res.ToString());
    }
    public function testInterpreter47() {
        var res = Lisp.Eval("(search \"my\" \"Hallo my World\")");
        Assert.equals("6", res.ToString());
    }
    public function testInterpreter48() {
        var res = Lisp.Eval("(float \"1.234\")");
        Assert.equals("1.234", res.ToString());
        var res = Lisp.Eval("(float 42)");
        Assert.equals("42", res.ToString());
        var res = Lisp.Eval("(float 7.89)");
        Assert.equals("7.89", res.ToString());
    }
    public function testInterpreter49() {
        var res = Lisp.Eval("(int \"1.234\")");
        Assert.equals("1", res.ToString());
        var res = Lisp.Eval("(int 42)");
        Assert.equals("42", res.ToString());
        var res = Lisp.Eval("(int 7.89)");
        Assert.equals("7", res.ToString());
    }
    public function testInterpreter50() {
        var res = Lisp.Eval("(parse-float \"1.234\")");
        Assert.equals("1.234", res.ToString());
        var res = Lisp.Eval("(parse-float 42)");
        Assert.equals("42", res.ToString());
        var res = Lisp.Eval("(parse-float 7.89)");
        Assert.equals("7.89", res.ToString());
    }
    public function testInterpreter51() {
        var res = Lisp.Eval("(parse-integer \"1.234\")");
        Assert.equals("1", res.ToString());
        var res = Lisp.Eval("(parse-integer 42)");
        Assert.equals("42", res.ToString());
        var res = Lisp.Eval("(parse-integer 7.89)");
        Assert.equals("7", res.ToString());
    }
    public function testInterpreter52() {
        var res = Lisp.Eval("(do (println (format \"Hello int={0} double={1} str={2}\" 42 2.3456 \"world\")))");
        Assert.equals("Hello int=42 double=2.3456 str=world", res.ToString());
    }
}
