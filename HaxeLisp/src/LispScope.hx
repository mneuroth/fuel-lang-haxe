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
using LispUtils.Ref;
using LispEnvironment;
using LispToken;

class TextWriter {
    public function new() {        
    }

    public function WriteLine(text:String, ?a1, ?a2, ?a3) {
        trace(text);
    }
}

class TextReader {
    public function new() {
    }
}
 
class LispScope extends haxe.ds.StringMap<Dynamic>/*Map<String,Dynamic>*/ {
    //public var _map:Map<String,Dynamic> = new Map<String,Dynamic>();

    public var Debugger:Dynamic;

    public var Tracing:Bool;

    /// <summary>
    /// Gets and sets all tokens of the current script,
    /// used for debugging purpose and for showing the 
    /// position of an error.
    /// </summary>
    public var Tokens:Array<LispToken>;
    
    /// <summary>
    /// Gets and sets the next and previous scope,
    /// used for debugging purpose to show the 
    /// call stack
    /// </summary>
    public var Next:LispScope;  //{ get; private set; }
    public var Previous:LispScope;  //{ get; set; }

    public var ClosureChain:LispScope;

    public var ModuleName:String;

    public var CurrentToken:LispToken;

    public var Name:String;

    public var GlobalScope:LispScope;
    public var Output:TextWriter;
    public var Input:TextReader;

    public var IsInReturn:Bool;

    public var NeedsLValue:Bool;

    /// <summary>
    /// Gets or sets user data.
    /// Needed for debugging support --> set function name to LispScope
    /// </summary>
    /// <value> The user data. </value>
    public var UserData:Dynamic;

    /// <summary>
    /// Gets or sets the user documentation information.
    /// </summary>
    /// <value>The user documentation.</value>
    public var UserDoc:TupleReturn<String,String>;

    public function new() {
        super();
    }

    private static function init(ret:LispScope, fcnName:String, globalScope:LispScope = null, moduleName:String = null):LispScope {
        ret.Name = fcnName;
        ret.GlobalScope = globalScope != null ? globalScope : ret;
        ret.ModuleName = moduleName;
        if (ret.ModuleName == null && globalScope != null)
        {
            ret.ModuleName = globalScope.ModuleName;
        }
        ret.CurrentToken = null;
        ret.Input = new TextReader();  //Console.In;
        ret.Output = new TextWriter(); //Console.Out;
        return ret;
    }

    public static function forFunction(fcnName:String, globalScope:LispScope = null, moduleName:String = null):LispScope {
        var ret = new LispScope();
        return init(ret, fcnName, globalScope, moduleName);
    }

    public function ContainsKey(key:String):Bool {
        return exists(key);
    }

    public function PushNextScope(nextScope:LispScope)
    {
        Next = nextScope;
        nextScope.Previous = this;
    }

    public function PopNextScope()
    {
        Next.Previous = null;
        Next = null;
    }

    /// <summary>
    /// Resolves the given element in this scope.
    /// </summary>
    /// <param name="elem">The element.</param>
    /// <param name="isFirst">Is the element the first one in the list.</param>
    /// <returns>Resolved value or null</returns>
    public function ResolveInScopes(elem:Dynamic, isFirst:Bool):Dynamic
    {
        var result:Ref<Dynamic> = new Ref<Dynamic>(null);

        // try to access the cached function value (speed optimization)
        var elemAsVariant:LispVariant = elem /*as LispVariant*/;
        if (elemAsVariant != null && elemAsVariant.CachedFunction != null)
        {
            return elemAsVariant.CachedFunction;
        }            

        var name = elem.ToString();
        var foundClosureScope:LispScope = new LispScope();
        // first try to resolve in this scope
        if (this.TryGetValue(name, /*out*/ result))
        {
            UpdateFunctionCache(elemAsVariant, result.value, isFirst);
        }
        // then try to resolve in global scope
        else if (GlobalScope != null &&
                 GlobalScope.TryGetValue(name, /*out*/ result))
        {
            UpdateFunctionCache(elemAsVariant, result.value, isFirst);
        }
        // then try to resolve in closure chain scope(s)
        else if (IsInClosureChain(name, /*out*/ foundClosureScope, /*out*/ result))
        {
            UpdateFunctionCache(elemAsVariant, result.value, isFirst);
        }
        // then try to resolve in scope of loaded modules
        else if (LispEnvironment.IsInModules(name, GlobalScope))
        {
            result.value = LispEnvironment.GetFunctionInModules(name, GlobalScope);
        }
        else
        {
            // activate this code if symbols must be resolved in parameter evaluation --> (println blub)
            //if (elemAsVariant != null && elemAsVariant.IsSymbol && name != "fuellib")
            //{
            //    throw new LispException('Could not resolve symbol $name');
            //}
            result = elem;
        }

        return result.value;
    }

    public function DumpStackToString(currentLevel:Int=-1):String {
// TODO --> implement later !        
        return "<NOT IMPLEMENTED YET>";
    }

    public function GetPreviousToken(token:LispToken):LispToken
    {
        var previous:LispToken = null;
        if (Tokens != null)
        {
            for (item in Tokens)
            {
                if (item == token)
                {
                    return previous;
                }
                previous = item;
            }
        }
        return null;
    }
    
    private static function UpdateFunctionCache(elemAsVariant:LispVariant, /*object*/ value:Dynamic, isFirst:Bool)
    {
        var valueAsVariant:LispVariant = value /*as LispVariant*/;
        if (isFirst && elemAsVariant != null && valueAsVariant != null && valueAsVariant.IsFunction)
        {
            //if (elemAsVariant.CachedFunction != null)
            //{
            //    throw new LispException("Cache already set !!!");
            //}
            elemAsVariant.CachedFunction = valueAsVariant;
        }
    }

    /// <summary>
    /// Determines whether the given name is available in the closure chain.
    /// </summary>
    /// <param name="name">The name.</param>
    /// <param name="closureScopeFound">The closure scope found.</param>
    /// <param name="value">The found value.</param>
    /// <returns>True if name was found.</returns>
    private function IsInClosureChain(name:String, /*out LispScope*/ closureScopeFound:LispScope, /*out object*/ value:Dynamic):Bool
    {
        if (ClosureChain != null)
        {
            if (ClosureChain.TryGetValue(name, /*out*/ value))
            {
                closureScopeFound = ClosureChain;
                return true;
            }
            return ClosureChain.IsInClosureChain(name, /*out*/ closureScopeFound, /*out*/ value);
        }

        closureScopeFound = null;
        value = null;
        return false;
    }
}
