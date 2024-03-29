#!/usr/bin/env python

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/e-mail.py
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/e-mail.py
##    https://davoudarsalani.ir

## https://stackoverflow.com/questions/953561/check-unread-count-of-gmail-messages-with-python

from imaplib import IMAP4_SSL
from os import getenv
from re import search
from sys import argv

from gp import set_widget, refresh_icon, save_error

arg = argv[1]

if arg == 'ymail':
    prefix = 'YA'
    server = 'imap.mail.yahoo.com'
    username = getenv('email1')
    password = getenv('email1_password2')
elif arg == 'gmail':
    prefix = 'GM'
    server = 'imap.gmail.com'
    username = getenv('email2')
    password = getenv('email2_password2')
else:
    exit()

port = 993
dest_widget = arg
error_file = f'{getenv("HOME")}/main/scripts/.error/{dest_widget}'

set_widget(dest_widget, 'fg', 'reset')
set_widget(dest_widget, 'markup', refresh_icon())

try:
    conn = IMAP4_SSL(server, port)
    conn.login(username, password)
    count = int(search('UNSEEN (\d+)', conn.status('INBOX', '(UNSEEN)')[1][0].decode('utf-8')).group(1))

    if count > 0:
        text = f'{prefix}:{count}'
        set_widget(dest_widget, 'fg', getenv('red'))
    else:
        text = prefix

except Exception as exc:
    text = prefix

    ## save error
    save_error(error_file, f'{exc!r}')

    set_widget(dest_widget, 'fg', getenv('red'))

finally:
    set_widget(dest_widget, 'markup', text)
