
import utest.Runner;
import utest.ui.Report;

class MainTest {
    static function main() {
      var runner = new Runner();
      runner.addCase(new LispTokenTest());
      runner.addCase(new LispTokenizerTest());
      runner.addCase(new LispParserTest());
      runner.addCase(new LispVariantTest());
      Report.create(runner);
      runner.run();
    }
  }