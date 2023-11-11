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

 class LispEnvironment {
    public /*const*/static var Builtin = "<builtin>";
    
    private /*const*/static var MainScope = "<main>";

    public /*const*/static var Quote = "quote";
    public /*const*/static var Quasiquote = "quasiquote";
    public /*const*/static var UnQuote = "_unquote";
    public /*const*/static var UnQuoteSplicing = "_unquotesplicing";

    public /*const*/static var MetaTag = "###";

    public /*const*/static var Macros = MetaTag + "macros" + MetaTag;
    public /*const*/static var Modules = MetaTag + "modules" + MetaTag;

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
        return LispVariant.forValue(new LispFunctionWrapper(func/*, signature, documentation, isBuiltin, isSpecialForm, isEvalInExpand, moduleName*/));
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
        return result;         
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
            (cast(val, LispScope)).TryGetValue(funcName.ToString(), /*out*/ val2))
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
                foundValue.value = val;
                return true;
            }
        }
        return false;
    }
}

