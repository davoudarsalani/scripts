#!/usr/bin/env python

from gp import dmenu, msgn, msgc, dorm, remove_leading_zeros, get_datetime

modes = ['at relative time (e.g. 30, 600, etc)', 'at specific time (e.g. 14:25)']
mode = dmenu(modes, title='reminder')

if 'relative' in mode:
    try:
        relative = int(dmenu(title='relative time'))
    except Exception as exc:
        msgc('ERROR', f'{exc!r}')
        exit()

    message = dmenu(title='message')
    msgn(f'Reminder in {relative} seconds', message)
    dorm(relative)
    msgc('Reminder', message)
elif 'specific' in mode:
    try:
        specific  = dmenu(title='specific time')
        specific2 = specific.replace(':', '')
        specific2 = remove_leading_zeros(specific2)
        specific2 = int(specific2)
    except Exception as exc:
        msgc('ERROR', f'{exc!r}')
        exit()

    message = dmenu(title='message')
    msgn(f'Reminder at {specific}', message)
    while True:
        current_time = int(get_datetime('jhms')[:4])
        current_time = int(remove_leading_zeros(current_time))
        if current_time == specific2:
            msgc('Reminder', message)
            break
        dorm(30)
