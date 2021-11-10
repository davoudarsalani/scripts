#!/usr/bin/env python

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
