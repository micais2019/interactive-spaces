import de.bezier.data.sql.*;
import de.bezier.data.sql.mapper.*;
import http.requests.*;

float sum(FloatList values) {
  float out = 0;
  for (float val : values) {
    out += val;
  }
  return out;
}

float average(FloatList values) {
  return sum(values) / values.size();
}


class DataLoader {
  SQLite db;
  
  String[] weatherData, soundData, motionData, moodData;
  
  DataLoader(PApplet app) {
    db = new SQLite(app, "archive.sqlite");
    db.connect();
  }
  
  String conditionsAtTimeForKey(long ts, String sensor) {
    return  "created_at > '" + Long.toString(ts) + "' and key = '" + sensor + "' ";
  }
 
  StringList queryAtTimeForKey(long ts, String _key, int limit) {
    String conditions = conditionsAtTimeForKey(ts, _key);
    db.query("select value from data where " + conditions + " limit " + str(limit));
    StringList results = new StringList();
    while (db.next()) {
      // println("LOADED " + _key + " DATA:", db.getString("value"));
      results.append(db.getString("value"));
    }
    return results;
  }
    
  //////////
  // Sound Data
  //////////
  float soundToScore(int level) {
    level = constrain(level, 200, 10000);
    return float(level) / 10000.0;
  }

  FloatList getSound1Scores(long ts) {
    return getSoundScores(ts, 1);
  }
  
  FloatList getSound2Scores(long ts) {
    return getSoundScores(ts, 2);
  }

  FloatList getSoundScores(long ts, int station) {
    int limit = 3;
   
    StringList results;
    if (station == 1) {
      results = queryAtTimeForKey(ts, "sound", limit);
    } else {
      results = queryAtTimeForKey(ts, "sound-2", limit);
    }
    
    FloatList soundScores = new FloatList();
    for (String value : results) {
      soundData = split(value, " "); // one recorded sound value
      for (int i=0; i < soundData.length; i++) {
        soundScores.append(soundToScore(int(soundData[i])));
      }
    }
    
    return soundScores;
  }


  //////////
  // Motion Data
  //////////
  
  FloatList getMotionScores(long ts) {
    int limit = 4;
    StringList results = queryAtTimeForKey(ts, "motion", limit);
    FloatList motionScores = new FloatList();
    for (String value : results) {
      motionData = split(value, " "); // one recorded sound value
      for (int i=0; i < motionData.length; i++) {
        motionScores.append(int(motionData[i]));
      }
    }
    
    return motionScores;
  }
  
  //////////
  // Mood Data
  //////////
  
  IntList getMoodValues(long ts) {
    int limit = 100;
    StringList results = queryAtTimeForKey(ts, "mood", limit);
    IntList moodValues = new IntList();
    boolean enough = false;
    for (String value : results) {
      moodData = split(value, " ");
      for (int i=0; i < moodData.length; i++) {
        moodValues.append(int(moodData[i])); 
        // stop gathering once we hit 100 individual values
        if (moodValues.size() >= 100) {
          enough = true;
          break;
        }
      }
      if (enough) {
        break;
      }
    }
    return moodValues;
  }
  
  // web request to micavibe.com
  /* expected response format:
  {
    "at": 1555159202016,
    "current": {
      "time": 1555159201,
      "summary": "Mostly Cloudy",
      "icon": "partly-cloudy-day",
      "nearestStormDistance": 17,
      "nearestStormBearing": 146,
      "precipIntensity": 0,
      "precipProbability": 0,
      "temperature": 61.48,
      "apparentTemperature": 61.48,
      "dewPoint": 57.94,
      "humidity": 0.88,
      "pressure": 1019.6,
      "windSpeed": 2.83,
      "windGust": 2.83,
      "windBearing": 141,
      "cloudCover": 0.83,
      "uvIndex": 1,
      "visibility": 7.16,
      "ozone": 301.83
    },
    "_id": "00u61B2bZTYO1ynB",
    "at_formatted": "2019-04-13T12:40:02.016Z"
  }
  */
  
  //////////
  // Weather Data
  //////////
  
  FloatList getWeatherScores(long ts) {
    FloatList weatherScores = new FloatList();
    String conditions = " created_at < '" + Long.toString(ts) + "' ";
    
    // set default values in case the web API craps out for some reason
    String result = "61.48 57.94 88 101.96 61.48 100";
    // ﻿1555092402
    db.query("select value from weather where " + conditions + " ORDER BY created_at DESC limit 1");
    while (db.next()) {
      // println("LOADED WEATHER DATA:", db.getString("value"), "AT", ts);
      result = db.getString("value");
    }
    
    weatherData = split(result, " ");
    
    try {
      JSONObject current = parseJSONObject(result); 
      weatherData = new String[]{
        str(current.getFloat("temperature")),
        str(current.getFloat("dewPoint")),
        str(current.getFloat("cloudCover") * 100 ),
        str(current.getFloat("uvIndex")*10),
        str(current.getFloat("visibility")*10),
        str(constrain(current.getFloat("windSpeed") * 10, 10, 100)),
      };
      // println("LOADED WEATHER DATA", join(weatherData, " "));
    } catch (RuntimeException ex) {      
      println("ERROR failed to retrieve weather data:", ex.getMessage());
    }
    
    for (int i=0; i < weatherData.length; i++) {
      weatherScores.append(float(weatherData[i]));
    } 
    return weatherScores;
  }
}

void debugDataLoader(DataLoader dload) {
  PrintWriter outfile = createWriter("debug-data.csv");

  for (int i=1; i <= 1000; i++) {
    now = getTimestampFromIndex(i);
    Date d = getDateFromTimestamp(now);

    sound1Scores  = dload.getSound1Scores(now);
    sound2Scores  = dload.getSound2Scores(now);
    moodValues    = dload.getMoodValues(now);
    motionScores  = dload.getMotionScores(now);
    weatherScores = dload.getWeatherScores(now);

    String sound1avg = str(average(sound1Scores) * 10000);
    String sound2avg = str(average(sound2Scores) * 10000);
    String motionMax = str(int(motionScores.max()));
    String motionavg = str(average(motionScores));
    String weather   = "\"" + weatherScores.toString() + "\"";
    String mcount = str(moodValues.size());
    String ns = String.valueOf(now);
    String ds = d.toString();
    String line[] = {
      str(i), ns, ds, sound1avg, sound2avg, motionMax, motionavg, mcount, weather
    };
    String out = join(line, ",");
    
    outfile.println(out);
    println(i, String.valueOf(now));
  }
  
  outfile.flush();
  outfile.close();
  exit();

  if (true) {
    throw new Error("break");
  }
}
