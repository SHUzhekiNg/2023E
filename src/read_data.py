from openpyxl import load_workbook

# Areas to analyze
geo_names = ['New York']

# GDP items to be analyzed
gdp_types = ['All industry total',
             'Construction',
             'Transportation and warehousing',
             'Broadcasting (except Internet) and telecommunications',
             'Finance and insurance',
             'Health care and social assistance',
             'Arts, entertainment, and recreation'
             ]

def read_gdp(filename: str = 'gdp.xlsx') -> dict:
    '''Read GDP data from xlsx file'''
    ret = {}
    workbook = load_workbook(filename)
    # sheet = workbook['Table']
    sheet = workbook.worksheets[0]

    for geo in geo_names:
        ret[geo] = {}
        for row in sheet.rows:
            if row[1].value == geo:
                desc = str(row[3].value).strip()
                num = float(row[4].value) if not row[4].value == '' else 0
                if desc in gdp_types:
                    ret[geo][desc] = num
    return ret

def read_population(filename: str = 'population.xlsx') -> dict:
    '''Read population data from xlsx file'''
    ret = {}
    workbook = load_workbook(filename)
    sheet = workbook.worksheets[0]
    for geo in geo_names:
        ret[geo] = {}
        for row in sheet.rows:
            if row[0].value == geo:
                ret[geo]['Population'] = int(row[1].value)
                ret[geo]['Population Density'] = float(row[2].value)
                ret[geo]['Density Rank'] = int(row[3].value)
    return ret

def generate_power_consumption() -> dict:
    '''Generate power consumption data'''
    ret = {}
    return ret

def generate_csv() -> str:
    '''Generate csv content'''
    # generate title
    ret = 'Area'
    for t in gdp_types:
        ret += ', ' + t.replace(',', '') + '(GDP)'
    ret += ', Population, Population Density, Density Rank\n'

    # read data
    gdp = read_gdp()
    population = read_population()

    # write data
    for geo in geo_names:
        ret += geo
        for t in gdp_types:
            ret += ', ' + str(gdp[geo][t])
        ret += ', ' + str(population[geo]['Population'])
        ret += ', ' + str(population[geo]['Population Density'])
        ret += ', ' + str(population[geo]['Density Rank'])
    return ret

if __name__ == '__main__':
    with open('combined.csv', 'w') as f:
        f.write(generate_csv())

