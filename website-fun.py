#!/usr/bin/env python

## @last-modified 1400-09-03 22:25:32 +0330 Wednesday

from getopt import getopt
from os import path
from subprocess import run
from sys import argv

from clipboard import copy as clipboard_copy
from gp import Color, if_exists, invalid, get_input

title = path.basename(__file__).replace('.py', '')
script_args = argv[1:]
dest_file = '/tmp/fun'
dest_file = if_exists(dest_file)
content_list = []
Col = Color()


def display_help() -> None:
    run('clear', shell=True)
    print(
        f'''{Col.heading(f'{title}')} {Col.yellow('help')}
{Col.flag('-l --length=')}'''
    )
    exit()


def getopts() -> None:
    global length
    try:
        duos, duos_long = getopt(script_args, 'hl:', ['help', 'length='])
    except Exception as exc:
        invalid(f'{exc!r}')

    for opt, arg in duos:
        if opt in ('-h', '--help'):
            display_help()
        elif opt in ('-l', '--length'):
            length = int(arg)


def prompt(*args: list[str]) -> None:
    global length
    for arg in args:
        if arg == '-l':
            try:
                length
            except:
                length = int(get_input('Length'))


getopts()
prompt('-l')


def create_list() -> None:
    separator = '<!-- wp:separator -->\n<hr class="wp-block-separator"/>\n<!-- /wp:separator -->'
    next_page = '<!-- wp:nextpage -->\n<!--nextpage-->\n<!-- /wp:nextpage -->'

    text1 = '<!-- wp:image {"align":"center","sizeSlug":"large"} -->'
    text2 = f'<div class="wp-block-image"><figure class="aligncenter size-large"><img src="https://www.davoudarsalani.ir/Files/Fun/{i:03}.jpg" alt=""/></figure></div>'
    text3 = '<!-- /wp:image -->'

    content_list.append(text1)
    content_list.append(text2)
    content_list.append(text3)
    content_list.append('')
    if i > 1:
        if i % 10 == 1:
            content_list.append(next_page)
        else:
            content_list.append(separator)
        content_list.append('')


for i in range(length, 0, -1):
    create_list()

## write to dest_file
with open(dest_file, 'a') as FILE:
    for j in content_list:
        FILE.write(j + '\n')

print(f'{dest_file} successfully created')

## copy dest_file content to clipboard
with open(dest_file, 'r') as opened_file:
    content = opened_file.read().strip()
clipboard_copy(content)
print(f'copied to clipboard')
