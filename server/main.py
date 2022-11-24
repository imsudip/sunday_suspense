import os
from dotenv import load_dotenv
import build_new_item
import requests
import json
import meilisearch


load_dotenv()
meiliClient = meilisearch.Client(
    "https://meilisearch-on-koyeb-imsudip.koyeb.app/", os.getenv('MASTER_KEY'))
firebase_key = os.getenv('FIREBASE_KEY')


def check_item_exists(video_id) -> bool:
    index = meiliClient.get_index('sunday')
    search = index.search(" ", {"filter": f"video_id = {video_id}"})
    if search['estimatedTotalHits'] > 0:
        return True
    else:
        return False


def send_notification(song_data):
    print('Sending notification...')
    url = 'https://fcm.googleapis.com/fcm/send'
    not_data = {
        "to": "/topics/news",
        "notification": {
            "title": song_data["title"],
            "body": "Listen to this week's Sunday Suspense! 😱",
        },
    }
    headers = {"Content-Type": "application/json",
               "Authorization": firebase_key}
    response = requests.post(url, data=json.dumps(not_data), headers=headers)
    print(response.text)


def update_db():
    playlist_url = 'https://api.rss2json.com/v1/api.json?rss_url=https%3A%2F%2Fwww.youtube.com%2Ffeeds%2Fvideos.xml%3Fplaylist_id%3DPLq71IJk8mCV4-DqsZ7W6zRS7uzKOmmT8j'
    response = requests.get(playlist_url)
    data = response.json()
    count = 0
    new_items = []
    for item in data['items']:
        video_id = item['link'].split('=')[1]
        link = 'https://www.youtube.com/watch?v=' + video_id
        if not check_item_exists(video_id):
            print('New item found!')
            print('Building new item...')
            new_item = build_new_item.getVideoDataFromLink(link)
            new_items.append(new_item)
            count += 1

    print(f'{count} new items added!')
    print(new_items)
    if count > 0:
        index = meiliClient.get_index('sunday')
        index.add_documents(new_items)
        send_notification(new_items[0])
    return


if __name__ == "__main__":
    update_db()

# cron job
# every 4 hours on every sunday
# 0 */4 * * 0 python3
