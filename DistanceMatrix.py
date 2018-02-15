import googlemaps
from datetime import datetime
import xlrd
import xlwt
from time import sleep

s = 1
l = 1
workbook = xlrd.open_workbook("C:\\Users\\Amlendu11\\Downloads\\DUBS\\Vehicle Routing\\Origins.xlsx")
worksheet = workbook.sheet_by_index(0)
num_rows = worksheet.nrows
origins = []
destinations = []
book = xlwt.Workbook(encoding="utf-8")
sheet1 = book.add_sheet("Distance Matrix")
sheet2 = book.add_sheet("Time Matrix")

for k in range(1,14,1):
    for i in range((k-1)*10, (k-1)*10+10, 1):
        data = str(worksheet.cell_value(i, 0))
        #print(data)
        origins.append(data)
        l = l+1

    for f in range(1,14,1):
        for o in range((f-1)*10, (f-1)*10+10, 1):
            data1 = str(worksheet.cell_value(o, 0))
            destinations.append(data1)
            s = s+1

        key = 'AIzaSyDxAb5n0kS8F_AcJAOyKg7-5md0qfEtChc'
        client = googlemaps.Client(key)
        now = datetime(2017, 8, 22, 10, 0, 0)
        #print(origins)
        matrix = client.distance_matrix(origins, destinations,
                                        mode="driving",
                                        language="en-AU",
                                        avoid="tolls",
                                        units="metric",
                                        departure_time=now,
                                        traffic_model="optimistic")

        #print(matrix)[0]['elements'][0]['distance']['value']
        #print(matrix['rows'][1]['elements'][1]['distance']['value'])
        #print(matrix)
        for w in range((f-1)*10, (f-1)*10+10, 1):
            for e in range((k-1)*10, (k-1)*10+10, 1):
                sheet1.write(w, e, matrix['rows'][(w%10)]['elements'][(e%10)]['distance']['value'])
                sheet2.write(w, e, matrix['rows'][(w%10)]['elements'][(e%10)]['duration']['value'])

        destinations = []
        if (s >= 121):
            print(s)
            break
        sleep(10)

    if (l >= 121):
        print(l)
        break
    s = 1
    origins = []
    destinations = []
    matrix = []
    print(str(l))
book.save("C:\\Users\\Amlendu11\\Downloads\\DUBS\\Vehicle Routing\\Distance Matrix_10.xls")
