#!/usr/bin/env python

## last modified: 1400-09-02 23:12:01 +0330 Tuesday

from os import getenv, path
from signal import signal, SIGINT

from gp import Screen, Color, Audio, Record, get_datetime, fzf, update_audio, record_icon, set_widget, invalid, get_single_input

title = path.basename(__file__).replace('.py', '')
Aud = Audio()
Col = Color()
Rec = Record()
Scr = Screen()

def received_ctrl_c(signum: int, stack) -> None:  ## {{{
    ## https://stackoverflow.com/questions/52269334/python-trap-routine
    Aud.mic('mute')
    Aud.mic('0')
    Aud.mon('mute')
    Aud.mon('0')

    update_audio()

    set_widget('record', 'fg', 'reset')
    set_widget('record', 'markup', record_icon())
    exit()
handler = signal(SIGINT, received_ctrl_c)
## }}}

print(Col.heading(title))

main_items = ['audio', 'screen 1', 'screen 2', 'screen all', 'video']
main_item = fzf(main_items)

mic = get_single_input('Need mic?')
if   mic == 'y':
    Aud.mic('unmute')
    Aud.mic('25')
    Aud.mon('unmute')
    Aud.mon('100')
elif mic == 'n':
    Aud.mon('unmute')
    Aud.mon('100')
else:
    invalid('Invalid answer')

update_audio()

set_widget('record', 'fg', getenv('red'))

if   main_item == 'audio':
    suffix = 'AUD-UL'
    output = f'{getenv("HOME")}/downloads/{get_datetime("jymdhms")}-{suffix}.mp3'
    set_widget('record', 'markup', f'{record_icon()}:{suffix}')
    Rec.audio_ul(output)
elif main_item == 'screen 1':
    scr_1_name, scr_1_res, scr_1_x, scr_1_y = Scr.screen_1()
    scr_2_name, scr_2_res, scr_2_x, scr_2_y = Scr.screen_2()
    resolution = scr_1_res
    x_offset = 0
    suffix = 'SCR-1-UL'
    output = f'{getenv("HOME")}/downloads/{get_datetime("jymdhms")}-{suffix}.mkv'
    set_widget('record', 'markup', f'{record_icon()}:{suffix}')
    Rec.screen_ul(resolution, x_offset, output)
elif main_item == 'screen 2':
    scr_1_name, scr_1_res, scr_1_x, scr_1_y = Scr.screen_1()
    scr_2_name, scr_2_res, scr_2_x, scr_2_y = Scr.screen_2()
    resolution = scr_2_res
    x_offset = scr_1_x
    suffix = 'SCR-2-UL'
    output = f'{getenv("HOME")}/downloads/{get_datetime("jymdhms")}-{suffix}.mkv'
    set_widget('record', 'markup', f'{record_icon()}:{suffix}')
    Rec.screen_ul(resolution, x_offset, output)
elif main_item == 'screen all':
    scr_1_name, scr_1_res, scr_1_x, scr_1_y = Scr.screen_1()
    scr_2_name, scr_2_res, scr_2_x, scr_2_y = Scr.screen_2()
    scr_all_res = Scr.screen_all()
    resolution = scr_all_res
    x_offset = 0
    suffix = 'SCR-ALL-UL'
    output = f'{getenv("HOME")}/downloads/{get_datetime("jymdhms")}-{suffix}.mkv'
    set_widget('record', 'markup', f'{record_icon()}:{suffix}')
    Rec.screen_ul(resolution, x_offset, output)
elif main_item == 'video':
    suffix = 'VID-UL'
    output = f'{getenv("HOME")}/downloads/{get_datetime("jymdhms")}-{suffix}.mkv'
    set_widget('record', 'markup', f'{record_icon()}:{suffix}')
    Rec.video_ul(output)
