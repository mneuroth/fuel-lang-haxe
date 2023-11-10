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
}
