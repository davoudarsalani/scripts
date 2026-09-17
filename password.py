#!/home/nnnn/main/scripts/venv/bin/python3

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/password.py
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/password.py
##    https://davoudarsalani.ir


import string

from getopt import getopt
from os import path
from random import sample
from re import sub
from subprocess import run
from sys import argv

from utils import (
    Color,
    invalid,
    pipe_to_fzf,
)


title = path.basename(__file__)
script_args = argv[1:]
Col = Color()


def display_help() -> None:
    run('clear', shell=True)
    print(f'''{Col.heading(f'{title}')} {Col.yellow('help')}
{Col.flag('-l|--length=')}{Col.default('[30]')}
{Col.flag('-c|--count=')}{Col.default('[5]')}''')
    exit()

def getopts() -> None:
    global length, count

    try:
        duos, duos_long = getopt(script_args, 'hl:c:', ['help', 'length=', 'count='])
    except Exception as exc:
        invalid(f'{exc!r}')

    for opt, arg in duos:
        if opt in ('-h', '--help'):
            display_help()
        elif opt in ('-l', '--length'):
            length = int(arg)
        elif opt in ('-c', '--count'):
            count = int(arg)

def prompt(*args: list[str]) -> None:
    global length, count

    for arg in args:
        if arg == '-l':
            try:
                length
            except:
                length = 30
        elif arg == '-c':
            try:
                count
            except:
                count = 5

def generate(
    uppercase: bool = True,
    lowercase: bool = True,
    digits: bool = True,
    symbols: bool = True,
) -> None:
    global length, count

    pools = []

    if uppercase:
        pools.append(string.ascii_uppercase)

    if lowercase:
        pools.append(string.ascii_lowercase)

    if digits:
        pools.append(string.digits)

    if symbols:
        ## remove &, / and \\ to prevent possible shell errors
        puncs = sub(r'[&/\\]', r'', string.punctuation)

        pools.append(puncs)

    ## flatten all pools into one string
    letters = ''.join(pools)

    if not letters:
        invalid('No character sets selected.')

    if length > len(letters):
        print(Col.yellow(f'Length exceeded maximum number.\nLength set to {len(letters)}'))
        length = len(letters)

    for _ in range(count):
        password_chars = []

        ## ensure at least one char from each selected pool
        for pool in pools:
            password_chars.append(sample(pool, 1)[0])

        remaining_length = length - len(password_chars)

        if remaining_length > 0:
            password_chars.extend(sample(letters, remaining_length))

        ## shuffle to avoid predictable pattern
        password = ''.join(sample(password_chars, len(password_chars)))
        print(password)

getopts()

print(Col.heading(title))

main_items = ['password', 'help']
main_item = pipe_to_fzf(main_items)

if main_item == 'password':
    prompt('-l', '-c')
    print('all characters (&, / and \\ excluded):')
    generate()
    print('\nno symbols:')
    generate(symbols=False)
elif main_item == 'help':
    display_help()
