#!/usr/bin/env python

from getopt import getopt
from os import path
from subprocess import run
from sys import argv

from gp import Color, fzf, invalid, get_input, hash_string, hash_file

title = path.basename(__file__).replace('.py', '')
script_args = argv[1:]
C = Color()

def help():  ## {{{
    run('clear', shell=True)
    print(f'''{C.heading(f'{title}')} {C.yellow('Help')}
string  {C.flag(f'-s --string=')}
file    {C.flag(f'-f --file=')}''')
    exit()
## }}}
def getopts():  ## {{{
    global file, string

    try:
        duos, duos_long = getopt(script_args, 'hf:s:', ['help', 'string=', 'file='])
    except Exception as exc:
        invalid(f'{exc!r}')

    for opt, arg in duos:
        if   opt in ('-h', '--help'):   help()
        elif opt in ('-s', '--string'): string = arg
        elif opt in ('-f', '--file'):   file = arg
## }}}
def prompt(*args: str):  ## {{{
    global file, string

    for arg in args:
        if   arg == '-f':
            try:    file
            except: file = get_input('File')
            if not path.exists(f'{file}'): invalid('No such file')
            if path.isdir(f'{file}'): invalid('Files only')
        elif arg == '-s':
            try:    string
            except: string = get_input('String')
## }}}

getopts()

print(C.heading(title))

main_items = ['string', 'file', 'help']
main_item = fzf(main_items)

if   main_item == 'string':
    prompt('-s')
    hashed = hash_string(string)
    print(hashed)
elif main_item == 'file':
    prompt('-f')
    hashed = hash_file(file)
    print(hashed)
elif main_item == 'help':
    help()
