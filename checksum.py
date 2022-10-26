#!/usr/bin/env python

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/checksum.py
##    https://davoudarsalani.ir

## @last-modified 1401-08-03 09:44:05 +0330 Tuesday

from getopt import getopt
from os import path
from subprocess import run
from sys import argv

from gp import Color, fzf, invalid, get_input, hash_string, hash_file

title = path.basename(__file__).replace('.py', '')
script_args = argv[1:]
Col = Color()


def display_help() -> None:  ## {{{
    run('clear', shell=True)
    print(
        f'''{Col.heading(f'{title}')} {Col.yellow('help')}
string  {Col.flag('-s|--string=')}
file    {Col.flag('-f|--file=')}'''
    )
    exit()


## }}}
def getopts() -> None:  ## {{{
    global file, string

    try:
        duos, duos_long = getopt(script_args, 'hf:s:', ['help', 'string=', 'file='])
    except Exception as exc:
        invalid(f'{exc!r}')

    for opt, arg in duos:
        if opt in ('-h', '--help'):
            display_help()
        elif opt in ('-s', '--string'):
            string = arg
        elif opt in ('-f', '--file'):
            file = arg


## }}}
def prompt(*args: list[str]) -> None:  ## {{{
    global file, string

    for arg in args:
        if arg == '-f':
            try:
                file
            except:
                file = get_input('file')
            if not path.exists(file):
                invalid(f'{file} does not exist')
            if path.isdir(file):
                invalid('files only')
        elif arg == '-s':
            try:
                string
            except:
                string = get_input('string')


## }}}

getopts()

print(Col.heading(title))

main_items = ['string', 'file', 'help']
main_item = fzf(main_items)

if main_item == 'string':
    prompt('-s')
    hashed = hash_string(string)
    print(hashed)
elif main_item == 'file':
    prompt('-f')
    hashed = hash_file(file)
    print(hashed)
elif main_item == 'help':
    display_help()
