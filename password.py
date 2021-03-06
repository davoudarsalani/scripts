#!/usr/bin/env python

from getopt import getopt
from os import path
from random import sample
from subprocess import run
from sys import argv

from gp import Color, invalid, fzf, get_input

title = path.basename(__file__).replace('.py', '')
script_args = argv[1:]

def help():  ## {{{
    run('clear', shell=True)
    print(f'''{Color().heading(f'{title}')} {Color().yellow('Help')}
{Color().flag(f'-l --length=')}''')
    exit()
## }}}
def getopts():  ## {{{
    global length

    try:
        duos, duos_long = getopt(script_args, 'hl:', ['help', 'length='])
    except Exception as exc:
        invalid(f'{exc!r}')

    for opt, arg in duos:
        if   opt in ('-h', '--help'):   help()
        elif opt in ('-l', '--length'): length = int(arg)
## }}}
def prompt(*args: str):  ## {{{
    global length

    for arg in args:
        if   arg == '-l':
            try:    length
            except:
                try:    length = int(get_input('Length'))
                except: invalid('Length should be a number')

## }}}
def generate():  ## {{{
    u = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    l = u.lower()
    d = '0123456789'
    s = '!@#$%^-*()_+={}\[\]\|\\;\':\",.<>/?`~'  ## & intentionally exclided to prevent possible shell errors/problems

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
        print(Color().orange(f'Length exceeded maximumm number.\nLength is {len(letters)} now.'))
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
        print(Color().orange(f'Length exceeded maximumm number.\nLength is {len(letters)} now.'))
        length = len(letters)

    for x in range(5):
        password = ''.join(sample(letters, length))
        print(password)
## }}}

getopts()

print(Color().heading(title))

main_items = ['password', 'help']
main_item = fzf(main_items)

if   main_item == 'password':
    prompt('-l')
    generate()
elif main_item == 'help':
    help()
