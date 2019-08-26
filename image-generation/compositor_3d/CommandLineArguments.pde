
import java.util.Date;

// Command Line Arguments

/* 
$ processing-java
  --sketch=/full/path/to/your/sketch/dir --output=/path/to/output/dir --force --run \# defaults
  timestamp \# should be timestamp in unix epoch seconds
  counter \# number between 0 and 75000
  one_shot \# "true" or "false" 
*/

long getTimestampFromArgs() {
  if (args != null) {
    return Long.parseLong(args[0]);
  } else {
    // unix epoch timestamp, default to Wed Apr 17 20:00:00 EDT 2019
    return Long.parseLong("1555545600");
  }
}

Date getDateFromTimestamp(long ts) {
  return new Date(ts * 1000);
}

int getIndexFromArgs() {
  if (args != null) {
    return parseInt(args[1]);
  } else {
    // unix epoch timestamp
    return floor(random(75000));
  }
}

boolean getOneShotFromArgs() {
  if (args != null) {
    return boolean(args[2]);
  } else {
    return false;
  }
}
