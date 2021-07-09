#!/usr/bin/env python

from os import getenv

from gp import Audio, Record, get_datetime, dmenu, update_audio, record_icon, set_widget, duration

lengths = ['30s', '1m', '5m', '10m', '30m', '1h', '2h', '3h', '4h', '5h']
length = dmenu(lengths, 'rec audio')
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

dur = duration(secs)
suffix = 'AUD'
output = f'{getenv("HOME")}/downloads/{get_datetime("jymdhms")}-{suffix}.mp3'

need_mics = ['no', 'yes']
need_mic = dmenu(need_mics, 'need mic?')
if   need_mic == 'yes':
    Audio().mic('unmute')
    Audio().mic('25')
    Audio().mon('unmute')
    Audio().mon('100')
elif need_mic == 'no':
    Audio().mon('unmute')
    Audio().mon('100')
else:
    exit()

update_audio()

set_widget('record', 'fg', getenv('red'))

Record().audio(dur, output, suffix, secs)

Audio().mic('mute')
Audio().mic('0')
Audio().mon('mute')
Audio().mon('0')

update_audio()

set_widget('record', 'fg', 'reset')
set_widget('record', 'markup', record_icon())
