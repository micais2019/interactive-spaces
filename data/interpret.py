import csv

import pprint
pp = pprint.PrettyPrinter(indent=2)

stations = {}

with open('2019-04-17-12pm_to_8pm.csv', newline='') as csvfile:
    data_reader = csv.reader(csvfile, delimiter=',', quotechar='"')

    for row in data_reader:
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
