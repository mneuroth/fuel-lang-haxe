
import utest.Runner;
import utest.ui.Report;

class MainTest {
    static function main() {
      var runner = new Runner();
      runner.addCase(new LispTokenTest());
      Report.create(runner);
      runner.run();
    }
  }