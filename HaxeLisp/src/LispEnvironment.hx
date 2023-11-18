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
 
 using StringTools;

 using LispUtils;
 using LispVariant;
 using LispVariant.OpLispVariant;
 using LispToken.LispTokenType;

 class LispEnvironment {
    public /*const*/static var MetaTag = "###";
    public /*const*/static var Builtin = "<builtin>";
    public /*const*/static var EvalStrTag = "<evalstr>:";

    private /*const*/static var MainScope = "<main>";

    private /*const*/static var If = "if";
    private /*const*/static var While = "while";
    private /*const*/static var Begin = "begin";
    private /*const*/static var Do = "do";
    private /*const*/static var Or = "or";
    private /*const*/static var And = "and";
    private /*const*/static var Fn = "fn";
    private /*const*/static var Def = "def";
    private /*const*/static var Setf = "setf";
    private /*const*/static var Defn = "defn";
    private /*const*/static var Gdef = "gdef";
    private /*const*/static var Gdefn = "gdefn";
    private /*const*/static var MapFcn = "map";
    private /*const*/static var ReduceFcn = "reduce";

    public /*const*/static var Lambda = "lambda";

    public /*const*/static var ArgsMeta = MetaTag + "args" + MetaTag;
    public /*const*/static var AdditionalArgs = "_additionalArgs";

    public /*const*/static var Macros = MetaTag + "macros" + MetaTag;
    public /*const*/static var Modules = MetaTag + "modules" + MetaTag;

    private /*const*/static var ArgsCount = "argscount";
    private /*const*/static var Args = "args";
    private /*const*/static var Arg = "arg";
    public /*const*/static var Apply = "apply";
    public /*const*/static var Eval = "eval";
    public /*const*/static var EvalStr = "evalstr";
    public /*const*/static var Quote = "quote";
    public /*const*/static var Quasiquote = "quasiquote";
    public /*const*/static var UnQuote = "_unquote";
    public /*const*/static var UnQuoteSplicing = "_unquotesplicing";

    public /*const*/static var Sym = "sym";
    public /*const*/static var Str = "str";

    public /*const*/static var Version = "v0.99.4";
    public /*const*/static var Date = "11.11.2023";

    public static function FuelFuncWrapper0<TResult>(/*object[]*/ args:Array<Dynamic>, scope:LispScope, name:String, /*Func<TResult>*/ func:Dynamic):LispVariant
    {
        CheckArgs(name, 0, args, scope);

        var result = func();

        //var tempResult:LispVariant = cast(result, LispVariant);
        //return tempResult!=null ? tempResult : LispVariant.forValue(result);
        return LispVariant.forValue(result);
    }

    public static function FuelFuncWrapper1/*<T1, TResult>*/(/*object[]*/ args:Array<Dynamic>, scope:LispScope, name:String, /*Func<T1, TResult>*/ func:Dynamic):LispVariant
    {
        CheckArgs(name, 1, args, scope);

        var arg1 = /*(T1)*/cast(args[0], LispVariant);
        var result = func(arg1);

        //var tempResult:LispVariant = cast(result, LispVariant);
        //return tempResult!=null ? tempResult : LispVariant.forValue(result);
        return LispVariant.forValue(result);
    }

    public static function FuelFuncWrapper2/*<T1, T2, TResult>*/(/*object[]*/ args:Array<Dynamic>, scope:LispScope, name:String, /*Func<T1, T2, TResult>*/ func:Dynamic):LispVariant
    {
        CheckArgs(name, 2, args, scope);

        var arg1 = /*(T1)*/cast(args[0], LispVariant);
        var arg2 = /*(T2)*/cast(args[1], LispVariant);
        var result = func(arg1, arg2);

        //var tempResult:LispVariant = cast(result, LispVariant);
        //return tempResult!=null ? tempResult : LispVariant.forValue(result);
        return LispVariant.forValue(result);
    }

    public static function CreateDefaultScope():LispScope {
        var scope = LispScope.forFunction(MainScope);

        //scope["fuel"] = CreateFunction(Fuel, "(fuel)", "");
        scope.set("fuel", CreateFunction(Fuel, "(fuel)", ""));

        scope.set("print", CreateFunction(Print, "(print expr1 expr2 ...)", "Prints the values of the given expressions on the console."));
        scope.set("println", CreateFunction(PrintLn, "(println expr1 expr2 ...)", "Prints the values of the given expressions on the console adding a new line at the end of the output."));

//TODO
        scope.set("trim", CreateFunction(Trim, "(trim expr1)", "Returns a string with no starting and trailing whitespaces."));
        scope.set("lower-case", CreateFunction(LowerCase, "(lower-case expr1)", "Returns a string with only lower case characters."));
        scope.set("upper-case", CreateFunction(UpperCase, "(upper-case expr1)", "Returns a string with only upper case characters."));
        scope.set("string", CreateFunction(Addition, "(string expr1 expr2 ...)", "see: add"));
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

        scope.set("not", CreateFunction(Not, "(not expr)", "Returns the inverted bool value of the expression."));
        scope.set("!", CreateFunction(Not, "(! expr)", "see: not"));

        scope.set("list", CreateFunction(CreateList, "(list item1 item2 ...)", "Returns a new list with the given elements."));
        scope.set(MapFcn, CreateFunction(MapLoop, "(map function list)", "Returns a new list with elements, where all elements of the list where applied to the function."));
        scope.set(ReduceFcn, CreateFunction(Reduce, "(reduce function list initial)", "Reduce function."));
        scope.set("cons", CreateFunction(Cons, "(cons item list)", "Returns a new list containing the item and the elements of the list."));
        scope.set("len", CreateFunction(Length, "(len list)", "Returns the length of the list."));
        scope.set("first", CreateFunction(FirstElem, "(first list)", "see: car"));
        scope.set("last", CreateFunction(LastElem, "(last list)", "Returns the last element of the list."));
        scope.set("car", CreateFunction(FirstElem, "(car list)", "Returns the first element of the list."));
        scope.set("rest", CreateFunction(Rest, "(rest list)", "see: cdr"));
        scope.set("cdr", CreateFunction(Rest, "(cdr list)", "Returns a new list containing all elements except the first of the given list."));
        scope.set("nth", CreateFunction(Nth, "(nth number list)", "Returns the [number] element of the list."));
        scope.set("push", CreateFunction(Push, "(push elem list [index])", "Inserts the element at the given index (default value 0) into the list (implace) and returns the updated list."));
        scope.set("pop", CreateFunction(Pop, "(pop list [index])", "Removes the element at the given index (default value 0) from the list and returns the removed element."));
        scope.set("append", CreateFunction(Append, "(append list1 list2 ...)", "Returns a new list containing all given lists elements."));
        scope.set("reverse", CreateFunction(Reverse, "(reverse expr)", "Returns a list or string with a reverted order."));
        scope.set("rval", CreateFunction(RValue, "(rval expr)", "Returns a RValue of the expr, disables LValue evaluation.", true, true));
        scope.set(Sym, CreateFunction(Symbol, "(sym expr)", "Returns the evaluated expression as symbol."));
        scope.set(Str, CreateFunction(ConvertToString, "(str expr)", "Returns the evaluated expression as string."));

        scope.set(ArgsCount, CreateFunction(ArgsCountFcn, "(argscount)", "Returns the number of arguments for the current function."));
        scope.set(Args, CreateFunction(ArgsFcn, "(args)", "Returns all the values of the arguments for the current function."));
        scope.set(Arg, CreateFunction(ArgFcn, "(arg number)", "Returns the value of the [number] argument for the current function."));
        scope.set(Apply, CreateFunction(ApplyFcn, "(apply function arguments-list)", "Calls the function with the arguments."));
        scope.set(Eval, CreateFunction(EvalFcn, "(eval ast)", "Evaluates the abstract syntax tree (ast)."));
        scope.set(EvalStr, CreateFunction(EvalStrFcn, "(evalstr string)", "Evaluates the string."));

//TODO -> support map/dictionary        

        scope.set(And, CreateFunction(and_form, "(and expr1 expr2 ...)", "And operator with short cut.", true, true));
        scope.set(Or, CreateFunction(or_form, "(or expr1 expr2 ...)", "Or operator with short cut.", true, true));
        scope.set(Def, CreateFunction(def_form, "(def symbol expression)", "Creates a new variable with name of symbol in current scope. Evaluates expression and sets the value of the expression as the value of the symbol.", true, true));
        scope.set(Gdef, CreateFunction(gdef_form, "(gdef symbol expression)", "Creates a new variable with name of symbol in global scope. Evaluates expression and sets the value of the expression as the value of the symbol.", true, true));
        scope.set(Setf, CreateFunction(setf_form, "(setf symbol expression)", "Evaluates expression and sets the value of the expression as the value of the symbol.", true, true));

//TODO -> support macros !

        scope.set(Quote, CreateFunction(quote_form, "(quasiquote expr)", "Returns expression without evaluating it, but processes evaluation operators , and ,@.", true, true));
        scope.set(Quasiquote, CreateFunction(quasiquote_form, "(quasiquote expr)", "Returns expression without evaluating it, but processes evaluation operators , and ,@.", true, true));
        scope.set(UnQuote, CreateFunction(unquote_form, "(unquotesplicing expr)", "Special form for unquotingsplicing expressions in quasiquote functions.", true, true));
        scope.set(UnQuoteSplicing, CreateFunction(unquotesplicing_form, "(unquotesplicing expr)", "Special form for unquotingsplicing expressions in quasiquote functions.", true, true));
        scope.set(If, CreateFunction(if_form, "(if cond then-block [else-block])", "The if statement.", true, true));
        scope.set(While, CreateFunction(while_form, "(while cond block)", "The while loop.", true, true));
        scope.set(Do, CreateFunction(do_form, "(do statement1 statement2 ...)", "Returns a sequence of statements.", true, true));
        scope.set(Begin, CreateFunction(do_form, "(begin statement1 statement2 ...)", "see: do", true, true));
        scope.set(Lambda, CreateFunction(fn_form, "(lambda (arguments) block)", "Returns a lambda function.", true, true));
        scope.set(Fn, CreateFunction(fn_form, "(fn (arguments) block)", "Returns a function.", true, true));
        scope.set(Defn, CreateFunction(defn_form, "(defn name (args) block)", "Defines a function in the current scope.", true, true));
        scope.set(Gdefn, CreateFunction(gdefn_form, "(gdefn name (args) block)", "Defines a function in the global scope.", true, true));

        return scope;
    }
    
    private static function CheckArgs(name:String, count:Int, /*object[]*/ args:Array<Dynamic>, scope:LispScope):Void
    {
        if (count < 0 || args.length != count)
        {
            throw LispException.fromScope('Bad argument count in $name, has $args.length expected $count', scope);
        }
    }

    private static function CheckOptionalArgs(name:String, minCount:Int, maxCount:Int, /*object[]*/ args:Array<Dynamic>, scope:LispScope):Void
    {
        if ((args.length < minCount) || (args.length > maxCount))
        {
            throw new LispException('Bad argument count in $name, has ${args.length} expected between $minCount and $maxCount');
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
    
    public static function Trim(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        return FuelFuncWrapper1/*<object, string>*/(args, scope, "trim", function (arg1):String { return StringTools.trim(arg1.ToString()); });
    }

    public static function LowerCase(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        return FuelFuncWrapper1/*<object, string>*/(args, scope, "lower-case", function (arg1):String { return arg1.ToString().toLowerCase(); });
    }

    public static function UpperCase(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        return FuelFuncWrapper1/*<object, string>*/(args, scope, "upper-case", function (arg1):String { return arg1.ToString().toUpperCase(); });
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

    public static function Not(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        return FuelFuncWrapper1/*<LispVariant, bool>*/(args, scope, "not", function (arg1) { return LispVariant.forValue(!arg1.ToBool()); });
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

    public static function CreateList(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant 
    {
        var result = new LispVariant(LispType.List, new Array<Dynamic>());  //List<object>()
        for (arg in args)
        {
            result.Add(arg);
        }
        return result;
    }

    public static function MapLoop(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant 
    {
        CheckArgs(MapFcn, 2, args, scope);

        var functionVal = CheckForFunction(MapFcn, args[0], scope).FunctionValue;
        var elements = CheckForList(MapFcn, args[1], scope);

        var result = new LispVariant(LispType.List, new Array<Dynamic>() /*List<object>()*/);
        for (elem in elements)
        {
            // call for every element the given function (args[0])
            var arr = new Array<Dynamic>();
            arr.push(elem);
            result.Add(functionVal.Function(/*new[] {elem}*/arr, scope));
        }
        return result;
    }
    
    public static function Reduce(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        CheckArgs(ReduceFcn, 3, args, scope);

        var functionVal = CheckForFunction(ReduceFcn, args[0], scope).FunctionValue;
        var elements = CheckForList(ReduceFcn, args[1], scope);

        var start = cast(args[2], LispVariant);
        var result = LispVariant.forValue(start);
        for (elem in elements)
        {
            // call for every element the given function (args[0])
            var arr = new Array<Dynamic>();
            arr.push(elem);
            arr.push(result);
            result = functionVal.Function(/*new[] { elem, result }*/arr, scope);
        }
        return result;
    }

    public static function Cons(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        var result = new LispVariant(LispType.List, new Array<Dynamic>());  //new List<object>()
        if (args.length > 0)
        {
            result.Add(args[0]);
        }
        if (args.length > 1)
        {
            var item2 = cast(args[1], LispVariant);
            if (item2.IsList)
            {
                for (item in item2.ListValue)
                {
                    result.Add(item);
                }
            }
            else
            {
                result.Add(args[1]);
            }
        }
        return result;
    }

    public static function Length(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        CheckArgs("len", 1, args, scope);

        var val = cast(args[0], LispVariant);
        if (val.IsNativeObject)
        {
//TODO
            // if (val.Value is Dictionary<object, object>)
            // {
            //     return new LispVariant(((Dictionary<object, object>)val.Value).Count);
            // }
        }
        if (val.IsString)
        {
            return LispVariant.forValue(val.StringValue.length);
        }
        var elements = val.ListValue;
        return LispVariant.forValue(elements.length/*Count()*/);
    }

    public static function FirstElem(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        CheckArgs("first", 1, args, scope);

        var val = cast(args[0], LispVariant);
        if (val.IsString)
        {
            return LispVariant.forValue(val.StringValue.substr(0, 1));
        }
        var elements = val.ListValue;
        if (scope.NeedsLValue)
        {
            var /*List<object>*/ container:Array<Dynamic> = elements; // as List<object>;
            //Action<object> action = (v) => { container[0] = v; };
            var action = function (v) { container[0] = v; };
            return new LispVariant(LispType.LValue, action);
        }
        else
        {
            return LispVariant.forValue(elements.First());
        }
    }

    public static function LastElem(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        CheckArgs("last", 1, args, scope);

        var val = cast(args[0], LispVariant);
        if (val.IsString)
        {
            return LispVariant.forValue(val.StringValue.substr(val.StringValue.length-1));
        }
        var elements = val.ListValue;
        if (scope.NeedsLValue)
        {
            var /*List<object>*/ container:Array<Dynamic> = elements; // as List<object>;
            //Action<object> action = (v) => { container[container.Count - 1] = v; };
            var action = function (v) { container[container.length - 1] = v; };
            return new LispVariant(LispType.LValue, action);
        }
        else
        {
            return LispVariant.forValue(elements.Last());
        }
    }

    public static function Rest(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        CheckArgs("rest", 1, args, scope);

        var val = cast(args[0], LispVariant);
        if(val.IsString)
        {
            return LispVariant.forValue(val.StringValue.substr(1));
        }
        var elements = val.ListValue;
        return LispVariant.forValue(elements.Skip(1));
    }

    public static function Nth(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        CheckArgs("nth", 2, args, scope);

        var index = cast(args[0], LispVariant).IntValue;
        var val = cast(args[1], LispVariant);
        if (val.IsString)
        {
            return LispVariant.forValue(val.StringValue.substr(index, 1));
        }
        var elements = val.ListValue;
        if(scope.NeedsLValue)
        {
            var /*List<object>*/ container:Array<Dynamic> = elements; // as List<object>;
            //Action<object> action = (v) => { container[index] = v; };
            var action = function (v) { container[index] = v; };
            return new LispVariant(LispType.LValue, action);
        }
        else
        {
            return LispVariant.forValue(elements.ElementAt(index));
        }
    }

    public static function Push(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        CheckOptionalArgs("push", 2, 3, args, scope);

        var val = cast(args[0], LispVariant);
        var list = cast(args[1], LispVariant);
        var pos = args.length > 2 ? cast(args[2], LispVariant).ToInt() : 0;
        if (list.IsList)
        {
            var elements = list.ListRef;
            if (pos < elements.length)
            {
                elements.Insert(pos, val);
                return LispVariant.forValue(elements);
            }
            return LispVariant.forValue(LispType.Nil);
        }
        else
        {
            throw new LispException('push not supported for type ${GetLispType(list)}');
        }
    }

    public static function Pop(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        CheckOptionalArgs("pop", 1, 2, args, scope);

        var list = cast(args[0], LispVariant);
        var pos = args.length > 1 ? cast(args[1], LispVariant).ToInt() : 0;
        if (list.IsList)
        {
            var elements = list.ListRef;
            if (pos < elements.length)
            {
                var elem = elements.ElementAt(pos);
                elements.RemoveAt(pos);
                return LispVariant.forValue(elem);
            }
            return LispVariant.forValue(LispType.Nil);
        }
        else
        {
            throw new LispException('pop not supported for type ${GetLispType(list)}');
        }
    }

    public static function Append(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        var result = new LispVariant(LispType.List, new Array<Dynamic>());  //List<object>
        for (listElement in args)
        {
            var lst = cast(listElement, LispVariant).ListValue;
            for (item in lst)
            {
                result.Add(item);                    
            }
        }
        return result;
    }

    public static function Reverse(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        CheckArgs("reverse", 1, args, scope);

        var val = cast(args[0], LispVariant);
        if (val.IsString)
        {
            return LispVariant.forValue(val.StringValue.reverse());
        }
        var elements = val.ListValue.copy();
        elements.reverse();
        return LispVariant.forValue(elements);
    }

    public static function RValue(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        CheckArgs("rval", 1, args, scope);

        var originalLValue = scope.NeedsLValue;
        scope.NeedsLValue = false;
        var value = EvalArgIfNeeded(args[0], scope);
        scope.NeedsLValue = originalLValue;
        return value; //  new LispVariant(value);
    }

    public static function Symbol(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        return FuelFuncWrapper1/*<LispVariant, LispVariant>*/(args, scope, Sym, function (arg1) { new LispVariant(LispType.Symbol, arg1.ToString()); } );
    }

    public static function ConvertToString(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        CheckArgs(Str, 1, args, scope);

        var value = cast(args[0], LispVariant).ToString();
        // convert native object into a readable form
        // used for: (println (str nativeLst))
        if (args[0] is LispVariant)
        {
            var variant = cast(args[0], LispVariant);
//TODO            
            // if (variant.IsNativeObject)
            // {
            //     value = variant.NativeObjectStringRepresentation;
            // }                
        }
        return new LispVariant(LispType.String, value);
    }

    public static function ArgsCountFcn(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        return FuelFuncWrapper0/*<int>*/(args, scope, "argscount", function () { return (cast(scope.get(ArgsMeta), LispVariant)).ListValue.length; });
    }

    public static function ArgsFcn(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        return FuelFuncWrapper0(args, scope, "args", function () { return (cast(scope.get(ArgsMeta), LispVariant)).ListValue/*.ToArray()*/; });
    }

    public static function ArgFcn(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        CheckArgs("arg", 1, args, scope);

        var index = cast(args[0], LispVariant).IntValue;
        var array = cast(scope.get(ArgsMeta), LispVariant).ListValue/*.ToArray()*/;
        if (index >= 0 && index < array.length)
        {
            return LispVariant.forValue(array[index]);
        }
        throw new LispException('Index out of range in args function (index=$index max=${array.length})');
    }
    
    public static function ApplyFcn(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        CheckArgs(Apply, 2, args, scope);

        var fcn = LispInterpreter.EvalAst(args[0], scope);

        var arguments = cast(args[1], LispVariant);

        if (arguments.IsList)
        {
            var argumentsArray = arguments.ListValue/*.ToArray()*/;
            var result = fcn.FunctionValue.Function(argumentsArray, scope);
            return result;
        }

        throw LispException.fromScope("Expected list as arguments in apply", scope);
    }

    public static function EvalFcn(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        CheckArgs("eval", 1, args, scope);

        var result:LispVariant;
        // convert LispVariant.List --> object[] needed for evaluation
        var variant = cast(args[0], LispVariant);
        if (variant.IsList)
        {
            var /*object[]*/ code = variant.ListValue/*.ToArray()*/;
            result = LispInterpreter.EvalAst(code, scope);
        }
        else
        {
            result = LispInterpreter.EvalAst(variant, scope);
        }
        return result;
    }

    public static function EvalStrFcn(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        CheckArgs("evalstr", 1, args, scope);

        var variant = cast(args[0], LispVariant);
        var tempModuleName = scope.ModuleName;
        scope.IsInEval = true;
        var result = Lisp.Eval(variant.ToString(), scope, EvalStrTag + Std.string(scope.ModuleName) + ":" + variant.ToString());
        scope.IsInEval = false;
        scope.ModuleName = tempModuleName;
        return result;
    }

    private static function CheckForFunction(functionName:String, /*object*/ arg0:Dynamic, scope:LispScope):LispVariant
    {
        var functionVal = cast(arg0, LispVariant);
        if (!functionVal.IsFunction)
        {
            throw LispException.fromScope("No function in " + functionName, scope);
        }
        return functionVal;
    }

    private static function CheckForList(functionName:String, /*object*/ listObj:Dynamic, scope:LispScope):Array<Dynamic>  //IEnumerable<object>
    {
        if (listObj is Array/*object[]*/)
        {
            return GetExpression(listObj);
        }
        var value = cast(listObj, LispVariant);
        if (value.IsNativeObject && (value.Value is /*IEnumerable<object>*/Array))
        {
            return cast(value.Value, Array<Dynamic>);  // IEnumerable<object>
        }
        if (!value.IsList)
        {
            throw new LispException("No list in " + functionName, scope.GetPreviousToken(cast(listObj, LispVariant).Token), scope.ModuleName, scope.DumpStackToString());
        }
        return value.ListValue;
    }

    private static function CompareOperation(/*object[]*/ args:Array<Dynamic>, /*Func<LispVariant, LispVariant, LispVariant>*/ op:Dynamic, scope:LispScope, name:String):LispVariant
    {
        return FuelFuncWrapper2/*<LispVariant, LispVariant, LispVariant>*/(args, scope, name, function(arg1, arg2):LispVariant return op(arg1, arg2));
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

    public static function quote_form(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        return FuelFuncWrapper1/*<object, LispVariant>*/(args, scope, Quote, function (arg1) { return LispVariant.forValue(arg1); });
    }

    private static function ProcessQuotedSExpression(/*IEnumerable<object>*/ expr:Array<Dynamic>, scope:LispScope, /*out*/ splicing:Ref<Bool>):Dynamic
    {
        //List<object> result = new List<object>();
        var result = new Array<Dynamic>();

        splicing.value = false;

        if (expr.length == 2)
        {
            var item1 = expr.First();
            var item2 = expr.ElementAt(1);
            if (item1 is LispVariant)
            {
                var variant = cast(item1, LispVariant);
                if (variant.IsSymbol && (variant.ToString() == UnQuote || variant.ToString() == UnQuoteSplicing))
                {
                    var evalResult = LispInterpreter.EvalAst(item2, scope);
                    splicing.value = variant.ToString() == UnQuoteSplicing;
                    evalResult.IsUnQuoted = splicing.value ? LispUnQuoteModus.UnQuoteSplicing : LispUnQuoteModus.UnQuote;
                    return evalResult;
                }
            }
            result.Add(item1);
            result.Add(item2);
        }
        else
        {
            for (itm in expr)
            {
                if (itm is Array/*IEnumerable<object>*/)
                {
                    var tempSplicing:Ref<Bool> = new Ref<Bool>(false);
                    var res = ProcessQuotedSExpression(itm /*as IEnumerable<object>*/, scope, /*out*/ tempSplicing);
                    if (tempSplicing.value)
                    {
                        var variant = cast(res, LispVariant);
                        result.AddRange(variant.ListValue);
                    }
                    else
                    {
                        result.Add(res);
                    }
                }
                else
                {
                    result.Add(itm);
                }
            }
        }
        return result;
    }

    public static function quasiquote_form(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        CheckArgs(Quasiquote, 1, args, scope);

        // iterate through arguments and evaluate unquote/splicing expressions
        var expression = args[0];
        if (expression is LispVariant)
        {
            return cast(expression, LispVariant);
        }
        else if(expression is Array/*IEnumerable<object>*/)
        {
            var splicing = new Ref<Bool>(false);
            return new LispVariant(ProcessQuotedSExpression(expression /*Array<Dynamic>*//*as IEnumerable<object>*/, scope, /*out*/ splicing));
        }
        return LispVariant.forValue(expression);
    }
    
    public static function unquote_form(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        return FuelFuncWrapper1/*<object, LispVariant>*/(args, scope, UnQuote, function (arg1) { return LispVariant.forValue(arg1); });
    }

    public static function unquotesplicing_form(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        return FuelFuncWrapper1/*<object, LispVariant>*/(args, scope, UnQuoteSplicing, function (arg1) { return LispVariant.forValue(arg1); });
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

    public static function Print(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        var text = GetStringRepresentation(args, scope);
        scope.GlobalScope.Output.Write(text);
        return LispVariant.forValue(text);
    }

    public static function PrintLn(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        var text = GetStringRepresentation(args, scope);
        scope.GlobalScope.Output.WriteLine(text);
        return LispVariant.forValue(text);
    }

    private static function GetStringRepresentation(/*object[]*/ args:Array<Dynamic>, scope:LispScope, separator:String = " "):String
    {
        var text = "";  //string.Empty;
        for (item in args)
        {
            if (text.length > 0)
            {
                text += separator;
            }
            text += item.ToString();
        }
        /*TODO
        if (scope.ContainsKey(Traceon) && (bool)scope[Traceon])
        {
            var buffer = (StringBuilder)scope[Tracebuffer];
            buffer.Append(text);
        }
        */
        return text;
    }

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
        if (importedModules != null)
        {
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

    private static function bool_operation_form(/*object[]*/ args:Array<Dynamic>, scope:LispScope, /*Func<bool, bool, bool>*/ func:Dynamic, initial:Bool):LispVariant
    {
        var result = initial;
        for (arg in args)
        {
            var value:Bool = LispInterpreter.EvalAst(arg, scope).BoolValue;
            result = func(result, value);
            if(initial) {
                // process and
                if (!result)
                {
                    break;
                }
            } else {
                // process or
                if (result)
                {
                    break;
                }        
            }
        }
        return LispVariant.forValue(result);
    }

    public static function and_form(/*object[]*/ args, scope:LispScope):LispVariant
    {
        return bool_operation_form(args, scope, function (r:Bool, v:Bool) { return r && v; }, true);
    }

    public static function or_form(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        return bool_operation_form(args, scope, function (r:Bool, v:Bool) { return r || v; }, false);
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

    private static function GetLispType(/*object*/ obj:Dynamic):String
    {
        var lispVariant = cast(obj, LispVariant);
        if (lispVariant != null)
        {
            return lispVariant.TypeString;
        }
        return obj.GetType().ToString();
    }
}
