import sqlite3
import json

conn = sqlite3.connect('archive.sqlite')
c = conn.cursor()

for row in c.execute('select count(*) from weather;'):
    print("ALREADY HAVE:")
    print(row)

weather = open('weather.log', 'r')

count = 0

for line in weather.readlines():
    val = json.loads(line)
    current = val['current']

    if current:
        try:
            c.execute('insert into weather (created_at, value) values (?, ?);',
                      (current['time'], json.dumps(current)))
        except sqlite3.IntegrityError:
            # record already present :+1:
            pass

        # break # safety cutoff

    if count % 1000 == 0:
        print(count)
    count += 1

conn.commit()

print('done!')
