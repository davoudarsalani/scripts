#!/usr/bin/env python

## @last-modified 1401-06-15 18:45:59 +0330 Tuesday

from magic import Magic
from natsort import natsorted
from os import listdir, path
from re import match, compile as re_compile

from gp import Color, invalid

Col = Color()
text_reg = re_compile(r'^text/.+$')
total_lines = 0
text_files = natsorted([_ for _ in listdir() if path.isfile(_)])

if not text_files:
    invalid('no text files')

for f in text_files:
    mime = Magic(mime=True).from_file(f)

    if match(text_reg, mime) or mime in ['application/json', 'application/csv', 'message/news']:

        try:
            with open(f) as opened:
                content = opened.readlines()

            length = len(content)
            total_lines += length

            print(f'{length:,}\t{f}')

        except Exception as exc:
            print(Col.red(f'?\t{f} (ERROR: {exc})'))  ## {exc} instead of {exc!r} because error message may be too long

print(Col.yellow(f'\n{total_lines:,}\ttotal'))
