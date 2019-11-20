import sqlite3
import csv

conn = sqlite3.connect('archive.sqlite')
c = conn.cursor()

# start: 2019-04-15 16:00:00
# end:   2019-05-05 09:00:00
#
#  'motion': { 'avg': 212.34256309757833,
#              'count': 821545,
#              'max': 5344,
#              'min': 0,
#              'sum': 174448971},
#  'sound': { 'avg': 15749.590682942171,
#             'count': 403797,
#             'max': 839413,
#             'min': 898,
#             'sum': 6359637469},
#  'sound-2': { 'avg': 16553.804505787237,
#               'count': 408053,
#               'max': 785436,
#               'min': 4497,
#               'sum': 6754829590}


import pprint
pp = pprint.PrettyPrinter(indent=2)
stations = {}

start_date = datetime.fromtimestamp(1555358400)
end_date = datetime.fromtimestamp(1557061200)

print("start: {}".format(start_date))
print("end:   {}".format(end_date))

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

