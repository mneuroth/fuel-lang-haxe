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

    public static function CreateDefaultScope():LispScope {
        var scope = LispScope.forFunction(MainScope);

        //scope["+"] = CreateFunction(Addition, "(+ expr1 expr2 ...)", "see: add");
        //scope["fuel"] = CreateFunction(Fuel, "(fuel)", "");
        scope.set("fuel", CreateFunction(Fuel, "(fuel)", ""));

        return scope;
    }

    private static function CreateFunction(/*Func<object[], LispScope, LispVariant>*/ func:Dynamic, signature:String = null, documentation:String = null, isBuiltin:Bool = true, isSpecialForm:Bool = false, isEvalInExpand:Bool = false, moduleName:String = "<builtin>"):Dynamic
    {
        return LispVariant.forValue(new LispFunctionWrapper(func/*, signature, documentation, isBuiltin, isSpecialForm, isEvalInExpand, moduleName*/));
    }

//    public static function Addition(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
//    {
//        return ArithmetricOperation(args, (l, r) => l + r);
//    }

    private static function Fuel(/*object[]*/ args:Array<Dynamic>, scope:LispScope):LispVariant
    {
        //CheckArgs("fuel", 0, args, scope);

        //var text = new StringBuilder();
        //text.Append(string.Format("fuel version {0} from {1}", Lisp.Version, Lisp.Date));
        return LispVariant.forValue("This is the fuel interpreter!");
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

