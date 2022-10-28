#!/usr/bin/env python

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/mime-type.py
##    https://davoudarsalani.ir

## @last-modified 1401-08-05 12:47:58 +0330 Thursday

from getopt import getopt
from os import path
from subprocess import run
from sys import argv

from magic import Magic
from gp import Color, fzf, invalid, get_input

title = path.basename(__file__).replace('.py', '')
script_args = argv[1:]
Col = Color()


def display_help() -> None:  ## {{{
    run('clear', shell=True)
    print(
        f'''{Col.heading(f'{title}')} {Col.yellow('help')}
{Col.flag('-f|--file=')}'''
    )
    exit()


## }}}
def getopts() -> None:  ## {{{
    global file

    try:
        duos, duos_long = getopt(script_args, 'hf:', ['help', 'file='])
    except Exception as exc:
        invalid(f'{exc!r}')

    for opt, arg in duos:
        if opt in ('-h', '--help'):
            display_help()
        elif opt in ('-f', '--file'):
            file = arg


## }}}
def prompt(*args: list[str]) -> None:  ## {{{
    global file

    for arg in args:
        if arg == '-f':
            try:
                file
            except:
                file = get_input('file')


## }}}

getopts()

print(Col.heading(title))

main_items = ['mime-type', 'help']
main_item = fzf(main_items)

if main_item == 'mime-type':
    prompt('-f')

    try:
        mime = Magic(mime=True).from_file(file)
        print(mime)
    except Exception as exc:
        print(f'{exc!r}')
