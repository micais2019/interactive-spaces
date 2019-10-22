
import java.util.Date;

// Command Line Arguments

/* 
$ processing-java
  --sketch=/full/path/to/your/sketch/dir --output=/path/to/output/dir --force --run \# defaults
  counter \# number between 0 and 75000
  one_shot \# "true" or "false" 
*/

Date getDateFromTimestamp(long ts) {
  return new Date(ts * 1000);
}

int getIndexFromArgs() {
  if (args != null) {
    return parseInt(args[0]);
  } else {
    // unix epoch timestamp
    return floor(random(75000));
  }
}

boolean getOneShotFromArgs() {
  if (args != null && args.length > 2) {
    return boolean(args[1]);
  } else {
    return false;
  }
}
