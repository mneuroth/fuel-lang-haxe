
import utest.Runner;
import utest.ui.Report;

class MainTest {
    static function main() {
      var runner = utest.Runner();
      runner.addCase(new LispTokenTest());
      utest.ui.Report.create(runner);
      runner.run();
    }
  }