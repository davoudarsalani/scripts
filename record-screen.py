#!/home/nnnn/main/scripts/venv/bin/python3

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/record-screen.py
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/record-screen.py
##    https://davoudarsalani.ir

from os import getenv

from gp import Screen, Record, Audio, get_datetime, pip_to_dmenu, update_audio, convert_second, invalid

Scr = Screen()
scr_1_name, scr_1_res, scr_1_x, scr_1_y, scr_1_x_offset, scr_1_y_offset = Scr.screen_1()
scr_2_name, scr_2_res, scr_2_x, scr_2_y, scr_2_x_offset, scr_2_y_offset = Scr.screen_2()
scr_all_res = Scr.screen_all()

lengths = ['30s', '1m', '5m', '10m', '30m', '1h', '2h', '3h', '4h', '5h']
length = pip_to_dmenu(lengths, 'rec screen')
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
screens = ['1', '2', 'all']
screen = pip_to_dmenu(screens, 'screen')
if   screen == '1':   x_offset, resolution, suffix = scr_1_x_offset, scr_1_res,   'SCR-1'
elif screen == '2':   x_offset, resolution, suffix = scr_2_x_offset, scr_2_res,   'SCR-2'
elif screen == 'all': x_offset, resolution, suffix = 0,              scr_all_res, 'SCR-ALL'
else: exit()

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

Rec.screen(resolution, x_offset, dur, output, suffix, secs)

Aud.mic('mute')
Aud.mic('0')
Aud.mon('mute')
Aud.mon('0')

update_audio()
