#!/usr/bin/env python

## last modified: 1400-09-02 23:12:01 Tuesday

from os import path, listdir, getenv, chdir

from clipboard import copy as clipboard_copy
from gp import Color, fzf, msgn

title = path.basename(__file__).replace('.py', '')
Col = Color()

chdir(f'{getenv("HOME")}/linux/emojis')
print(Col.heading(title))

main_items = listdir()
main_item = fzf(main_items)
print(main_item)

with open(main_item, 'r') as opened_main_item:
    all_content = opened_main_item.read().strip().split('\n')

lines = list(filter(lambda line: not line.startswith('#'), all_content))  ## remove comments
line = fzf(lines)

emoji = line.split()[0]
clipboard_copy(emoji)
msgn(f'copied <span color=\"{getenv("orange")}\">{emoji}</span>')
