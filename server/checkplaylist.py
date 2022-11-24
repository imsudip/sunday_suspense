import requests

adventure_id = 'PLq71IJk8mCV4bl9PzA1RJ6ipr0TBw-7VK'
crime_id = 'PLq71IJk8mCV4YmG5ULzAq2QCZqdDRWLhO'
horror_id = 'PLq71IJk8mCV4vFBqzx4JmLpWFtvpl93Sv'
thriller_id = 'PLq71IJk8mCV7tZ7b3BLx5lZitMvlGL-9p'


def get_rss_feed(playlist_id):
    url = 'https://api.rss2json.com/v1/api.json?rss_url=https://www.youtube.com/feeds/videos.xml?playlist_id=' + playlist_id
    response = requests.get(url)
    data = response.json()
    video_ids = []
    for item in data['items']:
        video_ids.append(item['link'].split('=')[1])
    return video_ids


def check_playlist_inclusion(video_id):
    adventure_ids = get_rss_feed(adventure_id)
    crime_ids = get_rss_feed(crime_id)
    horror_ids = get_rss_feed(horror_id)
    thriller_ids = get_rss_feed(thriller_id)

    tags = []
    if video_id in adventure_ids:
        tags.append('adventure')
    if video_id in crime_ids:
        tags.append('crime')
    if video_id in horror_ids:
        tags.append('horror')
    if video_id in thriller_ids:
        tags.append('thriller')
    return tags
