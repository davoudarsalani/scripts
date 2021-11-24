#!/usr/bin/env python

## last modified: 1400-09-02 23:12:01 Tuesday

from getopt import getopt
from os import path
from random import sample
from subprocess import run
from sys import argv

from gp import Color, invalid, fzf, get_input

title = path.basename(__file__).replace('.py', '')
script_args = argv[1:]
Col = Color()

def display_help() -> None:  ## {{{
    run('clear', shell=True)
    print(f'''{Col.heading(f'{title}')} {Col.yellow('help')}
{Col.flag('-l --length=')}''')
    exit()
## }}}
def getopts() -> None:  ## {{{
    global length

    try:
        duos, duos_long = getopt(script_args, 'hl:', ['help', 'length='])
    except Exception as exc:
        invalid(f'{exc!r}')

    for opt, arg in duos:
        if   opt in ('-h', '--help'):   display_help()
        elif opt in ('-l', '--length'): length = int(arg)
## }}}
def prompt(*args: list[str]) -> None:  ## {{{
    global length

    for arg in args:
        if   arg == '-l':
            try:    length
            except:
                try:    length = int(get_input('Length'))
                except: invalid('Length should be a number')

## }}}
def generate() -> None:  ## {{{
    u = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    l = u.lower()
    d = '0123456789'
    s = '!@#$%^-*()_+={}\[\]\|\\;\':\",.<>/?`~'  ## & intentionally excluded to prevent possible shell errors/problems

    ## with all the characters
    print('all characters:')
    up, lo, di, sy = True, True, True, True
    letters = ''
    if up: letters += u
    if lo: letters += l
    if di: letters += d
    if sy: letters += s

    global length
    if length > len(letters):
        print(Col.orange(f'Length exceeded maximumm number.\nLength is {len(letters)} now.'))
        length = len(letters)

    for x in range(5):
        password = ''.join(sample(letters, length))
        print(password)

    print()

    ## with no symbols
    print('no symbols:')
    up, lo, di, sy = True, True, True, False
    letters = ''
    if up: letters += u
    if lo: letters += l
    if di: letters += d
    if sy: letters += s

    if length > len(letters):
        print(Col.orange(f'Length exceeded maximumm number.\nLength is {len(letters)} now.'))
        length = len(letters)

    for x in range(5):
        password = ''.join(sample(letters, length))
        print(password)
## }}}

getopts()

print(Col.heading(title))

main_items = ['password', 'help']
main_item = fzf(main_items)

if   main_item == 'password':
    prompt('-l')
    generate()
elif main_item == 'help':
    display_help()

