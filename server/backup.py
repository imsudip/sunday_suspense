import os
from dotenv import load_dotenv
import json
import meilisearch


load_dotenv()
meiliClient = meilisearch.Client(
    "https://meilisearch-on-koyeb-imsudip.koyeb.app/", os.getenv('MASTER_KEY'))
try:
    index = meiliClient.index('sunday')
    # get all documents and save to json file
    all_docs = index.get_documents({'limit': 100000})
    d = all_docs.results
    d2 = []
    for item in d:
        d2.append(item.__dict__['_Document__doc'])
    if len(d2) > 0:
        with open('sunday.json', 'w', encoding='utf-8') as f:
            json.dump(d2, f, ensure_ascii=False, indent=4)

    print("total docs count: "+str(len(d2)))

# catch exception
except Exception as e:
    print(e)
    print("error")
finally:
    print("done")
