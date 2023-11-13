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

 package;
 
 using LispUtils;
 using LispVariant;
 using LispVariant.OpLispVariant;
 using LispToken.LispTokenType;

 class LispEnvironment {
    public /*const*/static var Builtin = "<builtin>";
    
    private /*const*/static var If = "if";
    private /*const*/static var While = "while";
    private /*const*/static var Fn = "fn";
    private /*const*/static var Def = "def";
    private /*const*/static var Setf = "setf";
    private /*const*/static var Defn = "defn";
    private /*const*/static var Gdef = "gdef";
    private /*const*/static var Gdefn = "gdefn";

    private /*const*/static var MainScope = "<main>";

    public /*const*/static var Quote = "quote";
    public /*const*/static var Quasiquote = "quasiquote";
    public /*const*/static var UnQuote = "_unquote";
    public /*const*/static var UnQuoteSplicing = "_unquotesplicing";

    public /*const*/static var MetaTag = "###";

    public /*const*/static var Macros = MetaTag + "macros" + MetaTag;
    public /*const*/static var Modules = MetaTag + "modules" + MetaTag;

    public /*const*/static var ArgsMeta = MetaTag + "args" + MetaTag;
    public /*const*/static var AdditionalArgs = "_additionalArgs";

    public /*const*/static var Version = "v0.99.4";
    public /*const*/static var Date = "11.11.2023";


    public static function CreateDefaultScope():LispScope {
        var scope = LispScope.forFunction(MainScope);

        //scope["fuel"] = CreateFunction(Fuel, "(fuel)", "");
        scope.set("fuel", CreateFunction(Fuel, "(fuel)", ""));
        scope.set("add", CreateFunction(Addition, "(add expr1 expr2 ...)", "Returns value of expr1 added with expr2 added with ..."));
        scope.set("+", CreateFunction(Addition, "(+ expr1 expr2 ...)", "see: add"));
        scope.set("sub", CreateFunction(Substraction, "(sub expr1 expr2 ...)", "Returns value of expr1 subtracted with expr2 subtracted with ..."));
        scope.set("-", CreateFunction(Substraction, "(- expr1 expr2 ...)", "see: sub"));
        scope.set("mul", CreateFunction(Multiplication, "(sub expr1 expr2 ...)", "(mul expr1 expr2 ...)", "Returns value of expr1 multipied by expr2 multiplied by ..."));
        scope.set("*", CreateFunction(Multiplication, "(* expr1 expr2 ...)", "see: mul"));
        scope.set("div", CreateFunction(Division, "(div expr1 expr2 ...)", "Returns value of expr1 divided by expr2 divided by ..."));
        scope.set("/", CreateFunction(Division, "(* expr1 expr2 ...)", "see: div"));
        scope.set("mod", CreateFunction(Modulo, "(mod expr1 expr2)", "Returns value of modulo operation between expr1 and expr2"));
        scope.set("%", CreateFunction(Modulo, "(% expr1 expr2)", "see: mod"));

        scope.set("<", CreateFunction(Less, "(< expr1 expr2)", "Returns #t if value of expression1 is smaller than value of expression2 and returns #f otherwiese."));
        scope.set(">", CreateFunction(Greater, "(> expr1 expr2)", "Returns #t if value of expression1 is larger than value of expression2 and returns #f otherwiese."));
        scope.set("<=", CreateFunction(LessEqual, "(<= expr1 expr2)", "Returns #t if value of expression1 is equal or smaller than value of expression2 and returns #f otherwiese."));
        scope.set(">=", CreateFunction(GreaterEqual, "(>= expr1 expr2)", "Returns #t if value of expression1 is equal or larger than value of expression2 and returns #f otherwiese."));

        scope.set("equal", CreateFunction(EqualTest, "(equal expr1 expr2)", "Returns #t if value of expression1 is equal with value of expression2 and returns #f otherwiese."));
        scope.set("=", CreateFunction(EqualTest, "(= expr1 expr2)", "see: equal"));
        scope.set("==", CreateFunction(EqualTest, "(== expr1 expr2)", "see: equal"));

        scope.set("!=", CreateFunction(NotEqualTest, "(!= expr1 expr2)", "Returns #t if value of expression1 is not equal with value of expression2 and returns #f otherwiese."));

        scope.set(If, CreateFunction(if_form, "(if cond then-block [else-block])", "The if statement.", true, true));
        scope.set(While, CreateFunction(while_form, "(while cond block)", "The while loop.", true, true));
        scope.set("do", CreateFunction(do_form, "(do statement1 statement2 ...)", "Returns a sequence of statements.", true, true));
        scope.set("begin", CreateFunction(do_form, "(begin statement1 statement2 ...)", "see: do", true, true));
        scope.set("lambda", CreateFunction(fn_form, "(lambda (arguments) block)", "Returns a lambda function.", true, true));
        scope.set(Fn, CreateFunction(fn_form, "(fn (arguments) block)", "Returns a function.", true, true));
        scope.set(Defn, CreateFunction(defn_form, "(defn name (args) block)", "Defines a function in the current scope.", true, true));
        scope.set(Gdefn, CreateFunction(gdefn_form, "(gdefn name (args) block)", "Defines a function in the global scope.", true, true));

        scope.set(Def, CreateFunction(def_form, "(def symbol expression)", "Creates a new variable with name of symbol in current scope. Evaluates expression and sets the value of the expression as the value of the symbol.", true, true));
        scope.set(Setf, CreateFunction(setf_form, "(setf symbol expression)", "Evaluates expression and sets the value of the expression as the value of the symbol.", true, true));

        return scope;
    }
    
    private static function CheckArgs(name:String, count:Int, /*object[]*/ args:Array<Dynamic>, scope:LispScope)
    {
        if (count < 0 || args.length != count)
        {
            throw LispException.fromScope('Bad argument count in $name, has $args.length expected $count', scope);
        }
    }

    private static function CreateFunction(/*Func<object[], LispScope, LispVariant>*/ func:Dynamic, signature:String = null, documentation:String = null, isBuiltin:Bool = true, isSpecialForm:Bool = false, isEvalInExpand:Bool = false, moduleName:String = "<builtin>"):Dynamic
    {
        return LispVariant.forValue(new LispFunctionWrapper(func, signature, documentation, isBuiltin, isSpecialForm, isEvalInExpand, moduleName));
    }

    private static function Fuel(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        CheckArgs("fuel", 0, args, scope);

        return LispVariant.forValue('fuel version ${LispEnvironment.Version} from ${LispEnvironment.Date}');
    }
    
    public static function Addition(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        return ArithmetricOperation(args, function(l:LispVariant, r:LispVariant) return LispVariant.op_add(l, r));
    }

    public static function Substraction(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        return ArithmetricOperation(args, function(l:LispVariant, r:LispVariant) return LispVariant.op_minus(l, r));
    }

    public static function Multiplication(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        return ArithmetricOperation(args, function(l:LispVariant, r:LispVariant) return LispVariant.op_mul(l, r));
    }

    public static function Division(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        return ArithmetricOperation(args, function(l:LispVariant, r:LispVariant) return LispVariant.op_divide(l, r));
    }

    public static function Modulo(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        return ArithmetricOperation(args, function(l:LispVariant, r:LispVariant) return LispVariant.op_modulo(l, r));
    }

    public static function Less(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        return CompareOperation(args, function(l:LispVariant, r:LispVariant) return LispVariant.op_less(l, r), scope, "<");
    }

    public static function Greater(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        return CompareOperation(args, function(l:LispVariant, r:LispVariant) return LispVariant.op_greater(l, r), scope, ">");
    }

    public static function LessEqual(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        return CompareOperation(args, function(l:LispVariant, r:LispVariant) return LispVariant.op_less_than(l, r), scope, "<=");
    }

    public static function GreaterEqual(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        return CompareOperation(args, function(l:LispVariant, r:LispVariant) return LispVariant.op_greater_than(l, r), scope, ">=");
    }

    public static function EqualTest(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        return CompareOperation(args, function(l:LispVariant, r:LispVariant) return LispVariant.op_equal(l, r), scope, "==");
    }

    public static function NotEqualTest(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        return CompareOperation(args, function(l:LispVariant, r:LispVariant) return LispVariant.op_not_equal(l, r), scope, "!=");
    }

    private static function CompareOperation(/*object[]*/ args:Array<Dynamic>, /*Func<LispVariant, LispVariant, LispVariant>*/ op:Dynamic, scope:LispScope, name:String):LispVariant
    {
        return FuelFuncWrapper2/*<LispVariant, LispVariant, LispVariant>*/(args, scope, name, function(arg1, arg2):LispVariant return op(arg1, arg2));
    }

    public static function FuelFuncWrapper2/*<T1, T2, TResult>*/(/*object[]*/ args:Array<Dynamic>, scope:LispScope, name:String, /*Func<T1, T2, TResult>*/ func:Dynamic):LispVariant
    {
        CheckArgs(name, 2, args, scope);

        var arg1 = /*(T1)*/cast(args[0], LispVariant);
        var arg2 = /*(T2)*/cast(args[1], LispVariant);
        var result = func(arg1, arg2);

        var tempResult:LispVariant = cast(result, LispVariant);
        return tempResult!=null ? tempResult : LispVariant.forValue(result);
    }

    private static function ArithmetricOperation(/*IEnumerable<object>*/ args:Array<Dynamic>, /*Func<LispVariant, LispVariant, LispVariant>*/ op:Dynamic):LispVariant 
    {
        var result:LispVariant = null;
        for (elem in args)
        {
            if (result == null)
            {
                result = LispVariant.forValue(elem.Value);
            }
            else
            {
                result = op(result, elem);
            }
        }
        return LispVariant.forValue(result.Value);
    }

    public static function if_form(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        if (!(args.length == 2 || args.length == 3))
        {
            // throw exception
            CheckArgs(If, -1, args, scope);                
        }

        var passed = LispInterpreter.EvalAst(args[0], scope).BoolValue;
        var elseCode = args.length > 2 ? args[2] : null;
        return LispInterpreter.EvalAst(passed ? args[1] : elseCode, scope);
    }

    public static function while_form(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        CheckArgs(While, 2, args, scope);

        var result = new LispVariant(null);
        var condition = LispInterpreter.EvalAst(args[0], scope);
        while (condition.ToBool())
        {
            result = LispInterpreter.EvalAst(args[1], scope);
            if (scope.IsInReturn)
            {
                break;
            }
            condition = LispInterpreter.EvalAst(args[0], scope);
        }
        return result;
    }

    public static function do_form(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        var result = LispVariant.forValue();

        for (statement in args)
        {
            var lv:LispVariant = statement;
            if (!((statement is /*Enumerable<object>*/Array) || ((statement is LispVariant) && cast(statement, LispVariant).IsList)))
            {
                throw new LispException("List expected in do", (cast(statement, LispVariant)).Token, scope.ModuleName, scope.DumpStackToString());
            }
            result = LispInterpreter.EvalAst(statement, scope);
            if (scope.IsInReturn)
            {
                break;
            }
        }

        return result;
    }

    public static function fn_form(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        var name = cast(scope.UserData, String);
        var moduleName = scope.ModuleName;
        var userDoc = scope.UserDoc;
        var signature = userDoc != null ? userDoc.value1 : null;
        var documentation = userDoc != null ? userDoc.value2 : null;
        
        var /*Func<object[], LispScope, LispVariant>*/ fcn:Dynamic =
            function (localArgs:Array<Dynamic>, localScope:LispScope):LispVariant
            {
                var childScope = LispScope.forFunction(name, localScope.GlobalScope, moduleName);
                localScope.PushNextScope(childScope);

                // add formal arguments to current scope
                var i = 0;
                var formalArgs:Array<Dynamic> = (args[0] is LispVariant ? (cast(args[0], LispVariant)).ListValue : GetExpression(args[0]))/*.ToArray()*/;

                if (formalArgs.length > localArgs.length)
                {
                    //throw new LispException("Invalid number of arguments");

                    // fill all not given arguments with nil
                    var newLocalArgs = new Array<Dynamic>();  //object[formalArgs.Length];
                    newLocalArgs.resize(formalArgs.length);
                    for (n in 0...formalArgs.length)
                    {
                        if (n < localArgs.length)
                        {
                            newLocalArgs[n] = localArgs[n];
                        }
                        else
                        {
                            newLocalArgs[n] = new LispVariant(LispType.Nil);
                        }
                    }

                    localArgs = newLocalArgs;
                }

                for (arg in formalArgs)
                {
                    childScope.set(arg.ToString(), localArgs[i]);
                    i++;
                }

                // support args function for accessing all given parameters
                childScope.set(ArgsMeta, LispVariant.forValue(localArgs));
                var formalArgsCount:Int = formalArgs.length;
                if (localArgs.length > formalArgsCount)
                {
                    var additionalArgs = new Array<Dynamic>();  //object[localArgs.Length - formalArgsCount];
                    additionalArgs.resize(localArgs.length - formalArgsCount);
                    for (n in 0...localArgs.length - formalArgsCount)
                    {
                        additionalArgs[n] = localArgs[n + formalArgsCount];
                    }
                    childScope.set(AdditionalArgs, LispVariant.forValue(additionalArgs));
                }

                // save the current call stack to resolve variables in closures
                childScope.ClosureChain = scope;
                childScope.NeedsLValue = scope.NeedsLValue;     // support setf in recursive calls

                var ret:LispVariant;
                try
                {
                    ret = LispInterpreter.EvalAst(args[1], childScope);
                }
/* //TODO                
                catch (ex:LispStopDebuggerException)
                {
                    // forward a debugger stop exception to stop the debugger loop
                    throw ex;
                }
*/                
                catch (ex:haxe.Exception)
                {
                    // add the stack info and module name to the data of the exception
//TODO                    ex.AddModuleNameAndStackInfos(childScope.ModuleName, childScope.DumpStackToString());
//TODO                    ex.AddTokenInfos(childScope.CurrentToken);

                    var debugger = scope.GlobalScope.Debugger;
                    if (debugger != null)
                    {
                        scope.GlobalScope.Output.WriteLine(Std.string(ex));

//TODO                        debugger.InteractiveLoop(initialTopScope: childScope, currentAst: (IList<object>)(args[1]) /*new List<object> { info.Item2 }*/ );
                    }

                    throw ex;
                }
                localScope.PopNextScope();
                return ret;
            };

        return LispVariant.forValue(CreateFunction(fcn, signature, documentation, /*isBuiltin:*/ false, /*isSpecialForm:*/ false, /*isEvalInExpand:*/ false, /*moduleName:*/ scope.ModuleName));
    }

    //
    // for tests with overloaded operators
    //
    // public static function Addition(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    // {
    //     //var val1:OpLispVariant = cast(args[0], OpLispVariant);
    //     //var val2:OpLispVariant = cast(args[1], OpLispVariant);
    //     //var val1 = new OpLispVariant(args[0]);
    //     //var val2 = new OpLispVariant(args[1]);        
    //     //trace("ADD:", val1.Value + val2.Value);
    //     //var sum = LispVariant.add(val1, val2);
    //     //var sum:LispVariant = val1 + val2;
    //     //return LispVariant.forValue(sum);

    //     return ArithmetricOperation(args, function(l:OpLispVariant, r:OpLispVariant) return l + r);
    // }

    // private static function ArithmetricOperation(/*IEnumerable<object>*/ args:Array<Dynamic>, /*Func<LispVariant, LispVariant, LispVariant>*/ op:Dynamic):LispVariant 
    // {
    //     var result:OpLispVariant = null;
    //     for (elem in args)
    //     {
    //         if (result == null)
    //         {
    //             result = new OpLispVariant(elem);
    //         }
    //         else
    //         {
    //             result = op(result, elem);
    //         }
    //     }
    //     return LispVariant.forValue(result.Value);
    // }

    public static function IsInModules(funcName:String, scope:LispScope):Bool
    {
        var value:Ref<Dynamic> = new Ref<Dynamic>(null);  //object
        return FindFunctionInModules(funcName, scope, /*out*/ value);
    }

    public static function GetFunctionInModules(funcName:String, scope:LispScope):Dynamic  //object
    {
        var result:Ref<Dynamic> = new Ref<Dynamic>(null);  //object
        FindFunctionInModules(funcName, scope, /*out*/ result);
        return result.value;
    }

    public static function IsMacro(funcName:Dynamic, scope:LispScope):Bool
    {
        return ExistsItem(funcName, scope, Macros);
    }

    public static function GetMacro(funcName:Dynamic, scope:LispScope):Dynamic  //object
    {
        return QueryItem(funcName, scope, Macros);
    }

    public static function IsExpression(item:Dynamic):Bool
    {
        return (item is LispVariant && (cast(item, LispVariant)).IsList) ||
               (item is Array/*<Dynamic>*/);  //IEnumerable<object>
    }

    public static function GetExpression(item:Dynamic):Array<Dynamic>  //IEnumerable<object>
    {
        if (item is LispVariant && (cast(item, LispVariant)).IsList)
        {
            return (cast(item, LispVariant)).ListValue;
        }
        if (item is Array/*<Dynamic>*/)  //IEnumerable<object>
        {
            return cast(item, Array<Dynamic>);  //IEnumerable<object>
        }
        return new Array<Dynamic>() [ item ];  // List<object>
    }

    private static function QueryItem(funcName:Dynamic, scope:LispScope, key:String):Dynamic  //object
    {
        var val:Ref<Dynamic> = new Ref<Dynamic>(null);
        var val2:Ref<Dynamic> = new Ref<Dynamic>(null);
        if (scope != null &&
            scope.TryGetValue(key, /*out*/ val) &&
            (cast(val.value, LispScope)).TryGetValue(funcName.ToString(), /*out*/ val2))
        {
            return val2.value;
        }
        return null;
    }

    private static function ExistsItem(funcName:Dynamic, scope:LispScope, key:String):Bool
    {
        var val:Ref<Dynamic> = new Ref<Dynamic>(null);  //object
        if (scope != null &&
            scope.TryGetValue(key, /*out*/ val))
        {
            return (/*(LispScope)*/cast(val.value, LispScope)).ContainsKey(funcName.ToString());
        }
        return false;
    }

    private static function FindFunctionInModules(funcName:String, scope:LispScope, /*out object*/ foundValue:Ref<Dynamic>):Bool
    {
        foundValue.value = null;
        var importedModules = /*(LispScope)*/cast(scope.GlobalScope.get(Modules), LispScope);
        for (/*KeyValuePair<string, object>*/ kv in importedModules)
        {
            var module = /*(LispScope)*/kv.Value;
            var val:Dynamic = new Ref<Dynamic>(null);  //object
            if (module.TryGetValue(funcName, /*out*/ val))
            {
                foundValue.value = val.value;
                return true;
            }
        }
        return false;
    }

    public static function defn_form(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        return defn_form_helper(args, scope, Def);
    }

    public static function gdefn_form(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        return defn_form_helper(args, scope, Gdef);
    }

    private static function defn_form_helper(/*object[]*/ args:Array<Dynamic>, scope:LispScope, name:String):LispVariant
    {
        CheckArgs(name, 3, args, scope);

        UpdateDocumentationInformationAtScope(args, scope);

        var fn = (cast(scope.GlobalScope.get(Fn), LispVariant)).FunctionValue;
        scope.UserData = EvalArgIfNeeded(args[0], scope).ToString();
        var resultingFcn = fn.Function([args[1], args[2]], scope);  //(new[] { args[1], args[2] }, scope);
        scope.UserData = null;

        var defFcn = (cast(scope.GlobalScope.get(name), LispVariant)).FunctionValue;
        return defFcn.Function([args[0], resultingFcn], scope);  //(new[] { args[0], resultingFcn }, scope);
    }

    private static function EvalArgIfNeeded(/*object*/ arg:Dynamic, scope:LispScope):LispVariant
    {
        return (arg is /*IEnumerable<object>*/Array) ? LispInterpreter.EvalAst(arg, scope) : cast(arg, LispVariant);
    }

    private static function GetSignatureFromArgs(/*object*/ arg0:Dynamic, name:String):String
    {
        var signature = "(" + (name != null ? name : "?");
        var formalArgsAsString = GetFormalArgsAsString(arg0);
        if (formalArgsAsString.length > 0)
        {
            signature += " ";
        }
        signature += formalArgsAsString;
        signature += ")";
        return signature;
    }

    private static function GetFormalArgsAsString(/*object*/ args:Dynamic):String
    {
        var result = "";  //string.Empty;
        var /*IEnumerable<object>*/ theArgs:Array<Dynamic> = null;
        if (args is LispVariant)
        {
            theArgs = (cast(args, LispVariant)).ListValue;
        }
        else
        {
            theArgs = /*(IEnumerable<object>)*/cast(args, Array<Dynamic>);
        }
        for (s in theArgs)
        {
            if (result.length > 0)
            {
                result += " ";
            }
            result += s;
        }
        return result;
    }

    private static function UpdateDocumentationInformationAtScope(/*object[]*/ args:Array<Dynamic>, scope:LispScope)
    {
        var documentation = "";  //string.Empty;
        var token = GetTokenBeforeDefn(args[0], scope);
        if ((token != null) && (token.Type == LispTokenType.Comment))
        {
            documentation = token.Value.ToString();
        }
        var signature = GetSignatureFromArgs(args[1], args[0].ToString());
        scope.UserDoc = new LispUtils.TupleReturn<String, String>(signature, documentation);
    }

    // returns token just before the defn statement:
    // item is fcn token, go three tokens before, example:
    // ; comment before defn
    // (defn fcn (x) (+ x 1))
    // --> Comment Token
    private static function GetTokenBeforeDefn(/*object*/ item:Dynamic, scope:LispScope):LispToken
    {
        if (item is LispVariant)
        {
            var tokenName:LispVariant = cast(item, LispVariant);
            var token1 = scope.GetPreviousToken(tokenName.Token);
            var token2 = scope.GetPreviousToken(token1);
            var token3 = scope.GetPreviousToken(token2);
            return token3;
        }
        return null;
    }

    public static function def_form(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        return def_form_helper(args, scope, Def, scope);
    }

    public static function gdef_form(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        return def_form_helper(args, scope, Gdef, scope.GlobalScope);
    }

    private static function def_form_helper(/*object[]*/ args:Array<Dynamic>, scope:LispScope, name:String, scopeToSet:LispScope):LispVariant
    {
        CheckArgs(name, 2, args, scope);

        var symbol = EvalArgIfNeeded(args[0], scope);
        if (!(symbol.IsSymbol || symbol.IsString))
        {
            throw LispException.fromScope("Symbol expected", scope);
        }
        var value = LispInterpreter.EvalAst(args[1], scope);
        scopeToSet.set(symbol.ToString(), value);
        return LispVariant.forValue(value);
    }

    public static function setf_form(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        CheckArgs(Setf, 2, args, scope);

        var originalNeedsLValue = scope.NeedsLValue;
        scope.NeedsLValue = true;
        var symbol = EvalArgIfNeeded(args[0], scope);
        scope.NeedsLValue = originalNeedsLValue;  
        var symbolName = symbol != null ? symbol.ToString() : null;
        var value = LispInterpreter.EvalAst(args[1], scope);
        if(symbol.IsLValue)
        {
            var /*Action<object>*/ action:Dynamic = /*(Action<object>)*/symbol.Value;
            action(value);
        }
        else
        {
            scope.SetInScopes(symbolName, value);
        }
        return value;
    }
}

