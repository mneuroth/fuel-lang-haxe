
import utest.Runner;
import utest.ui.Report;

class MainTest {
    static function main() {
      var runner = new Runner();
      runner.addCase(new LispTokenTest());
      runner.addCase(new LispTokenizerTest());
      runner.addCase(new LispParserTest());
      Report.create(runner);
      runner.run();
    }
  }