import pandas as pd

f=open('C:/RCCM/2017 Projects/VIYA/Recommendation Engine/Recom_Engine_Foods_Blog/Data/foods.txt')


fields=['productId','userId','helpfulness','score','time','summary','text']
fields_dict={}
for field in fields:
	fields_dict[field] = []
					
for line in f:
    line=line.rstrip()

    if line.startswith('product/productId:'):
        	line=line.split('product/productId: ')
        	fields_dict['productId'].append(line[1])

    elif line.startswith('review/userId:'):
        	line=line.split('review/userId: ')
        	fields_dict['userId'].append(line[1])

    elif line.startswith('review/helpfulness:'):
        	line=line.split('review/helpfulness: ')
        	fields_dict['helpfulness'].append(line[1])

    elif line.startswith('review/score:'):
        	line=line.split('review/score: ')
        	fields_dict['score'].append(line[1])

    elif line.startswith('review/time:'):
        	line=line.split('review/time: ')
        	fields_dict['time'].append(line[1])

    elif line.startswith('review/summary:'):
        	line=line.split('review/summary: ')
        	fields_dict['summary'].append(line[1])

    elif line.startswith('review/text:'):
        	line=line.split('review/text: ')
        	fields_dict['text'].append(line[1])

reviews = pd.DataFrame.from_dict(fields_dict)

reviews.to_csv('C:/RCCM/2017 Projects/VIYA/Recommendation Engine/Recom_Engine_Foods_Blog/Data/foods_prepped1.csv', sep=',', encoding='utf-8', index=False)