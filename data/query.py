import sqlite3
import csv

conn = sqlite3.connect('archive.sqlite')
c = conn.cursor()

# with open('2019-04-17_12pm-8pm.csv', 'w', newline='') as csvfile:
#     spamwriter = csv.writer(csvfile, delimiter=',',
#                             quotechar='"', quoting=csv.QUOTE_MINIMAL)
#     for row in c.execute('select * from data where created_at BETWEEN 1555516800 and 1555545600'):
#         spamwriter.writerow(row)

import pprint
pp = pprint.PrettyPrinter(indent=2)
stations = {}

#for row in c.execute('select * from data where created_at BETWEEN 1555516800 and 1555545600'):
for row in c.execute('select * from data where created_at BETWEEN 1555358400 and 1557061200'):
    if row[0] == 'key':
        continue
    # print()
    sensor = row[0]
    values = row[1].split(' ')
    sumval = sum(int(v) for v in values)
    time = row[2]

    ## see the raw data
    #print('{}\t  {}: {} '.format(sensor, time, sum(int(v) for v in values)))

    # calculations

    if sensor != 'mood':
        if not sensor in stations:
            stations[sensor] = {
                'count': 1,
                'sum': sumval,
                'avg': sumval,
                'max': sumval,
                'min': sumval
            }
        else:
            c = stations[sensor]
            c['count'] = c['count'] + 1
            c['sum'] = c['sum'] + sumval

            c['max'] = sumval if sumval > c['max'] else c['max']
            c['min'] = sumval if sumval < c['min'] else c['min']
            c['avg'] = c['sum'] / c['count']
    else:
        if not sensor in stations:
            stations[sensor] = {
                'count': 1,
                'values': values,
            }
        else:
            c = stations[sensor]
            c['count'] = c['count'] + 1
            c['values'] = c['values'] + values

# convert mood to one long string
stations['mood']['values'] = ' '.join(stations['mood']['values'])

pp.pprint(stations)

