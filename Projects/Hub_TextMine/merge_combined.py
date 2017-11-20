import pandas as pd

public = pd.read_csv('C:/GTP/Programming/roadshow_text/prepped_data/hub_2179_nov20_prep.csv', encoding='utf-8')
public['source'] = 'public_hub'


private = pd.read_csv('C:/GTP/Programming/roadshow_text/prepped_data/hub_2174_nov20_prep.csv', encoding='utf-8')
private['source'] = 'private_hub'

viya = pd.read_csv('C:/GTP/Programming/roadshow_text/prepped_data/hub_1809_nov20_prep.csv', encoding='utf-8')
viya['source'] = 'viya_hub'

merged = pd.concat([public, private, viya], axis=0)
#merged = merged.drop(['key'], axis=1)

merged=merged.reset_index(drop=True)
merged.index.name='id'

print(merged.head())
print(len(merged))

merged.to_csv('C:/GTP/Programming/roadshow_text/prepped_data/ViyaLIVE_HUB_combined_final.csv', encoding='utf-8')