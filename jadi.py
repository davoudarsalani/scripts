#!/usr/bin/env python

## last modified: 1400-09-02 23:12:01 Tuesday

from os import getenv

from googleapiclient.discovery import build
from gp import msgc, get_headers, get_datetime, last_file_exists, save_as_last, save_error, get_last

api_key = getenv('api_jadi')
channel_id = 'UCgKePkWtPuF36bJy0n2cEMQ'
last_file = f'{getenv("HOME")}/scripts/.last/jadi'
error_file = f'{getenv("HOME")}/scripts/.error/jadi'
message_text = ''

try:
    youtube = build('youtube', 'v3', developerKey=api_key)
    request = youtube.channels().list(part='statistics', id=channel_id)
    response = request.execute()
    count = int(response['items'][0]['statistics']['videoCount'])

    ## get last count
    if last_file_exists(last_file):
        count_last = int(get_last(last_file))

    ## get new count
    ## already got in try

    ## save count as last to compare in our next read
    save_as_last(last_file, count)

    ## compare
    if last_file_exists(last_file):
        diff = count - count_last
        if diff > 0:
            msgc('jadi', f'new video: {diff}')

            ## get the titles
            try:
                request = youtube.search().list(part='snippet', order='date', channelId=channel_id)
                response = request.execute()

                videos = response['items']

                ## add all titles to the message text
                for i in range(diff):
                    video = videos[i]
                    title = video['snippet']['title']
                    message_text = f'{message_text}{i} {title}\n'

                msgc('title', message_text.strip())

            except Exception as exc:
                ## save error
                save_error(error_file, f'{exc!r}')

except Exception as exc:
    ## save error
    save_error(error_file, f'{exc!r}')

##############################################################################
## OR using urls:
## https://jingwen-z.github.io/how-to-get-a-youtube-video-information-with-youtube-data-api-by-python/
## https://developers.google.com/youtube/v3/docs/channels/list#parameters
## https://developers.google.com/youtube/v3/docs/search/list#parameters

# Ses = Session()
# hdrs = get_headers()
# url_for_count = f'https://www.googleapis.com/youtube/v3/channels?part=statistics&id={channel_id}&key={api_key}'
# url_for_title = f'https://www.googleapis.com/youtube/v3/search?key={api_key}&channelId={channel_id}&part=snippet&order=date&maxResults=20'

####### get count

## try:
# response = S.get(url_for_count, headers=hdrs, timeout=20)

####### get title
## https://stackoverflow.com/questions/18953499/youtube-api-to-fetch-all-videos-on-a-channel

## try:
# response = S.get(url_for_title, headers=hdrs, timeout=20)
## else:
# response = response.json()
##############################################################################
## OR using youtube_dl:
## as in download.py in Playlist.get_playlist_urls()
