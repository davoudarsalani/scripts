#!/usr/bin/env python

from getopt import getopt
from os import path
from subprocess import run
from sys import argv

from gp import Color, fzf, invalid, get_input, get_single_input, get_password, compress_tar, xtract_tar, compress_zip, xtract_zip, xtract_rar

title = path.basename(__file__).replace('.py', '')
script_args = argv[1:]

def help():  ## {{{
    run('clear', shell=True)
    print(f'''{Color().heading(f'{title}')} {Color().yellow('Help')}
{Color().flag(f'-i --input=')}
{Color().flag(f'-p --password=')}''')
    exit()
## }}}
def getopts():  ## {{{
    global inpt, password

    try:
        duos, duos_long = getopt(script_args, 'hi:p:', ['help', 'input=', 'password='])
    except Exception as exc:
        invalid(f'{exc!r}')

    for opt, arg in duos:
        if   opt in ('-h', '--help'):     help()
        elif opt in ('-i', '--input'):    inpt = arg
        elif opt in ('-p', '--password'): password = arg
## }}}
def prompt(*args: str):  ## {{{
    global inpt, password

    for arg in args:
        if   arg == '-i':
            try:    inpt
            except: inpt = get_input('Input')
            if not path.exists(f'{inpt}'): invalid('No such file/dir')
        elif arg == '-p':
            try:    password
            except: password = get_password('Password ')
## }}}

getopts()

print(Color().heading(title))

main_items = ['tar', 'untar', 'zip', 'unzip', 'unrar', 'help']
main_item = fzf(main_items)

if   main_item == 'tar':
    prompt('-i')
    compress_tar(inpt)
elif main_item == 'untar':
    prompt('-i')
    xtract_tar(inpt)
elif main_item == 'zip':
    use_password = get_single_input('Use password (y/n)?')
    if   use_password == 'y':
        prompt('-i', '-p')
        compress_zip(inpt, password)
    elif use_password == 'n':
        prompt('-i')
        compress_zip(inpt)
    else:
        invalid('Wrong choice')
elif main_item == 'unzip':
    has_password = get_single_input('Has password (y/n)?')
    if   has_password == 'y':
        prompt('-i', '-p')
        xtract_zip(inpt, password)
    elif has_password == 'n':
        prompt('-i')
        xtract_zip(inpt)
    else:
        invalid('Wrong choice')
elif main_item == 'unrar':
    has_password = get_single_input('Has password (y/n)?')
    if   has_password == 'y':
        prompt('-i', '-p')
        xtract_rar(inpt, password)
    elif has_password == 'n':
        prompt('-i')
        xtract_rar(inpt)
    else:
        invalid('Wrong choice')
elif main_item == 'help':
    help()
