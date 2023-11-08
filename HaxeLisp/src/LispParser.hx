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

import LispUtils.TupleReturn;
import LispVariant.LispVariant;
import LispVariant.LispType;
import LispException.LispException;

using LispUtils;

class LispEnvironment {
    public /*const*/static var Quote = "quote";
    public /*const*/static var Quasiquote = "quasiquote";
    public /*const*/static var UnQuote = "_unquote";
    public /*const*/static var UnQuoteSplicing = "_unquotesplicing";

    public /*const*/static var MetaTag = "###";

    public /*const*/static var Macros = MetaTag + "macros" + MetaTag;
    public /*const*/static var Modules = MetaTag + "modules" + MetaTag;

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

/// <summary>
/// The FUEL lisp parser.
/// </summary>
/*public*/ class LispParser
{
    private /*const*/static var BracketsOutOfBalance = "Brackets out of balance";
    private /*const*/static var BracketsOutOfBalanceOrUnexpectedScriptCode = BracketsOutOfBalance + " or unexpected script code";
    private /*const*/static var UnexpectedToken = "Unexpected token";

    /// <summary>
    /// Parses the specified code.
    /// string ==&gt; List(Tokens) ==&gt; List(object) mit object == List(object), LispVariant(string, int, double, and ==&gt; for unquoting Symbols)
    /// </summary>
    /// <param name="code">The code.</param>
    /// <param name="offset">The position offset.</param>
    /// <param name="scope">The scope.</param>
    /// <returns>Abstract syntax tree as container</returns>
    public static function Parse(code:String, offset:Int = 0, scope:Dynamic/*LispScope*/ = null):Dynamic //object
    {
        //var parseResult:Dynamic = null; //object
        var moduleName = ""; //string.Empty;

        // set tokens at LispScope to improve debugging and 
        // support displaying of error position 
        var tokens = LispTokenizer.Tokenize(code, offset)/*.ToList()*/;
        if (scope != null)
        {
            scope.Tokens = tokens;
            moduleName = scope.ModuleName;
        }

        var parseResult = ParseTokens(moduleName, tokens, 0, /*ref parseResult,*/ /*isToplevel:*/ true);

        return parseResult.value2;
    }

    private static function ParseTokens(moduleName:String, /*IList<LispToken>*/ tokens:Array<LispToken>, startIndex:Int, /*ref object parseResult:Dynamic,*/ isToplevel:Bool):TupleReturn<Int,Dynamic>
    {
        var parseResult:Dynamic = null;
        var i:Int;
        var current:Array<Dynamic> = null;  //object
        var listStack = new haxe.ds.GenericStack<Array<Dynamic>>();  //object

        var i = startIndex;
        while (i<tokens.length)
        //for (i in startIndex...tokens.length)
        {
            var token = tokens[i];
            if (token.Type == LispToken.LispTokenType.ListStart)
            {
                current = new Array<Dynamic>();  //object
                listStack.add(current);
            }
            else if (token.Type == LispToken.LispTokenType.ListEnd)
            {
                var temp = current;
                listStack.pop();
                if (!listStack.isEmpty())
                {
                    listStack.first().Add(temp);
                    current = listStack.first();
                }
                else
                {
                    if (isToplevel && i+1<tokens.length && !OnlyCommentTokensFrom(tokens, i+1))
                    {
                        throw new LispException(BracketsOutOfBalanceOrUnexpectedScriptCode, token, moduleName);
                    }
                    parseResult = current;
                    return new TupleReturn<Int,Dynamic>(i, parseResult);
                }
            }
            else if (token.Type == LispToken.LispTokenType.Quote || token.Type == LispToken.LispTokenType.QuasiQuote)
            {
                var quote = new Array<Dynamic>();  //object
                quote.Add(new LispVariant(Symbol, token.Type == LispToken.LispTokenType.Quote ? LispEnvironment.Quote : LispEnvironment.Quasiquote));

                var quotedList:Dynamic = null;  //object
                var temp = ParseTokens(moduleName, tokens, i + 1, /*ref quotedList,*/ /*isToplevel:*/ false);
                i = temp.value1;
                quotedList = temp.value2;
                quote.Add(quotedList);

                if (current != null)
                {
                    current.Add(quote);                        
                }
            }
            else if (token.Type == LispToken.LispTokenType.UnQuote || token.Type == LispToken.LispTokenType.UnQuoteSplicing)
            {
                var unquote = new Array<Dynamic>();  //object
                //LispUnQuoteModus unquotedModus = token.Type == LispToken.LispTokenType.UnQuote ? LispUnQuoteModus.UnQuote : LispUnQuoteModus.UnQuoteSplicing;
                unquote.Add(new LispVariant(LispType.Symbol, token.Type == LispToken.LispTokenType.UnQuote ? LispEnvironment.UnQuote : LispEnvironment.UnQuoteSplicing));

                var quotedList:Dynamic = null;  //object
                var temp = ParseTokens(moduleName, tokens, i + 1, /*ref quotedList,*/ /*isToplevel:*/ false);
                i = temp.value1;
                quotedList = temp.value2;
                unquote.Add(quotedList);

                if (current != null)
                {
                    current.Add(unquote);
                }
                else
                {
                    parseResult = unquote;
                    return new TupleReturn<Int,Dynamic>(i, parseResult);
                }
            }
            else if (token.Type == LispToken.LispTokenType.Comment)
            {
                // just ignore comment 
            }
            else
            {
                if(!isToplevel && current == null)
                {
                    parseResult = LispVariant.forToken(token);
                    return new TupleReturn<Int,Dynamic>(i, parseResult);
                }
                if (current == null)
                {
                    throw new LispException(UnexpectedToken, token, moduleName);
                }
                current.Add(LispVariant.forToken(token));
            }
            i++;
        }

        if (isToplevel && tokens.length>0)
        {
            var token = tokens.Last();
            throw new LispException(BracketsOutOfBalance, token, moduleName);
        }

        parseResult = current;
        return new TupleReturn<Int,Dynamic>(i, parseResult);
    }

    private static function OnlyCommentTokensFrom(tokens:Array<LispToken>, i:Int):Bool
    {
        for (token in tokens)
        {
            if (token.Type != LispToken.LispTokenType.Comment)
            {
                return false;
            }
        }
        return true;
    }
}
