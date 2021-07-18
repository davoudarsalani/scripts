#!/usr/bin/env python

from os import path, getenv, symlink, rename, remove
from shutil import rmtree
from subprocess import run, check_output
from sys import argv

from magic import Magic
from gp import (msgn, msgc, get_datetime, get_single_input, invalid, dorm, get_password, fzf,
                compress_tar, compress_zip, xtract_tar, xtract_zip, xtract_rar)

script_args = argv[1:]
main_arg    = script_args[0]
files       = script_args[1:]

if   main_arg == 'chattr':  ## {{{
    main_items = ['mutable', 'immutable', 'deletable', 'undeletable', 'delete normal', 'delete secure', 'lsattr']
    main_item = fzf(main_items, 'chattr')
    if   main_item == 'mutable':
        for f in files:
            _, base = path.split(f)
            cmd = run(f'sudo chattr -R -i {base}', shell=True, universal_newlines=True, capture_output=True)
            cmd_error = cmd.stderr.strip()
            if not cmd_error:
                if path.isdir(base):
                    attribution = check_output(f'lsattr {base}', shell=True, universal_newlines=True).strip()
                else:
                    attribution = check_output(f'lsattr {base}', shell=True, universal_newlines=True).split()[0]
                msgn('mutable', f'<span color=\"{getenv("orange")}\">{base}</span>\n({attribution})')
            else:
                msgc('ERROR', f'making <span color=\"{getenv("orange")}\">{base}</span> mutable\n{cmd_error}', f'{getenv("HOME")}/linux/themes/alert-w.png')

            dorm(0.1)
    elif main_item == 'immutable':
        for f in files:
            _, base = path.split(f)
            cmd = run(f'sudo chattr -R +i {f}', shell=True, universal_newlines=True, capture_output=True)
            cmd_error = cmd.stderr.strip()
            if not cmd_error:
                if path.isdir(base):
                    attribution = check_output(f'lsattr {f}', shell=True, universal_newlines=True).strip()
                else:
                    attribution = check_output(f'lsattr {f}', shell=True, universal_newlines=True).split()[0]
                msgn('immutable', f'<span color=\"{getenv("orange")}\">{base}</span>\n({attribution})')
            else:
                msgc('ERROR', f'making <span color=\"{getenv("orange")}\">{base}</span> immutable\n{cmd_error}', f'{getenv("HOME")}/linux/themes/alert-w.png')

            dorm(0.1)
    elif main_item == 'deletable':
        for f in files:
            _, base = path.split(f)
            cmd = run(f'sudo chattr -R -a {f}', shell=True, universal_newlines=True, capture_output=True)
            cmd_error = cmd.stderr.strip()
            if not cmd_error:
                if path.isdir(base):
                    attribution = check_output(f'lsattr {f}', shell=True, universal_newlines=True).strip()
                else:
                    attribution = check_output(f'lsattr {f}', shell=True, universal_newlines=True).split()[0]
                msgn('deletable', f'<span color=\"{getenv("orange")}\">{base}</span>\n({attribution})')
            else:
                msgc('ERROR', f'making <span color=\"{getenv("orange")}\">{base}</span> deletable\n{cmd_error}', f'{getenv("HOME")}/linux/themes/alert-w.png')

            dorm(0.1)
    elif main_item == 'undeletable':
        for f in files:
            _, base = path.split(f)
            cmd = run(f'sudo chattr -R +a {f}', shell=True, universal_newlines=True, capture_output=True)
            cmd_error = cmd.stderr.strip()
            if not cmd_error:
                if path.isdir(base):
                    attribution = check_output(f'lsattr {f}', shell=True, universal_newlines=True).strip()
                else:
                    attribution = check_output(f'lsattr {f}', shell=True, universal_newlines=True).split()[0]
                msgn('undeletable', f'<span color=\"{getenv("orange")}\">{base}</span>\n({attribution})')
            else:
                msgc('ERROR', f'making <span color=\"{getenv("orange")}\">{base}</span> undeletable\n{cmd_error}', f'{getenv("HOME")}/linux/themes/alert-w.png')

            dorm(0.1)
    elif main_item == 'delete normal':
        for f in files:
            _, base = path.split(f)
            cmd = run(f'sudo chattr -R -s {f}', shell=True, universal_newlines=True, capture_output=True)
            cmd_error = cmd.stderr.strip()
            if not cmd_error:
                if path.isdir(base):
                    attribution = check_output(f'lsattr {f}', shell=True, universal_newlines=True).strip()
                else:
                    attribution = check_output(f'lsattr {f}', shell=True, universal_newlines=True).split()[0]
                msgn('delete normal', f'<span color=\"{getenv("orange")}\">{base}</span>\n({attribution})')
            else:
                msgc('ERROR', f'making <span color=\"{getenv("orange")}\">{base}</span> delete normal\n{cmd_error}', f'{getenv("HOME")}/linux/themes/alert-w.png')

            dorm(0.1)
    elif main_item == 'delete secure':
        for f in files:
            _, base = path.split(f)
            cmd = run(f'sudo chattr -R +s {f}', shell=True, universal_newlines=True, capture_output=True)
            cmd_error = cmd.stderr.strip()
            if not cmd_error:
                if path.isdir(base):
                    attribution = check_output(f'lsattr {f}', shell=True, universal_newlines=True).strip()
                else:
                    attribution = check_output(f'lsattr {f}', shell=True, universal_newlines=True).split()[0]
                msgn('delete secure', f'<span color=\"{getenv("orange")}\">{base}</span>\n({attribution})')
            else:
                msgc('ERROR', f'making <span color=\"{getenv("orange")}\">{base}</span> delete secure\n{cmd_error}', f'{getenv("HOME")}/linux/themes/alert-w.png')

            dorm(0.1)
    elif main_item == 'lsattr':
        for f in files:
            try:
                _, base = path.split(f)
                if path.isdir(base):
                    attribution = check_output(f'lsattr {base}', shell=True, universal_newlines=True).strip()
                else:
                    attribution = check_output(f'lsattr {base}', shell=True, universal_newlines=True).split()[0]
                msgn(f'<span color=\"{getenv("orange")}\">{base}</span>\n{attribution}')
            except Exception as exc:
                msgc('ERROR', f'printing lsattr for <span color=\"{getenv("orange")}\">{base}</span>\n{exc!r}', f'{getenv("HOME")}/linux/themes/alert-w.png')
            dorm(0.1)
## }}}
elif main_arg == 'trash':  ## {{{
    for f in files:
        try:
            _, base = path.split(f)
            new_name = f'{get_datetime("jymdhms")}-{base}'
            rename(base, f'{getenv("HOME")}/trash/{new_name}')
            msgn('trashed', f'<span color=\"{getenv("orange")}\">{base}</span>')
        except Exception as exc:
            msgc('ERROR', f'trashing <span color=\"{getenv("orange")}\">{base}</span>\n{exc!r}', f'{getenv("HOME")}/linux/themes/alert-w.png')
        dorm(0.1)
## }}}
elif main_arg == 'rm':  ## {{{
    for f in files:
        try:
            _, base = path.split(f)
            if path.isdir(f):
                rmtree(f)  ## removes even non-empty directories
            elif path.isfile(f):
                remove(f)
            msgn('removed', f'<span color=\r"{getenv("red")}\"><b>{base}</b></span>', icon=f'{getenv("HOME")}/linux/themes/delete-w.png')
        except Exception as exc:
            msgc('ERROR', f'removing <span color=\"{getenv("orange")}\">{base}</span>\n{exc!r}', f'{getenv("HOME")}/linux/themes/alert-w.png')
        dorm(0.1)
## }}}
elif main_arg == 'mime_type':  ## {{{
    for f in files:
        try:
            _, base = path.split(f)
            mime = Magic(mime=True).from_file(base)
            msgn('mimetype', f'<span color=\"{getenv("orange")}\">{base}</span> is <span color=\"{getenv("orange")}\">{mime}</span>')
        except Exception as exc:
            msgc('ERROR', f'showing mimetype of <span color=\"{getenv("orange")}\">{base}</span>\n{exc!r}', f'{getenv("HOME")}/linux/themes/alert-w.png')
        dorm(0.1)
## }}}
elif main_arg == 'softlink':  ## {{{
    for f in files:
        try:
            _, base = path.split(f)
            symlink(f, f'{getenv("HOME")}/downloads/{base}')
            msgn('softlinekd', f'<span color=\"{getenv("orange")}\">{base}</span>')
        except Exception as exc:
            msgc('ERROR', f'softlinking <span color=\"{getenv("orange")}\">{base}</span>\n{exc!r}', f'{getenv("HOME")}/linux/themes/alert-w.png')
        dorm(0.1)
## }}}
elif main_arg == 'tar':  ## {{{
    for f in files:
        try:
            _, base = path.split(f)
            compress_tar(f)
            msgn('compressed', f'<span color=\"{getenv("orange")}\">{base}</span> to tar')
        except Exception as exc:
            msgc('ERROR', f'compressing <span color=\"{getenv("orange")}\">{base}</span> to tar\n{exc!r}', f'{getenv("HOME")}/linux/themes/alert-w.png')
        dorm(0.1)
## }}}
elif main_arg == 'untar':  ## {{{
    for f in files:
        try:
            _, base = path.split(f)
            xtract_tar(f)
            msgn('xtracted', f'<span color=\"{getenv("orange")}\">{base}</span>')
        except Exception as exc:
            msgc('ERROR', f'xtracting <span color=\"{getenv("orange")}\">{base}</span>\n{exc!r}', f'{getenv("HOME")}/linux/themes/alert-w.png')
        dorm(0.1)
## }}}
elif main_arg == 'zip':  ## {{{
    for f in files:
        try:
            _, base = path.split(f)
            use_password = get_single_input('Use password (y/n)?')
            if use_password == 'y':
                password = get_password('Password ')
                compress_zip(f, password)
            elif use_password == 'n':
                compress_zip(f)
            else:
                invalid('Wrong choice')
            msgn('compressed', f'<span color=\"{getenv("orange")}\">{base}</span> to zip')
        except Exception as exc:
            msgc('ERROR', f'compressing <span color=\"{getenv("orange")}\">{base}</span> to zip\n{exc!r}', f'{getenv("HOME")}/linux/themes/alert-w.png')
        dorm(0.1)
## }}}
elif main_arg == 'unzip':  ## {{{
    for f in files:
        try:
            _, base = path.split(f)
            has_password = get_single_input('Has password (y/n)?')
            if   has_password == 'y':
                password = get_password('Password ')
                xtract_zip(f, password)
            elif has_password == 'n':
                xtract_zip(f)
            else:
                invalid('Wrong choice')
            msgn('xtracted', f'<span color=\"{getenv("orange")}\">{base}</span>')
        except Exception as exc:
            msgc('ERROR', f'xtracting <span color=\"{getenv("orange")}\">{base}</span>\n{exc!r}', f'{getenv("HOME")}/linux/themes/alert-w.png')
        dorm(0.1)
## }}}
elif main_arg == 'unrar':  ## {{{
    for f in files:
        try:
            _, base = path.split(f)
            has_password = get_single_input('Has password (y/n)?')
            if   has_password == 'y':
                password = get_password('Password ')
                xtract_rar(f, password)
                pass
            elif has_password == 'n':
                xtract_rar(f)
            else:
                invalid('Wrong choice')
            msgn('xtracted', f'<span color=\"{getenv("orange")}\">{base}</span>')
        except Exception as exc:
            msgc('ERROR', f'xtracting <span color=\"{getenv("orange")}\">{base}</span>\n{exc!r}', f'{getenv("HOME")}/linux/themes/alert-w.png')
        dorm(0.1)
## }}}
