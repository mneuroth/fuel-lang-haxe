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

import LispException.LispException;

class Ref<T> {
    public var value:T;

    public function new(val:T) {
        value = val;
    }
}

class TupleReturn<T1,T2> {
    public var value1:T1;
    public var value2:T2;

    public function new(_value1:T1, _value2:T2) {
        value1 = _value1;
        value2 = _value2;
    }
}

class ArrayExtender {
    static public function First(arr:Array<Dynamic>):Dynamic {
        if (arr.length == 0) {
            throw new LispException("Array<Dynamic> has no elements!");
        }
        return arr[0];
    }
    static public function Last(arr:Array<Dynamic>):Dynamic {
        if (arr.length == 0) {
            throw new LispException("Array<Dynamic> has no elements!");
        }
        return arr[arr.length - 1];
    }
    static public function FirstOrDefault(arr:Array<Dynamic>):Dynamic {
        if (arr.length == 0) {
            return null;
        }
        return arr[0];
    }
    static public function Add(arr:Array<Dynamic>, item:Dynamic) {
        arr.push(item);
    }
    static public function Insert(arr:Array<Dynamic>, pos:Int, item:Dynamic) {
        arr.insert(pos, item);
    }
    static public function RemoveAt(arr:Array<Dynamic>, pos:Int) {
        arr.splice(pos, 1);
    }
    static public function ToList(arr:Array<Dynamic>):Array<Dynamic> {
        return arr;
    }
    static public function Skip(arr:Array<Dynamic>, count:Int):Array<Dynamic> {
        arr = arr.slice(count);
        return arr;
    }
    static public function AddRange(arr:Array<Dynamic>, other:Array<Dynamic>):Array<Dynamic> {
        for(elem in other) {
            arr.push(elem);
        }
        return arr;
    }
    static public function CopyTo(arr:Array<Dynamic>, other:Array<Dynamic>, index:Int):Array<Dynamic> {
        arr = other.copy();
        return arr;
    }
    static public function ElementAt(arr:Array<Dynamic>, index:Int):Dynamic {
        return arr[index];
    }
}

class StringExtender {
    static public function reverse(s:String):String {
        var temp = s.split('');
        temp.reverse();
        return temp.join('');
    }
    static public function ToUpper(s:String):String {
        return s.toUpperCase();
    }
    static public function ToLower(s:String):String {
        return s.toLowerCase();
    }
    public static function Format(value:String, values:Array<Any>) {
        //see: https://stackoverflow.com/questions/49104997/string-substitution-string-formating-in-haxe
        var ereg:EReg = ~/(\{(\d{1,2})\})/g;
        while (ereg.match(value)) {
            value = ereg.matchedLeft() + values[Std.parseInt(ereg.matched(2))] + ereg.matchedRight();
        }
        return value;
    }    
}

class MapExtender {
    static public function TryGetValue(map:haxe.ds.StringMap<Dynamic>/*Map<String,Dynamic>*/, name:String, value:Ref<Dynamic>):Bool {
        if (map.exists(name)) {
            var val = map.get(name);
            value.value = val;
            return true;
        }
        return false;
    }
}

class LispExceptionExtender {
    static public function AddTokenInfos(exc:LispException, token:LispToken) {
// TODO        
    }
}
/*
function CompareToT<T>(val1:T, val2:T):Int {
    if(val1 == val2) {
        return 0;
    }
    if(val1 < val2) {
        return -1;        
    }
    if(val1 > val2) {
        return 1;        
    }
    return 0;
}
*/
function CompareToInt(val1:Int, val2:Int):Int {
    if(val1 == val2) {
        return 0;
    }
    if(val1 < val2) {
        return -1;        
    }
    if(val1 > val2) {
        return 1;        
    }
    return 0;
}

function CompareToFloat(val1:Float, val2:Float):Int {
    //if(val1 == val2) {
    //    return 0;
    //}
    if(val1 < val2) {
        return -1;        
    }
    if(val1 > val2) {
        return 1;        
    }
    return 0;
}

function StringCompare(val1:String, val2:String):Int {
    // <0   val1 < val2
    // ==0  val1 == val2
    // >0   val1 > val2
    //if(val1 == val2) {
    //    return 0;
    //}
    if(val1 < val2) {
        return -1;        
    }
    if(val1 > val2) {
        return 1;        
    }
    return 0;
}

function IsNullOrEmpty(val:String):Bool {
    return val == null || val.length == 0;
}

function ToLispVariant(val:Dynamic) {
    var ret:LispVariant = cast(val, LispVariant);
    return ret;
}

/// <summary>
/// Gets the script files from program arguments.
/// Returns all elements of the given args array which does not start with a "-".
/// </summary>
/// <param name="args">The arguments.</param>
/// <returns>Array of string names</returns>
function GetScriptFilesFromProgramArgs(/*string[]*/ args:Array<String>):Array<String>  // string[]
{
    return args.filter(function (s) { return s.indexOf("-") != 0; });
//    return new Array<String>();  //args.Where(s => !s.StartsWith("-")).ToArray();
}

/// <summary>
/// Reads a file or returns an empty string.
/// </summary>
/// <param name="fileName">Name of the file.</param>
/// <returns>Content of the file as string</returns>
function ReadFileOrEmptyString(fileName:String):String
{
    var exists:Bool = false;
    try
    {
//TODO        exists = File.Exists(fileName);
    }
    catch (ArgumentException)
    {
        exists = false;
    }
    return  "";  //exists ? File.ReadAllText(fileName) : /*string.Empty*/"";   //TODO
}

/// <summary>
/// Decorates the code with a block.
/// </summary>
/// <param name="code">The code.</param>
/// <param name="offset">The position offset created by the decorated code.</param>
/// <returns>Decorated code.</returns>
function DecorateWithBlock(code:String, /*out*/ offset:Ref<Int>):String
{
    var /*const string*/ block = "(do ";
    offset.value = block.length;
    return block + code + "\n)";
}
