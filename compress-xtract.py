#!/usr/bin/env python

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/compress-xtract.py
##    https://davoudarsalani.ir

## @last-modified 1401-08-03 09:52:20 +0330 Tuesday

from getopt import getopt
from os import path
from subprocess import run
from sys import argv

from gp import Color, fzf, invalid, get_input, get_single_input, get_password, compress_tar, xtract_tar, compress_zip, xtract_zip, xtract_rar

title = path.basename(__file__).replace('.py', '')
script_args = argv[1:]
Col = Color()


def display_help() -> None:  ## {{{
    run('clear', shell=True)
    print(
        f'''{Col.heading(f'{title}')} {Col.yellow('help')}
{Col.flag('-i|--input=')}
{Col.flag('-p|--password=')}'''
    )
    exit()


## }}}
def getopts() -> None:  ## {{{
    global inpt, password

    try:
        duos, duos_long = getopt(script_args, 'hi:p:', ['help', 'input=', 'password='])
    except Exception as exc:
        invalid(f'{exc!r}')

    for opt, arg in duos:
        if opt in ('-h', '--help'):
            display_help()
        elif opt in ('-i', '--input'):
            inpt = arg
        elif opt in ('-p', '--password'):
            password = arg


## }}}
def prompt(*args: list[str]) -> None:  ## {{{
    global inpt, password

    for arg in args:
        if arg == '-i':
            try:
                inpt
            except:
                inpt = get_input('input')
            if not path.exists(f'{inpt}'):
                invalid(f'{inpt} does not exist')
        elif arg == '-p':
            try:
                password
            except:
                password = get_password('password ')


## }}}

getopts()

print(Col.heading(title))

main_items = ['tar', 'untar', 'zip', 'unzip', 'unrar', 'help']
main_item = fzf(main_items)

if main_item == 'tar':
    prompt('-i')
    compress_tar(inpt)
elif main_item == 'untar':
    prompt('-i')
    xtract_tar(inpt)
elif main_item == 'zip':
    use_password = get_single_input('use password (y/n)?')
    if use_password == 'y':
        prompt('-i', '-p')
        compress_zip(inpt, password)
    elif use_password == 'n':
        prompt('-i')
        compress_zip(inpt)
    else:
        invalid('wrong choice')
elif main_item == 'unzip':
    has_password = get_single_input('has password (y/n)?')
    if has_password == 'y':
        prompt('-i', '-p')
        xtract_zip(inpt, password)
    elif has_password == 'n':
        prompt('-i')
        xtract_zip(inpt)
    else:
        invalid('wrong choice')
elif main_item == 'unrar':
    has_password = get_single_input('has password (y/n)?')
    if has_password == 'y':
        prompt('-i', '-p')
        xtract_rar(inpt, password)
    elif has_password == 'n':
        prompt('-i')
        xtract_rar(inpt)
    else:
        invalid('wrong choice')
elif main_item == 'help':
    display_help()
