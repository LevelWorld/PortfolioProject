from bs4 import BeautifulSoup
import requests
import pandas as pd
url = 'https://en.wikipedia.org/wiki/List_of_largest_companies_by_revenue'
page = requests.get(url)
soup = BeautifulSoup(page.text, 'html')

table = soup.find('table')

world_titles = table.find_all('th')
world_tables_titles = [title.text.strip() for title in world_titles]
while world_tables_titles[ len(world_tables_titles) - 1] != 'Revenue per worker':
    world_tables_titles.pop()

df  = pd.DataFrame(columns = world_tables_titles)
df

column_data = table.find_all('tr')
count = 0
for row in column_data[2:]:
    count = count + 1
    row_data = (row.find_all('td'))
    individual_row_data = [title.text.strip() for title in row_data]
    individual_row_data.insert(0,count)
    length = len(df)
    
    df.loc[length] = individual_row_data

df
df.to_csv(r'D:\career\Python\comp.csv', index = False)
