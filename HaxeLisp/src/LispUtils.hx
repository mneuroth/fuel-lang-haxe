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
    static public function ToList(arr:Array<Dynamic>):Array<Dynamic> {
        return arr;
    }
    static public function Skip(arr:Array<Dynamic>, count:Int):Array<Dynamic> {
        arr = arr.slice(0, count);
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
