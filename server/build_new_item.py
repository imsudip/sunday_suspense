# {
#         "title": "The Cask of Amontillado - Edgar Allan Poe",
#         "video_id": "CziZzauAa5Y",
#         "date": "2022-09-11T00:00:00",
#         "url": "https://youtube.com/watch?v=CziZzauAa5Y",
#         "thumbnail": "https://i.ytimg.com/vi/CziZzauAa5Y/sddefault.jpg?v=631f040a",
#         "length": 2362,
#         "views": 507970,
#         "author": "Mirchi Bangla",
#         "description": "Mirchi Bangla presents Edgar Allan Poe's The Cask of Amontillado on Sunday Suspense\n\nDate of Broadcast - 11th September, 2022\n\nMontresor - Deep\nFortunato - Agni\n\nTranslated, Adapted and Directed by Pushpal\nProduction, Sound Design and Original Music - Pradyut\nPoster Design - Join the Dots\nExecutive Producer - Alto\n\nInterns\n\nArpan Chatterjee\nSaptanil Maji\nUtsa Dey\n\nEnjoy and stay connected with us!!\n\nSubscribe to us :\nhttp://bit.ly/SubscribeMirchiBangla\n\nLike us on Facebook\nhttps://www.facebook.com/MirchiBangla/\n\nFollow us on Instagram\nhttps://www.instagram.com/mirchibangla/",
#         "blurhash": "V34UvhD%EMyDIAs.aeWBofn$0K%g%1Mw%MM|ozt6WAbc",
#         "tags": [
#             "horror"
#         ],
#         "timestamp": 1662834600
#     },

import requests
import json
import pytube
import datetime
import blurhash
import io
import checkplaylist


def getBlurHashFromLink(url):
    img = requests.get(url).content
    img_io = io.BytesIO(img)
    blurString = blurhash.encode(img_io, 5, 4)
    return blurString


def clean_up_title(title) -> str:
    wildcards = [
        "Mirchi 98.3",
        "Radio Mirchi",
        "Radio Mirchi 98.3",
        "Radio Mirchi 98.3 FM",
        "Sunday Suspense",
        "#SundaySuspense",
        "Mirchi Bangla",
        "Radio Mirchi Bangla",
        "#Sunday Suspense",
        "#Sunday Suspense",
        "98.3",
        "#SundayNonsense",
    ]
    # remove all invisible characters
    title = title.replace("\u200b", "")

    splits = title.split("|")
    # strip whitespaces
    splits = [x.strip() for x in splits]
    if len(splits) > 1:
        # check if any of the wildcards are present
        for wildcard in wildcards:
            if wildcard in splits:
                # remove the wildcard
                splits.remove(wildcard)
        # join the splits
        title = " - ".join(splits)
        # update the title
        return title
    else:
        sp2 = title.split("-")
        sp2 = [x.strip() for x in sp2]
        if len(sp2) > 1:
            for wildcard in wildcards:
                if wildcard in sp2:
                    sp2.remove(wildcard)
            title = " - ".join(sp2)
            return title
        else:
            return title


def getVideoDataFromLink(url):
    yt = pytube.YouTube(url)
    v = {
        "title": clean_up_title(yt.title),
        "video_id": yt.video_id,
        "date": yt.publish_date.isoformat(),
        "url": yt.watch_url,
        "thumbnail": yt.thumbnail_url,
        "length": yt.length,
        "views": yt.views,
        "author": yt.author,
        "description": yt.description,
        "blurhash": getBlurHashFromLink(yt.thumbnail_url),
        "tags": checkplaylist.check_playlist_inclusion(yt.video_id),
        "timestamp": int(datetime.datetime.timestamp(yt.publish_date))
    }

    return v
