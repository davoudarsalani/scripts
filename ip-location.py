#!/usr/bin/env python

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/ip-location.py
##    https://davoudarsalani.ir

## @last-modified 1401-07-10 09:03:36 +0330 Sunday

from getopt import getopt
from json import dumps
from os import path
from subprocess import run
from sys import argv

from requests import Session
from gp import Color, fzf, invalid, get_input, get_headers

title = path.basename(__file__).replace('.py', '')
script_args = argv[1:]
Col = Color()


def display_help() -> None:  ## {{{
    run('clear', shell=True)
    print(
        f'''{Col.heading(f'{title}')} {Col.yellow('help')}
{Col.flag('-i|--ip=')}'''
    )
    exit()


## }}}
def getopts() -> None:  ## {{{
    global ip

    try:
        duos, duos_long = getopt(script_args, 'hi:', ['help', 'ip='])
    except Exception as exc:
        invalid(f'{exc!r}')

    for opt, arg in duos:
        if opt in ('-h', '--help'):
            display_help()
        elif opt in ('-i', '--ip'):
            ip = arg


## }}}
def prompt(*args: list[str]) -> None:  ## {{{
    global ip

    for arg in args:
        if arg == '-i':
            try:
                ip
            except:
                ip = get_input('IP')


## }}}

getopts()

print(Col.heading(title))

main_items = ['ip', 'help']
main_item = fzf(main_items)

if main_item == 'ip':
    prompt('-i')

    url = 'http://ip-api.com/json'
    s = Session()
    hdrs = get_headers()

    try:
        response = s.get(f'{url}/{ip}', headers=hdrs, timeout=20).json()
        dumped = dumps(response, indent=2)  ## prettify
        print(dumped)
    except Exception as exc:
        print(f'{exc!r}')
