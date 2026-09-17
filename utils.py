from datetime import datetime as dt
from email import encoders
## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/utils.py
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/utils.py
##    https://davoudarsalani.ir

from email.mime.base import MIMEBase
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from functools import wraps, lru_cache
from getpass import getpass
from gzip import open as gzip_open
from os import getenv, path, chdir, listdir, mkdir
from re import match, sub
from shutil import get_terminal_size, make_archive as shutil_make_archive, copyfileobj
from smtplib import SMTP_SSL
from socket import create_connection as socket_create_connection
from ssl import create_default_context
from subprocess import run, check_output
from sys import stdin
from tarfile import open as tarfile_open
from termios import tcgetattr, tcsetattr, TCSADRAIN
from threading import Thread
from time import perf_counter, sleep
from tty import setraw
from typing import Any, Callable
from zipfile import ZipFile, ZIP_DEFLATED

from dmenu import show as dmenu_show
from halo import Halo
from jdatetime import datetime as jdt
from pyfzf.pyfzf import FzfPrompt
from pyminizip import compress
from RRRavard import convert_second
from rarfile import RarFile

import notify2

TIMEOUT       = 20
ERROR_DIR     = f'{getenv("HOME")}/main/scripts/.error'
REFRESH_ICON  = getenv('refresh_icon')
RECORD_ICON   = 'RE'
DEF_VIDEO_DEV = '/dev/video0'

## number of cached entries,
## not a time in seconds
LRU_CACHE_MAXSIZE = 128  ## default is 128

HTTP_HEADERS = {
    'User-Agent':      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
    'Accept':          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.9',
    'Accept-Encoding': 'gzip, deflate, br',

    ## Do Not Track
    'DNT': '1',

    ## using 'close' can slow down scraping
    ## or mark you as unusual
    'Connection': 'keep-alive',

    ## this is sent by browsers when accessing HTTPS URLs
    ## and signals the browser prefers secure content
    'Upgrade-Insecure-Requests': '1',

    # 'Referer': 'https://example.com/',

    ## Modern browsers send these in real requests.
    ## They're important for bypassing bot protections like Cloudflare, Akamai, etc.
    # 'Sec-Fetch-Dest': 'document',
    # 'Sec-Fetch-Mode': 'navigate',
    # 'Sec-Fetch-Site': 'none',   # or 'same-origin', 'cross-site' depending on context
    # 'Sec-Fetch-User': '?1',
}


class Color:
    @staticmethod
    def red(text: str) -> str:    return f'\033[00;49;031m{text}\033[0m'
    @staticmethod
    def green(text: str) -> str:  return f'\033[00;49;032m{text}\033[0m'
    @staticmethod
    def yellow(text: str) -> str: return f'\033[00;49;033m{text}\033[0m'
    @staticmethod
    def blue(text: str) -> str:   return f'\033[00;49;034m{text}\033[0m'
    @staticmethod
    def purple(text: str) -> str: return f'\033[00;49;035m{text}\033[0m'
    @staticmethod
    def cyan(text: str) -> str:   return f'\033[00;49;036m{text}\033[0m'
    @staticmethod
    def white(text: str) -> str:  return f'\033[00;49;037m{text}\033[0m'
    @staticmethod
    def gray(text: str) -> str:   return f'\033[00;49;090m{text}\033[0m'
    @staticmethod
    def brown(text: str) -> str:  return f'\033[38;05;094m{text}\033[0m'
    @staticmethod
    def orange(text: str) -> str: return f'\033[38;05;202m{text}\033[0m'
    @staticmethod
    def olive(text: str) -> str:  return f'\033[38;05;064m{text}\033[0m'

    ## bold
    @staticmethod
    def red_bold(text: str) -> str:    return f'\033[01;49;031m{text}\033[0m'
    @staticmethod
    def green_bold(text: str) -> str:  return f'\033[01;49;032m{text}\033[0m'
    @staticmethod
    def yellow_bold(text: str) -> str: return f'\033[01;49;033m{text}\033[0m'
    @staticmethod
    def blue_bold(text: str) -> str:   return f'\033[01;49;034m{text}\033[0m'
    @staticmethod
    def purple_bold(text: str) -> str: return f'\033[01;49;035m{text}\033[0m'
    @staticmethod
    def cyan_bold(text: str) -> str:   return f'\033[01;49;036m{text}\033[0m'
    @staticmethod
    def white_bold(text: str) -> str:  return f'\033[01;49;037m{text}\033[0m'
    @staticmethod
    def gray_bold(text: str) -> str:   return f'\033[01;49;090m{text}\033[0m'

    ## dim
    @staticmethod
    def red_dim(text: str) -> str:    return f'\033[02;49;031m{text}\033[0m'
    @staticmethod
    def green_dim(text: str) -> str:  return f'\033[02;49;032m{text}\033[0m'
    @staticmethod
    def yellow_dim(text: str) -> str: return f'\033[02;49;033m{text}\033[0m'
    @staticmethod
    def blue_dim(text: str) -> str:   return f'\033[02;49;034m{text}\033[0m'
    @staticmethod
    def purple_dim(text: str) -> str: return f'\033[02;49;035m{text}\033[0m'
    @staticmethod
    def cyan_dim(text: str) -> str:   return f'\033[02;49;036m{text}\033[0m'
    @staticmethod
    def white_dim(text: str) -> str:  return f'\033[02;49;037m{text}\033[0m'
    @staticmethod
    def gray_dim(text: str) -> str:   return f'\033[02;49;090m{text}\033[0m'

    ## italic
    @staticmethod
    def red_italic(text: str) -> str:    return f'\033[03;49;031m{text}\033[0m'
    @staticmethod
    def green_italic(text: str) -> str:  return f'\033[03;49;032m{text}\033[0m'
    @staticmethod
    def yellow_italic(text: str) -> str: return f'\033[03;49;033m{text}\033[0m'
    @staticmethod
    def blue_italic(text: str) -> str:   return f'\033[03;49;034m{text}\033[0m'
    @staticmethod
    def purple_italic(text: str) -> str: return f'\033[03;49;035m{text}\033[0m'
    @staticmethod
    def cyan_italic(text: str) -> str:   return f'\033[03;49;036m{text}\033[0m'
    @staticmethod
    def white_italic(text: str) -> str:  return f'\033[03;49;037m{text}\033[0m'
    @staticmethod
    def gray_italic(text: str) -> str:   return f'\033[03;49;090m{text}\033[0m'

    ## underline
    @staticmethod
    def red_underline(text: str) -> str:    return f'\033[04;49;031m{text}\033[0m'
    @staticmethod
    def green_underline(text: str) -> str:  return f'\033[04;49;032m{text}\033[0m'
    @staticmethod
    def yellow_underline(text: str) -> str: return f'\033[04;49;033m{text}\033[0m'
    @staticmethod
    def blue_underline(text: str) -> str:   return f'\033[04;49;034m{text}\033[0m'
    @staticmethod
    def purple_underline(text: str) -> str: return f'\033[04;49;035m{text}\033[0m'
    @staticmethod
    def cyan_underline(text: str) -> str:   return f'\033[04;49;036m{text}\033[0m'
    @staticmethod
    def white_underline(text: str) -> str:  return f'\033[04;49;037m{text}\033[0m'
    @staticmethod
    def gray_underline(text: str) -> str:   return f'\033[04;49;090m{text}\033[0m'

    ## blink
    @staticmethod
    def red_blink(text: str) -> str:    return f'\033[05;49;031m{text}\033[0m'
    @staticmethod
    def green_blink(text: str) -> str:  return f'\033[05;49;032m{text}\033[0m'
    @staticmethod
    def yellow_blink(text: str) -> str: return f'\033[05;49;033m{text}\033[0m'
    @staticmethod
    def blue_blink(text: str) -> str:   return f'\033[05;49;034m{text}\033[0m'
    @staticmethod
    def purple_blink(text: str) -> str: return f'\033[05;49;035m{text}\033[0m'
    @staticmethod
    def cyan_blink(text: str) -> str:   return f'\033[05;49;036m{text}\033[0m'
    @staticmethod
    def white_blink(text: str) -> str:  return f'\033[05;49;037m{text}\033[0m'
    @staticmethod
    def gray_blink(text: str) -> str:   return f'\033[05;49;090m{text}\033[0m'

    ## bg
    @staticmethod
    def red_bg(text: str) -> str:    return f'\033[07;49;031m{text}\033[0m'
    @staticmethod
    def green_bg(text: str) -> str:  return f'\033[07;49;032m{text}\033[0m'
    @staticmethod
    def yellow_bg(text: str) -> str: return f'\033[07;49;033m{text}\033[0m'
    @staticmethod
    def blue_bg(text: str) -> str:   return f'\033[07;49;034m{text}\033[0m'
    @staticmethod
    def purple_bg(text: str) -> str: return f'\033[07;49;035m{text}\033[0m'
    @staticmethod
    def cyan_bg(text: str) -> str:   return f'\033[07;49;036m{text}\033[0m'
    @staticmethod
    def white_bg(text: str) -> str:  return f'\033[07;49;037m{text}\033[0m'
    @staticmethod
    def gray_bg(text: str) -> str:   return f'\033[07;49;090m{text}\033[0m'
    @staticmethod
    def brown_bg(text: str) -> str:  return f'\033[48;05;094m{text}\033[0m'
    @staticmethod
    def orange_bg(text: str) -> str: return f'\033[48;05;202m{text}\033[0m'
    @staticmethod
    def olive_bg(text: str) -> str:  return f'\033[48;05;064m{text}\033[0m'

    ## strikethrough
    @staticmethod
    def red_strikethrough(text: str) -> str:    return f'\033[09;49;031m{text}\033[0m'
    @staticmethod
    def green_strikethrough(text: str) -> str:  return f'\033[09;49;032m{text}\033[0m'
    @staticmethod
    def yellow_strikethrough(text: str) -> str: return f'\033[09;49;033m{text}\033[0m'
    @staticmethod
    def blue_strikethrough(text: str) -> str:   return f'\033[09;49;034m{text}\033[0m'
    @staticmethod
    def purple_strikethrough(text: str) -> str: return f'\033[09;49;035m{text}\033[0m'
    @staticmethod
    def cyan_strikethrough(text: str) -> str:   return f'\033[09;49;036m{text}\033[0m'
    @staticmethod
    def white_strikethrough(text: str) -> str:  return f'\033[09;49;037m{text}\033[0m'
    @staticmethod
    def gray_strikethrough(text: str) -> str:   return f'\033[09;49;090m{text}\033[0m'

    def heading(self, text: str) -> str: return self.green(text)
    def ask(self, text: str) -> str:     return self.olive(text)
    def flag(self, text: str) -> str:    return self.purple(text)
    def default(self, text: str) -> str: return self.white_dim(text)

class Audio:
    @staticmethod
    def vol(arg: str) -> Any:
      # port  = check_output(f'pacmd list-sinks | grep -iA 65 "*" | grep -i "active port" | grep -ioP "(?<=<).*?(?=>)"', shell=True, universal_newlines=True).strip()
        name  = check_output(f'pacmd list-sinks | grep -iA 1 "*" | grep -i "name:" | grep -ioP "(?<=<).*?(?=>)"', shell=True, universal_newlines=True).strip()
        index = check_output(f'pacmd list-sinks | grep -i "*"', shell=True, universal_newlines=True).strip().split()[-1]
        level = check_output(f'pacmd list-sinks | grep -iA 6 {name} | grep -i "volume: front"', shell=True, universal_newlines=True).strip().split()[4].replace("%", "")
        state = check_output(f'pacmd list-sinks | grep -iA 3 {name} | grep -i "state:"', shell=True, universal_newlines=True).strip().split()[-1]

        if not match('^bluez_sink', name):
            mute_status = check_output(f'pacmd list-sinks | grep -i "muted"', shell=True, universal_newlines=True).strip().split()[1]
        else:
            mute_status = check_output(f'pacmd list-sinks | grep -i "muted"', shell=True, universal_newlines=True).strip().split()[-1]

        if   arg == 'name':        return name
        elif arg == 'index':       return index
        elif arg == 'level':       return level
        elif arg == 'state':       return state
        elif arg == 'mute_status': return mute_status
      # elif arg == 'port':        return port
        elif arg == 'mute':        run(f'pactl set-sink-mute {index} 1', shell=True)
        elif arg == 'unmute':      run(f'pactl set-sink-mute {index} 0', shell=True)

    @staticmethod
    def mic(arg: str) -> Any:
      # port        = check_output(f'pacmd list-sources | grep -iA 65 "*" | grep -i "active port" | grep -ioP "(?<=<).*?(?=>)"', shell=True, universal_newlines=True).strip()
        name        = check_output(f'pacmd list-sources | grep -iA 1 "*" | grep -i "name:" | grep -ioP "(?<=<).*?(?=>)"', shell=True, universal_newlines=True).strip()
        index       = check_output(f'pacmd list-sources | grep -i "*"', shell=True, universal_newlines=True).strip().split()[-1]
        level       = check_output(f'pacmd list-sources | grep -iA 6 {name} | grep -i "volume: front"', shell=True, universal_newlines=True).strip().split()[4].replace('%', '')
        state       = check_output(f'pacmd list-sources | grep -iA 3 {name} | grep -i "state:"', shell=True, universal_newlines=True).strip().split()[-1]
        mute_status = check_output(f'pacmd list-sources | grep -A 10 {name} | grep -i "muted"', shell=True, universal_newlines=True).strip().split()[-1]

        if   arg == 'name':        return name
        elif arg == 'index':       return index
        elif arg == 'level':       return level
        elif arg == 'state':       return state
        elif arg == 'mute_status': return mute_status
      # elif arg == 'port':        return port
        elif arg == 'mute':        run(f'pactl set-source-mute   {index} 1', shell=True)
        elif arg == 'unmute':      run(f'pactl set-source-mute   {index} 0', shell=True)
        elif arg == '0':           run(f'pactl set-source-volume {index} 0%', shell=True)
        elif arg == '25':          run(f'pactl set-source-volume {index} 25%', shell=True)

    @staticmethod
    def mon(arg: str) -> Any:
        mons = check_output(fr'pacmd list-sources | grep -i "\.monitor" | grep -ioP "(?<=<).*?(?=>)"', shell=True, universal_newlines=True).strip().split()
        for eachmon in mons:
            name = eachmon
            if match('^bluez_sink', name):
                break

        index       = check_output(f'pacmd list-sources | grep -iB 1 {name} | grep -i "index"', shell=True, universal_newlines=True).strip().split()[-1]
        level       = check_output(f'pacmd list-sources | grep -iA 6 {name} | grep -i "volume: front"', shell=True, universal_newlines=True).strip().split()[4].replace('%', '')
        state       = check_output(f'pacmd list-sources | grep -iA 3 {name} | grep -i "state:"', shell=True, universal_newlines=True).strip().split()[-1]
        mute_status = check_output(f'pacmd list-sources | grep -A 10 {name} | grep -i "muted"', shell=True, universal_newlines=True).strip().split()[-1]

        if   arg == 'name':        return name
        elif arg == 'index':       return index
        elif arg == 'level':       return level
        elif arg == 'state':       return state
        elif arg == 'mute_status': return mute_status
        elif arg == 'mute':        run(f'pactl set-source-mute   {index} 1', shell=True)
        elif arg == 'unmute':      run(f'pactl set-source-mute   {index} 0', shell=True)
        elif arg == '0':           run(f'pactl set-source-volume {index} 0%', shell=True)
        elif arg == '100':         run(f'pactl set-source-volume {index} 100%', shell=True)

class Screen:
    @staticmethod
    def screen_1() -> tuple[str, str, int, int]:
        scr_1            = check_output('xrandr | grep -iw connected | grep -i primary', shell=True, universal_newlines=True).strip()
        scr_1_name, *_   = scr_1.split()  ## eDP-1
        scr_1_res_total  = scr_1.split()[3]  ## 1366x768+1920+0
        scr_1_res, *_    = scr_1_res_total.split('+')  ## 1366x768
        scr_1_x, scr_1_y = scr_1_res.split('x')  ## 1366 768
        scr_1_x_offset, scr_1_y_offset = scr_1_res_total.split('+')[1:]  ## 1920 0

        return scr_1_name, scr_1_res, scr_1_x, scr_1_y, scr_1_x_offset, scr_1_y_offset

    @staticmethod
    def screen_2() -> tuple[str, str, int, int]:
        scr_2            = check_output('xrandr | grep -iw connected | grep -vi primary | sed "1q;d"', shell=True, universal_newlines=True).strip()
        scr_2_name, *_   = scr_2.split()
        scr_2_res_total  = scr_2.split()[2]
        scr_2_res, *_    = scr_2_res_total.split('+')
        scr_2_x, scr_2_y = scr_2_res.split('x')
        scr_2_x_offset, scr_2_y_offset = scr_2_res_total.split('+')[1:]

        return scr_2_name, scr_2_res, scr_2_x, scr_2_y, scr_2_x_offset, scr_2_y_offset

    @staticmethod
    def screen_3() -> tuple[str, str, int, int]:
        scr_3           = check_output('xrandr | grep -iw connected | grep -vi primary | sed "2q;d"' , shell=True, universal_newlines=True).strip()
        scr_3_name, *_  = scr_3.split()
        scr_3_res_total = scr_3.split()[2]
        scr_3_res, *_   = scr_3_res_total.split('+')

        ## scr_3 may have a name but no proper scr_3_res (e.g. is 'normal' instead of '1920x1080') because
        ## screen 3 has been turned off at startup with 'xrandr --output "$scr_3_name" --off' command
        ## therefore it doesn't have proper x and y. So, we need try here
        ## TODO can this happen to scr_2 (in screen_2 function) too when second monitor is not attached?
        try:
            scr_3_x, scr_3_y = scr_3_res.split('x')
            scr_3_x_offset, scr_3_y_offset = scr_3_res_total.split('+')[1:]
        except Exception:
            scr_3_x, scr_3_y = None, None
            scr_3_x_offset, scr_3_y_offset = None, None

        return scr_3_name, scr_3_res, scr_3_x, scr_3_y, scr_3_x_offset, scr_3_y_offset

    @staticmethod
    def screen_all() -> str:
        scr_all_res = list(check_output('xrandr | grep -iw current', shell=True, universal_newlines=True).strip().split())
        scr_all_res = scr_all_res[7:10]
        scr_all_res = ''.join(scr_all_res).replace(',', '')

        return scr_all_res

    @staticmethod
    def screens_count() -> int:
        screens_count = check_output('xrandr --listmonitors', shell=True, universal_newlines=True).strip().split()[1]  ## 2

        return screens_count

class Record:
    def __init__(self):
        self.Aud = Audio()

    def audio(self, duration: str, output: str, suffix: str, timer_secs: int) -> None:
        th = Thread(target=timer, args=(suffix, timer_secs), daemon=True)
        th.start()
        run(f'ffmpeg -f pulse -i {self.Aud.mon("index")} -f pulse -i default -filter_complex amix=inputs=2 -t {duration} {output} -loglevel quiet', shell=True)

    def screen(self, resolution: str, x_offset: int, duration: str, output: str, suffix: str, timer_secs: int) -> None:
        th = Thread(target=timer, args=(suffix, timer_secs), daemon=True)
        th.start()
        run(f'ffmpeg -f pulse -i {self.Aud.mon("index")} -f pulse -i default -filter_complex amix=inputs=2 -f x11grab -r 30 \
              -video_size {resolution} -i :0.0+{x_offset},0 -vcodec libx264 -preset veryfast -crf 18 -acodec libmp3lame -q:a 1 \
              -pix_fmt yuv420p -vf eq=saturation=1.3 -t {duration} {output} -loglevel quiet', shell=True)

    def video(self, duration: str, output: str, suffix: str, timer_secs: int) -> None:
        th = Thread(target=timer, args=(suffix, timer_secs), daemon=True)
        th.start()
        run(f'ffmpeg -f v4l2 -framerate 25 -video_size 1366x768 -i {DEF_VIDEO_DEV} -f pulse -i {self.Aud.mon("index")} \
              -f pulse -i default -filter_complex amix=inputs=2 -t {duration} {output} -loglevel quiet', shell=True)

    @Halo(color='green', spinner='dots12')
    def audio_ul(self, output: str) -> None:
        run(f'ffmpeg -f pulse -i {self.Aud.mon("index")} -f pulse -i default -filter_complex amix=inputs=2 {output} -loglevel quiet', shell=True)

    @Halo(color='green', spinner='dots12')
    def screen_ul(self, resolution: str, x_offset: int, output: str) -> None:
        run(f'ffmpeg -f pulse -i {self.Aud.mon("index")} -f pulse -i default -filter_complex amix=inputs=2 -f x11grab -r 30 \
              -video_size {resolution} -i :0.0+{x_offset},0 -vcodec libx264 -preset veryfast -crf 18 -acodec libmp3lame -q:a 1 \
              -pix_fmt yuv420p -vf eq=saturation=1.3 {output} -loglevel quiet', shell=True)

    @Halo(color='green', spinner='dots12')
    def video_ul(self, output: str) -> None:
        run(f'ffmpeg -f v4l2 -framerate 25 -video_size 1366x768 -i {DEF_VIDEO_DEV} -f pulse -i {self.Aud.mon("index")} \
              -f pulse -i default -filter_complex amix=inputs=2 {output} -loglevel quiet', shell=True)

def pipe_to_fzf(items: list[str], multi: bool=False, header: str='') -> str:
    fzf_opts = ''

    if multi:
        fzf_opts += f' --multi'

    if header:
        fzf_opts += f' --header {header}'

    Col = Color()
    fzf = FzfPrompt()

    try:
        item = fzf.prompt(items, fzf_opts)
        item = item[0]
        print(f'{Col.brown("--=[")} {item} {Col.brown("]=--")}')

        return item
    except Exception:
        print(Col.red('No item selected'))
        exit(38)

## Docs: https://dmenu.readthedocs.io/en/latest/
def pipe_to_dmenu(items: list[str]=[], header: str='') -> str:
    try:
        return dmenu_show(items,
            case_insensitive=True,
            lines=getenv('dmenulines'),
            background=getenv('dmenunb'),
            foreground=getenv('dmenunf'),
            background_selected=getenv('dmenusb'),
            foreground_selected=getenv('dmenusf'),
            font=getenv('dmenufn'),
            prompt=header,
        )
    except Exception:
        print(Color().red('No item selected'))
        exit(38)

def invalid(text: str) -> None:
    print(Color().red(text))
    exit(38)

def duration_wrapper() -> str:  ## TODO is str correct for outputs?
    def dec(func: Callable) -> str:
        @wraps(func)
        def wrapper(*args: str, **kwargs: str) -> str:
            start = perf_counter()
            func(*args, **kwargs)
            end = perf_counter()
            secs = end - start

            return convert_second(secs)
        return wrapper
    return dec

def get_width() -> int:
    return get_terminal_size()[0]

def get_input(prompt: str) -> Any:
    answer=input(Color().ask(f'{prompt} '))
    if answer:
        return answer
    return None

def get_single_input(prompt: str) -> Any:
    def _find_getch() -> Any:
        def _getch() -> Any:
            print(Color().ask(f'{prompt} '), end='')
            fd = stdin.fileno()
            old_settings = tcgetattr(fd)
            try:
                setraw(fd)
                ch = stdin.read(1)
            finally:
                tcsetattr(fd, TCSADRAIN, old_settings)

            return ch
        return _getch

    getch = _find_getch()
    single_char = getch()

    if single_char:
        print(single_char)
        return single_char

    '''
    from click import getchar, echo
    while (single_character := getchar(echo(Color().ask(prompt), nl=False))) == '\r':
        print()
        pass
    print(single_character)

    return single_character
    '''

def get_datetime(frmt: str) -> Any:
    if   frmt == 'ymdhms':   output =  dt.now().strftime('%Y%m%d%H%M%S')
    elif frmt == 'ymd':      output =  dt.now().strftime('%Y%m%d')
    elif frmt == 'hms':      output =  dt.now().strftime('%H%M%S')
    elif frmt == 'seconds':  output =  dt.now().strftime('%s')
    elif frmt == 'weekday':  output =  dt.now().strftime('%A')
    elif frmt == 'jymdhms':  output = jdt.now().strftime('%Y%m%d%H%M%S')
    elif frmt == 'jymd':     output = jdt.now().strftime('%Y%m%d')
    elif frmt == 'jhms':     output = jdt.now().strftime('%H%M%S')
    elif frmt == 'jseconds': output = int(jdt.now().timestamp())   ## exceptionally written in this format. have to use int to get rid of decimals
    elif frmt == 'jweekday': output = jdt.now().strftime('%A')

    return output

def create_unique_dir_name(dest) -> str:
    append_index = 2
    if path.exists(dest):
        while path.exists(f'{dest}_{append_index:02}'):
            append_index += 1
        dest = f'{dest}_{append_index:02}'

    return dest

def save_error(error_file, text) -> None:
    current_datetime = get_datetime('jymdhms')
    weekday = get_datetime('jweekday')
    with open(error_file, 'w') as opened_error_file:
        opened_error_file.write(f'{current_datetime}\t{weekday}\n{text}\n')

def msgn(message: str, title: str='', icon: str='', duration: int=10) -> None:
    ## https://notify2.readthedocs.io/en/latest/#notify2.Notification.set_urgency
    ## also have a look at https://www.devdungeon.com/content/desktop-notifications-linux-python
    
    notify2.init('app name')
    n = notify2.Notification(str(message), str(title), icon)
    n.timeout = duration*1000
    n.set_urgency(notify2.URGENCY_NORMAL)  ## URGENCY_CRITICAL, URGENCY_LOW & URGENCY_NORMAL
    n.show()
    notify2.uninit()

def msgc(message: str, title: str='', icon: str='') -> None:
    ## https://notify2.readthedocs.io/en/latest/#notify2.Notification.set_urgency
    ## also have a look at https://www.devdungeon.com/content/desktop-notifications-linux-python
    notify2.init('app name')
    n = notify2.Notification(str(message), str(title), icon)
    n.set_urgency(notify2.URGENCY_CRITICAL)  ## URGENCY_CRITICAL, URGENCY_LOW & URGENCY_NORMAL
    n.show()
    notify2.uninit()

def countdown(start: int=5) -> None:
    for i in range(start, 0, -1):
        msgn(i, duration=1)
        sleep(1)
    sleep(1)

def centralize(text: str, wrapper: str=' ') -> str:
    width = get_width()

    return text.center(width, wrapper)

def get_password(prompt: str) -> str:  ## https://linuxhint.com/python-getpass-module/
    while len(password := getpass(prompt=Color().ask(prompt))) < 1:
        pass

    return password

@lru_cache(maxsize=LRU_CACHE_MAXSIZE)
def remove_trailing_slashes(string: str) -> str:
    '''
    Remove trailing slashes from a string.

    Args:
        string (str): String to normalize.

    Returns:
        str: The normalized string without trailing slashes.

    Examples:
        >>> remove_trailing_slashes('test')
        'test'

        >>> remove_trailing_slashes('test/')
        'test'

        >>> remove_trailing_slashes('test//')
        'test'

        >>> remove_trailing_slashes('https://example.com/')
        'https://example.com'
    '''
    ## __HAS_TEST__

    return sub(r'/+$', r'', string)

def set_widget(widget: str, attr: str, value: str) -> None:
    # widget = f'{widget}_ct'

    run(f'awesome-client "{widget}.{attr} = \'{value}\'"', shell=True)

def update_audio() -> None:
    run(f'{getenv("HOME")}/main/scripts/awesome-widgets audio', shell=True)

def timer(suffix: str, timer_secs: int) -> None:
    start = int(get_datetime('jhms'))
    record_icon_suffix = f'{RECORD_ICON}:{suffix}'

    for i in range(int(timer_secs)):
        current = int(get_datetime('jhms'))
        diff = current - start
        dur = convert_second(diff)
        hms = f'{record_icon_suffix} {dur}'
        set_widget('record', 'markup', hms)
        sleep(1)

@lru_cache(maxsize=LRU_CACHE_MAXSIZE)
def hms_to_seconds(hms: str) -> int:
    '''
    Convert a time string in HH:MM:SS format to total seconds.

    Args:
        hms (str): Time string in 'HH:MM:SS' format.

    Returns:
        int: Total number of seconds represented by the input.

    Examples:
        >>> hms_to_seconds('04:38:23')
        16703

        >>> hms_to_seconds('00:12:19')
        739
    '''
    ## __HAS_TEST__

    h, m, s = map(int, hms.split(':'))
    return h*3600 + m*60 + s

def send_email(subject: str, body: str, sender: str, receiver: str) -> None:
    ## https://realpython.com/python-send-email/

    if sender == getenv('email1'):
        password = getenv('email1_password1')
        server   = 'smtp.mail.yahoo.com'
    elif sender == getenv('email2'):
        password = getenv('email2_password1')
        server   = 'smtp.gmail.com'

    port    = 465
    context = create_default_context()
    text    = f'Subject: {subject}\n\n{body}'  ## NOTE do NOT change the format

    with SMTP_SSL(server, port, context=context) as opened_server:
        try:
            opened_server.login(sender, password)
            opened_server.sendmail(sender, receiver, text)
        except Exception as exc:
            print(Color().red(f'ERROR sending mail:\n{exc!r}'))
            msgc('ERROR', f'sending email\n{exc!r}', f'{getenv("HOME")}/main/configs/themes/alert-w.png')

def send_email_with_attachment(subject: str, body: str, attachment: str, sender: str, receiver: str) -> None:
    ## https://realpython.com/python-send-email/
    if sender == getenv('email1'):
        password = getenv('email1_password1')
        server   = 'smtp.mail.yahoo.com'
    elif sender == getenv('email2'):
        password = getenv('email2_password1')
        server   = 'smtp.gmail.com'

    port = 465

    ## create a multipart message and set headers
    message            = MIMEMultipart()
    message['From']    = sender
    message['To']      = receiver
    message['Subject'] = subject
    # message['Bcc']   = receiver_email  ## recommended for mass emails

    ## add body to email
    message.attach(MIMEText(body, 'plain'))

    ## open file in binary mode
    with open(attachment, 'rb') as opened_attachment:
        ## add file as application/octet-stream
        ## email client can usually download this automatically as attachment
        part = MIMEBase('application', 'octet-stream')
        part.set_payload(opened_attachment.read())

    ## encode file in ASCII characters to send by email
    encoders.encode_base64(part)

    ## add header as key/value pair to attachment part
    part.add_header('Content-Disposition', f'attachment; filename= {attachment}')

    ## add attachment to message and convert message to string
    message.attach(part)
    text = message.as_string()

    ## log in to server using secure context and send email
    context = create_default_context()
    with SMTP_SSL(server, port, context=context) as opened_server:
        try:
            opened_server.login(sender, password)
            opened_server.sendmail(sender, receiver, text)
        except Exception as exc:
            print(Color().red(f'ERROR sending mail:\n{exc!r}'))
            msgc('ERROR', f'sending email\n{exc!r}', f'{getenv("HOME")}/main/configs/themes/alert-w.png')

###########################

def compress_tar(inpt: str) -> None:
    inpt = remove_trailing_slashes(inpt)
    root, base = path.split(inpt)
    dest_dir = root
    chdir(dest_dir)
    dest_tar = f'{base}.tar'

    if path.isdir(inpt):
        with tarfile_open(dest_tar, 'w') as opened_new_tarfile:
            chdir(base)
            for i in listdir():
                opened_new_tarfile.add(i)
    else:
        with tarfile_open(dest_tar, 'w') as opened_new_tarfile:
            opened_new_tarfile.add(base)

def compress_gz(inpt: str) -> None:
    inpt = remove_trailing_slashes(inpt)
    root, base = path.split(inpt)
    dest_dir = root
    chdir(dest_dir)
    dest_gz = f'{base}.gz'

    with open(inpt, 'rb') as f_in:
        with gzip_open(dest_gz, 'wb') as f_out:
            f_out.writelines(f_in)

def compress_zip(inpt: str, password: str='') -> None:
    inpt = remove_trailing_slashes(inpt)
    root, base = path.split(inpt)
    dest_dir = root
    chdir(dest_dir)

    if password == '':
        dest_zip = f'{base}.zip'
        if path.isdir(inpt):
            shutil_make_archive(inpt, 'zip', inpt)

            ## OR: FIXME the problem is it creats empty zip when inpt is a dir containing dir(s)
            # with ZipFile(dest_zip, 'w', compression=ZIP_DEFLATED) as opened_new_zipfile:
            #     chdir(inpt)
            #     for i in listdir():
            #         print(i)
            #         msgn(i)
            #         opened_new_zipfile.write(i)
        else:
            with ZipFile(dest_zip, 'w', compression=ZIP_DEFLATED) as opened_new_zipfile:
                opened_new_zipfile.write(base)
    else:
        if path.isdir(inpt): invalid('files only. currently, cannot create password-protected directories.')
        dest_zip = f'{inpt}.zip'
        compress(inpt, None, dest_zip, password, 5)

def compress_rar(inpt: str, set_password: bool=False) -> None:  ## FIXME find a pythonic way to create rar file
    inpt = remove_trailing_slashes(inpt)
    root, base = path.split(inpt)
    dest_dir = root
    chdir(dest_dir)
    dest_rar = f'{base}.rar'

    if set_password:
        run(f'rar a -p {dest_rar} {base}', shell=True)
    else:
        run(f'rar a {dest_rar} {base}', shell=True)

def xtract_tar(inpt: str) -> None:
    inpt = remove_trailing_slashes(inpt)
    root_base, _ = path.splitext(inpt)
    dest_dir = root_base
    mkdir(dest_dir)

    with tarfile_open(inpt) as opened_cur_tarfile:
        opened_cur_tarfile.extractall(dest_dir)

def xtract_gz(inpt: str) -> None:
    inpt = remove_trailing_slashes(inpt)
    root_base, _ = path.splitext(inpt)
    dest_dir = root_base
    mkdir(dest_dir)

    base = path.basename(dest_dir)
    dest = f'{dest_dir}/{base}'

    with gzip_open(inpt, 'rb') as f_in:
        with open(dest, 'wb') as f_out:
            copyfileobj(f_in, f_out)

def xtract_zip(inpt: str, password: str='') -> None:
    inpt = remove_trailing_slashes(inpt)
    root_base, _ = path.splitext(inpt)
    dest_dir = root_base
    mkdir(dest_dir)

    if password == '':
        with ZipFile(inpt, 'r') as opened_cur_zipfile:
            opened_cur_zipfile.extractall(dest_dir)
    else:
        with ZipFile(inpt, 'r') as opened_cur_zipfile:
            opened_cur_zipfile.setpassword(pwd=bytes(password, 'utf-8'))
            opened_cur_zipfile.extractall(dest_dir)

def xtract_rar(inpt: str, password: str='') -> None:
    inpt = remove_trailing_slashes(inpt)
    root_base, _ = path.splitext(inpt)
    dest_dir = root_base
    mkdir(dest_dir)
    chdir(dest_dir)

    if password == '':
        with RarFile(inpt, 'r') as opened_cur_rarfile:
            opened_cur_rarfile.extractall()
    else:
        with RarFile(inpt, 'r') as opened_cur_rarfile:
            opened_cur_rarfile.extractall(pwd=password)
    ## previously: subprocess.run(f'unrar x {inpt} 1>/dev/null', shell=True)
