import os
from dotenv import load_dotenv
import build_new_item
import requests
import json
import meilisearch


load_dotenv()
meiliClient = meilisearch.Client(
    "https://meilisearch-on-koyeb-imsudip.koyeb.app/", os.getenv('MASTER_KEY'))
# firebase_key = os.getenv('FIREBASE_KEY')


# fetch newest item from meilisearch

def get_newest_items():
    index = meiliClient.index('sunday')
    # get the newest item
    all_docs = index.search(" ", {'limit': 5, 'sort': ['timestamp:desc']})
    d = all_docs['hits']
    # print(d)
    for item in d:
        if (item['length'] == 0):
            print('Updating item...')
            print(item['title'])
            new_item = build_new_item.getVideoDataFromLink(item['url'])
            index.update_documents([new_item])
            print('Item updated!')


get_newest_items()
