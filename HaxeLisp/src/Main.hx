/**
    Multi-line comments for documentation.
**/

using LispScope;
using LispUtils;

class Main {

    public static function MainExtended(/*string[]*/ args:Array<String>, output:TextWriter, input:TextReader)
    {
        if (args.length == 0)
        {
            Usage(output);
            return;
        }

        var /*List<string>*/ allArgs = args; //.ToList();

        var script:String = null;
        var loadFiles = true;
        var trace = false;
        var macroExpand = false;
        var compile = false;
        var wasDebugging = false;
        var showCompileOutput = false;
        var measureTime = false;
        var lengthyErrorOutput = false;
        var interactiveLoop = false;
        var startDebugger = false;
        var result = new LispVariant(null);
        var startTickCount = 0; //TODOEnvironment.TickCount;
//TODO        var debugger = TryGetDebugger();

        if (ContainsOptionAndRemove(allArgs, "-m"))
        {
            measureTime = true;
        }
        if (ContainsOptionAndRemove(allArgs, "-v"))
        {
            output.WriteLine(Lisp.ProgramName + " " + Lisp.Version + " from " + Lisp.Date);
            return;
        }
        if (ContainsOptionAndRemove(allArgs, "-h"))
        {
            Usage(output);
            return;
        }
        if (ContainsOptionAndRemove(allArgs, "--doc"))
        {
            script = "(println (doc))";
            loadFiles = false;
        }
        if (ContainsOptionAndRemove(allArgs, "--html"))
        {
            script = "(println (htmldoc))";
            loadFiles = false;
        }
        if (ContainsOptionAndRemove(allArgs, "--macro-expand"))
        {
            macroExpand = true;
        }
        if (ContainsOptionAndRemove(allArgs, "-x"))
        {
            lengthyErrorOutput = true;
        }
        if (ContainsOptionAndRemove(allArgs, "-t"))
        {
            trace = true;
        }
        if (ContainsOptionAndRemove(allArgs, "-e"))
        {
            script = LispUtils.GetScriptFilesFromProgramArgs(args).FirstOrDefault();
            loadFiles = false;
        }
/*TODO        
        var libPath = args.Where(v => v.StartsWith("-l=")).Select(v => v).ToArray();
        if (libPath.Length > 0)
        {
            if (libPath.Length == 1)
            {
                var libraryPath = libPath.First().Substring(3);
                LispUtils.LibraryPath = libraryPath;
                ContainsOptionAndRemove(allArgs, libPath.First());
            }
            else
            {
                output.WriteLine("Error: only one library path is supported");
                return;
            }
        }
*/
        // handle options for compiler
        if (ContainsOptionAndRemove(allArgs, "-c"))
        {
            compile = true;
        }
        if (ContainsOptionAndRemove(allArgs, "-s"))
        {
            showCompileOutput = true;
        }
/*TODO
        // handle options for debugger
        if (debugger != null)
        {
            if (ContainsOptionAndRemove(allArgs, "-i"))
            {
                interactiveLoop = true;
            }
            if (ContainsOptionAndRemove(allArgs, "-d"))
            {
                startDebugger = true;
            }
        }
*/
        var scriptFiles = LispUtils.GetScriptFilesFromProgramArgs(args);

        // check if all command line options could be consumed
        allArgs = allArgs.filter(function (x) { return !scriptFiles.contains(x); });
        //allArgs = allArgs.Where(x => !scriptFiles.Contains(x)).ToList();    // remove script files from option list
        if (allArgs.length > 0)
        {
//TODO            output.WriteLine('Error: unknown option(s) ${LispUtils.DumpEnumerable(allArgs, " ")}');
            return;
        }

//TODO        
        // if (debugger != null)
        // {
        //     debugger.SetInputOutputStreams(output, input);
        //     if (interactiveLoop)
        //     {
        //         InteractiveLoopHeader(output);
        //         debugger.InteractiveLoop(/*startedFromMain:*/ true, /*tracing:*/ trace);
        //         loadFiles = false;
        //         wasDebugging = true;
        //     }
        //     if (startDebugger)
        //     {
        //         var fileName = LispUtils.GetScriptFilesFromProgramArgs(args).FirstOrDefault();
        //         // process -e option if script is given via command line
        //         if (script == null)
        //         {
        //             script = LispUtils.ReadFileOrEmptyString(fileName);
        //         }
        //         else
        //         {
        //             fileName = "command-line";
        //         }

        //         InteractiveLoopHeader(output);
        //         result = debugger.DebuggerLoop(script, fileName, /*tracing:*/ trace);
        //         loadFiles = false;
        //         wasDebugging = true;
        //     }
        // }

        if (loadFiles)
        {
            for (fileName in scriptFiles)
            {
                script = LispUtils.ReadFileOrEmptyString(fileName);
                /*
                ILispCompiler compiler = TryGetCompiler();
                if (compile && compiler != null)
                {
                    result = compiler.CompileToExe(script, fileName + ".exe");
                }
                else if (showCompileOutput && compiler != null)
                {
                    result = compiler.CompileToCsCode(script);
                    output.WriteLine(result.StringValue);
                }
                else
                */
                {
                    result = Lisp.SaveEval(script, /*moduleName:*/ fileName, /*verboseErrorOutput:*/ lengthyErrorOutput, /*tracing:*/ trace, /*onlyMacroExpand:*/ macroExpand);
                }
            }
        }
        else if (script != null && !wasDebugging)
        {
            // process -e option
            result = Lisp.SaveEval(script, /*onlyMacroExpand:*/ macroExpand);
            trace("RESULT:", /*result,*/ result.TypeString, result.ToString());
        }

        if (macroExpand)
        {
            output.WriteLine("Macro expand: " + result);
        }
        if (trace)
        {
            output.WriteLine("Result=" + result);
        }
        if (measureTime)
        {
//TODO            output.WriteLine('Execution time = ${(Environment.TickCount - startTickCount) * 0.001} s');
        }
    }

    private static function ContainsOptionAndRemove(/*List<string>*/ args:Array<String>, option:String):Bool
    {
        if (args.contains(option))
        {
            args.remove(option);
            return true;
        }

        return false;
    }

    private static function Usage(output:TextWriter)
    {
        ShowAbout(output);
        output.WriteLine("usage:");
        output.WriteLine(">" + Lisp.ProgramName + " [options] [script_file_name]");
        output.WriteLine();
        output.WriteLine("options:");
        output.WriteLine("  -v             : show version");
        output.WriteLine("  -h             : show help");
        output.WriteLine("  -e \"script\"    : execute given script");
        output.WriteLine("  -l=\"path\"      : path to library");
        output.WriteLine("  --doc          : show language documentation");
        output.WriteLine("  --html         : show language documentation in html");
        output.WriteLine("  --macro-expand : expand all macros and show resulting code");
        output.WriteLine("  -m             : measure execution time");
        output.WriteLine("  -t             : enable tracing");
        output.WriteLine("  -x             : exhaustive error output");
/*TODO
        if (TryGetDebugger() != null)
        {
            output.WriteLine("  -i             : interactive shell");
            output.WriteLine("  -d             : start debugger");
        }
        else
        {
            output.WriteLine();
            output.WriteLine("Info: no debugger support installed !");
        }
        if (TryGetCompiler() != null)
        {
            output.WriteLine("  -c             : compile program");
            output.WriteLine("  -s             : show C# compiler output");
        }
        else
        {
            output.WriteLine();
            output.WriteLine("Info: no compiler support installed !");
        }
*/        
        output.WriteLine();
    }

        
    /// <summary>
    /// Show the version of this FUEL interpreter.
    /// </summary>
    /// <param name="output">The output stream.</param>
    public static function ShowVersion(output:TextWriter)
    {
      output.WriteLine();
      output.WriteLine(Lisp.Name + " " + Lisp.Version + " (for " + Lisp.Platform + ") from " + Lisp.Date + ", " + Lisp.Copyright);
      output.WriteLine();
    }

    /// <summary>
    /// Show informations about this FUEL interperter.
    /// </summary>
    /// <param name="output">The output stream.</param>
    public static function ShowAbout(output:TextWriter)
    {
      ShowVersion(output);
      output.WriteLine(Lisp.Info);
      output.WriteLine();
    }

  static public function main():Void {
      // see: https://haxe.org/manual/lf-target-defines.html
#if sys      
      var args = Sys.args();
#else
      var args = new Array<String>();
#end
      trace("ARGUMENTS:", args);            
      MainExtended(args, new TextWriter(), new TextReader());
  }


  static public function mainx():Void {
      //var args = Sys.args();  // -> Accessing this field requires a system platform (php,neko,cpp,etc.)
      trace("Hello World");
      var token = new LispToken.LispToken("1.2", 0, 2, 7);
      trace(token);
      var token2 = new LispToken.LispToken("42", 0, 2, 7);
      trace(token2);
      trace(Std.parseFloat("1.234d"));
      trace(haxe.Json.parse("1.234"));

      var i = 3;
      var lv:Dynamic = LispVariant.forValue(3.3);
      trace("#############################");
      trace(i is LispVariant);

      var scope = LispEnvironment.CreateDefaultScope();
      //var ast = LispParser.Parse("(do (+ 1 2 (* 3 42)) (- 3 2))");
      //var ast = LispParser.Parse("(do (defn f (x) 
      //                                    (+ x 1)
      //                                )                              
      //                                (f 7))");
      var ast = LispParser.Parse("(do (def i 1) (setf i (+ i 1)))");
      //var ast = LispParser.Parse("(fuel)");
      //var ast = LispParser.Parse("(!= 1 2)");
      //var ast = LispParser.Parse("(fuel 1 2 3 4)");
      trace("AST:");
      trace(ast);
      var interpRes = LispInterpreter.EvalAst(ast, scope);
      trace("RESULT:",interpRes, "value=",interpRes.Value);
    }
}
