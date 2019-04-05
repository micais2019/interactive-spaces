
import java.util.Date;

long getTimestampFromArgs() {
  if (args != null) {
    return Long.parseLong(args[0]);
  } else {
    return (new Date()).getTime() / 1000;
  }
}
