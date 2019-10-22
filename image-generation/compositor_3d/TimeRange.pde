// Helper classes for picking a timestamp value based on a collection 

final int TOTAL_STEPS = 75000;

// a collection of time ranges, each covering a (start, end) span of time. 
// times in comments are in -0400 (EDT) 
TimeRangeCollection TIMESTAMP_RANGES = new TimeRangeCollection(
  new TimeRange(1555459200, 1556668800), // 2019-04-16 20:00 to 2019-04-30 20:00 (main)
  new TimeRange(1556697600, 1556985600), // 2019-05-01 04:00 to 2019-05-04 04:00 (dolphin)
  new TimeRange(1557014400, 1557054000)  // 2019-05-04 20:00 to 2019-05-05 07:00 (vigil)           
);

// convert index to timestamp
long getTimestampFromIndex(int index) {
  return TIMESTAMP_RANGES.timestampForIndex(index);
}

// a single time range in the collection
class TimeRange {
  long start_time;
  long end_time;
  long span;
  
  float percent_of_total;
  
  int index_count;
  int start_index;
  int end_index;
  
  TimeRange(long s, long e) {
    start_time = s;
    end_time = e;
    span = end_time - start_time;
  }
}

// A collection of time ranges from which we can pick a 
class TimeRangeCollection {
  long total;
  float timestep;
  ArrayList<TimeRange> members;
  
  TimeRangeCollection(TimeRange ... ranges) {
    members = new ArrayList<TimeRange>();
    
    for (TimeRange m : ranges) {
      members.add(m);
      total += m.span;
    }
    
    int steps = TOTAL_STEPS;
    timestep = total / steps;
    int from_step = 1;
    int to_step = 0;
    
    // calculate the indexes (image counters) that each time range covers
    for (TimeRange m : members) {
      m.percent_of_total = m.span / (total * 1.0);
      m.index_count = round(steps * m.percent_of_total);
      
      to_step = from_step + (m.index_count - 1);
      if (to_step > steps) {
        m.index_count = m.index_count - (to_step - 75000); // truncate to 75000 images, max
        to_step = 75000;
      }
      
      m.start_index = from_step;
      m.end_index = to_step;

      from_step = to_step + 1;
    }
  }
  
  long timestampForIndex(int idx) {
    long ts = 0;

    for (TimeRange m : members) {
      if (idx >= m.start_index && idx <= m.end_index) {
        // 
        float ts_perc = (idx - m.start_index) / float(m.index_count);
        ts = (long)(m.start_time + floor(m.span * ts_perc));
      }
    }
    
    return ts;
  }
}
