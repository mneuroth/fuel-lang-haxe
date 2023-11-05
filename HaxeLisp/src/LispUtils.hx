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

 class ArrayExtender {
    static public function First(arr:Array<Dynamic>) {
        if (arr.length == 0) {
            throw new LispTokenizer.LispException("Array<Dynamic> has no elements!");
        }
        return arr[0];
    }
    static public function Last(arr:Array<Dynamic>) {
        if (arr.length == 0) {
            throw new LispTokenizer.LispException("Array<Dynamic> has no elements!");
        }
        return arr[arr.length - 1];
    }
    static public function FirstOrDefault(arr:Array<Dynamic>) {
        if (arr.length == 0) {
            return null;
        }
        return arr[0];
    }
    static public function Add(arr:Array<Dynamic>, item:Dynamic) {
        arr.push(item);
    }
}