#!/usr/bin/env python

## @last-modified 1400-09-16 11:12:19 +0330 Tuesday

from getopt import getopt
from os import path, getenv
from subprocess import run
from sys import argv

from clipboard import copy as clipboard_copy
from gp import Color, fzf, get_input, invalid, msgn, get_datetime

title = path.basename(__file__).replace('.py', '')
script_args = argv[1:]
Col = Color()


def display_help() -> None:
    run('clear', shell=True)
    print(
        f'''{Col.heading(f'{title}')} {Col.yellow('help')}
{Col.flag('-s --string=')}
{Col.flag('-f --file=')}
{Col.flag('-c --command=')}'''
    )
    exit()


def getopts() -> None:
    global string, file, command

    try:
        duos, duos_long = getopt(script_args, 'hs:f:c:', ['help', 'string=', 'file=', 'command='])
    except Exception as exc:
        invalid(f'{exc!r}')

    for opt, arg in duos:
        if opt in ('-h', '--help'):
            display_help()
        elif opt in ('-s', '--string'):
            string = arg
        elif opt in ('-f', '--file'):
            file = arg
        elif opt in ('-c', '--command'):
            command = arg


def prompt(*args: list[str]) -> None:
    global string, file, command

    for arg in args:
        if arg == '-s':
            try:
                string
            except:
                string = get_input('String')
        elif arg == '-f':
            try:
                file
            except:
                file = get_input('File')
            if not path.exists(f'{file}'):
                invalid('No such file')
        elif arg == '-c':
            try:
                command
            except:
                command = get_input('Command')
            # if path.isdir(f'{file}'): invalid('Files only')


getopts()

print(Col.heading(title))

main_items = ['string', 'file', 'command', 'datetime', 'jalali datetime', 'help']
main_item = fzf(main_items)

if main_item == 'string':
    prompt('-s')
    clipboard_copy(string)
    msgn(f'copied\n<span color=\"{getenv("orange")}\">{string}</span>')
elif main_item == 'file':
    prompt('-f')
    with open(file, 'r') as opened_file:
        content = opened_file.read().strip()
    clipboard_copy(content)
    msgn(f'copied\n<span color=\"{getenv("orange")}\">{content}</span>')
elif main_item == 'command':
    prompt('-c')
    cmd = run(command, shell=True, universal_newlines=True, capture_output=True)
    cmd_output = cmd.stdout.strip()
    clipboard_copy(cmd_output)
    msgn(f'copied\n<span color=\"{getenv("orange")}\">{cmd_output}</span>')
elif main_item == 'datetime':
    current_datetime = get_datetime('ymdhms')
    clipboard_copy(current_datetime)
    msgn(f'copied\n<span color=\"{getenv("orange")}\">{current_datetime}</span>')
elif main_item == 'jalali datetime':
    current_datetime = get_datetime('jymdhms')
    clipboard_copy(current_datetime)
    msgn(f'copied\n<span color=\"{getenv("orange")}\">{current_datetime}</span>')
elif main_item == 'help':
    display_help()
