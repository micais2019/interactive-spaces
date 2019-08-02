
import java.util.Date;

long getTimestampFromArgs() {
  if (args != null) {
    return Long.parseLong(args[0]);
  } else {
    // unix epoch timestamp
    return (new Date()).getTime() / 1000;
  }
}

int getIndexFromArgs() {
  if (args != null) {
    return parseInt(args[1]);
  } else {
    // unix epoch timestamp
    return floor(random(75000));
  }
}
