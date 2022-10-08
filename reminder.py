#!/usr/bin/env python

## @last-modified 1401-06-15 18:47:27 +0330 Tuesday

from time import sleep

from gp import rofi, msgn, msgc, remove_leading_zeros, get_datetime

modes = ['at relative time (e.g. 30, 600, etc)', 'at specific time (e.g. 14:25)']
mode = rofi(modes, title='reminder')

if 'relative' in mode:
    try:
        relative = int(rofi(title='relative time'))
    except Exception as exc:
        msgc('ERROR', f'{exc!r}')
        exit()

    message = rofi(title='message')
    msgn(f'Reminder in {relative} seconds', message)
    sleep(relative)
    msgc('Reminder', message)
elif 'specific' in mode:
    try:
        specific = rofi(title='specific time')
        specific2 = specific.replace(':', '')
        specific2 = remove_leading_zeros(specific2)
        specific2 = int(specific2)
    except Exception as exc:
        msgc('ERROR', f'{exc!r}')
        exit()

    message = rofi(title='message')
    msgn(f'Reminder at {specific}', message)
    while True:
        current_time = int(get_datetime('jhms')[:4])
        current_time = int(remove_leading_zeros(current_time))
        if current_time == specific2:
            msgc('Reminder', message)
            break
        sleep(30)
