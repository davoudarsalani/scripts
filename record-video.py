#!/home/nnnn/main/scripts/venv/bin/python3

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/record-video.py
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/record-video.py
##    https://davoudarsalani.ir

from os import getenv

from gp import Audio, Record, get_datetime, pip_to_dmenu, update_audio, convert_second, invalid

lengths = ['30s', '1m', '5m', '10m', '30m', '1h', '2h', '3h', '4h', '5h']
length = pip_to_dmenu(lengths, 'rec video')
if   length == '30s': secs = 30
elif length == '1m':  secs = 60
elif length == '5m':  secs = 300
elif length == '10m': secs = 600
elif length == '30m': secs = 1800
elif length == '1h':  secs = 3600
elif length == '2h':  secs = 7200
elif length == '3h':  secs = 10800
elif length == '4h':  secs = 14400
elif length == '5h':  secs = 18000
else: exit()

dur = convert_second(secs)
suffix = 'VID'
output = f'{getenv("HOME")}/main/downloads/{get_datetime("jymdhms")}-{suffix}.mkv'
Aud = Audio()
Rec = Record()

need_mics = ['no', 'yes']
need_mic = pip_to_dmenu(need_mics, 'need mic?')
if   need_mic == 'yes':
    Aud.mic('unmute')
    Aud.mic('25')
    Aud.mon('unmute')
    Aud.mon('100')
elif need_mic == 'no':
    Aud.mon('unmute')
    Aud.mon('100')
else:
    invalid('invalid answer')

update_audio()

Rec.video(dur, output, suffix, secs)

Aud.mic('mute')
Aud.mic('0')
Aud.mon('mute')
Aud.mon('0')

update_audio()
