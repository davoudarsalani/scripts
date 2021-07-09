# {{{ imports
from os import getenv  ## for send_email* functions
from typing import List  ## for fzf and dmenu functions
## }}}
class Color:  ## {{{
    # def __init__(self): self.text = ''
    ## {{{
    def red(self, text: str):    return f'\033[00;49;031m{text}\033[0m'
    def green(self, text: str):  return f'\033[00;49;032m{text}\033[0m'
    def yellow(self, text: str): return f'\033[00;49;033m{text}\033[0m'
    def blue(self, text: str):   return f'\033[00;49;034m{text}\033[0m'
    def purple(self, text: str): return f'\033[00;49;035m{text}\033[0m'
    def cyan(self, text: str):   return f'\033[00;49;036m{text}\033[0m'
    def white(self, text: str):  return f'\033[00;49;037m{text}\033[0m'
    def grey(self, text: str):   return f'\033[00;49;090m{text}\033[0m'
    def brown(self, text: str):  return f'\033[38;05;094m{text}\033[0m'
    def orange(self, text: str): return f'\033[38;05;202m{text}\033[0m'
    def olive(self, text: str):  return f'\033[38;05;064m{text}\033[0m'
    ## }}}
    ## bold {{{
    def red_bold(self, text: str):    return f'\033[01;49;031m{text}\033[0m'
    def green_bold(self, text: str):  return f'\033[01;49;032m{text}\033[0m'
    def yellow_bold(self, text: str): return f'\033[01;49;033m{text}\033[0m'
    def blue_bold(self, text: str):   return f'\033[01;49;034m{text}\033[0m'
    def purple_bold(self, text: str): return f'\033[01;49;035m{text}\033[0m'
    def cyan_bold(self, text: str):   return f'\033[01;49;036m{text}\033[0m'
    def white_bold(self, text: str):  return f'\033[01;49;037m{text}\033[0m'
    def grey_bold(self, text: str):   return f'\033[01;49;090m{text}\033[0m'
    ## }}}
    ## dim {{{
    def red_dim(self, text: str):    return f'\033[02;49;031m{text}\033[0m'
    def green_dim(self, text: str):  return f'\033[02;49;032m{text}\033[0m'
    def yellow_dim(self, text: str): return f'\033[02;49;033m{text}\033[0m'
    def blue_dim(self, text: str):   return f'\033[02;49;034m{text}\033[0m'
    def purple_dim(self, text: str): return f'\033[02;49;035m{text}\033[0m'
    def cyan_dim(self, text: str):   return f'\033[02;49;036m{text}\033[0m'
    def white_dim(self, text: str):  return f'\033[02;49;037m{text}\033[0m'
    def grey_dim(self, text: str):   return f'\033[02;49;090m{text}\033[0m'
    ## }}}
    ## italic {{{
    def red_italic(self, text: str):    return f'\033[03;49;031m{text}\033[0m'
    def green_italic(self, text: str):  return f'\033[03;49;032m{text}\033[0m'
    def yellow_italic(self, text: str): return f'\033[03;49;033m{text}\033[0m'
    def blue_italic(self, text: str):   return f'\033[03;49;034m{text}\033[0m'
    def purple_italic(self, text: str): return f'\033[03;49;035m{text}\033[0m'
    def cyan_italic(self, text: str):   return f'\033[03;49;036m{text}\033[0m'
    def white_italic(self, text: str):  return f'\033[03;49;037m{text}\033[0m'
    def grey_italic(self, text: str):   return f'\033[03;49;090m{text}\033[0m'
    def brown_italic(self, text: str):  return f'\033[48;05;094m{text}\033[0m'
    def orange_italic(self, text: str): return f'\033[48;05;202m{text}\033[0m'
    def olive_italic(self, text: str):  return f'\033[48;05;064m{text}\033[0m'
    ## }}}
    ## underline {{{
    def red_underline(self, text: str):    return f'\033[04;49;031m{text}\033[0m'
    def green_underline(self, text: str):  return f'\033[04;49;032m{text}\033[0m'
    def yellow_underline(self, text: str): return f'\033[04;49;033m{text}\033[0m'
    def blue_underline(self, text: str):   return f'\033[04;49;034m{text}\033[0m'
    def purple_underline(self, text: str): return f'\033[04;49;035m{text}\033[0m'
    def cyan_underline(self, text: str):   return f'\033[04;49;036m{text}\033[0m'
    def white_underline(self, text: str):  return f'\033[04;49;037m{text}\033[0m'
    def grey_underline(self, text: str):   return f'\033[04;49;090m{text}\033[0m'
    ## }}}
    ## blink {{{
    def red_blink(self, text: str):    return f'\033[05;49;031m{text}\033[0m'
    def green_blink(self, text: str):  return f'\033[05;49;032m{text}\033[0m'
    def yellow_blink(self, text: str): return f'\033[05;49;033m{text}\033[0m'
    def blue_blink(self, text: str):   return f'\033[05;49;034m{text}\033[0m'
    def purple_blink(self, text: str): return f'\033[05;49;035m{text}\033[0m'
    def cyan_blink(self, text: str):   return f'\033[05;49;036m{text}\033[0m'
    def white_blink(self, text: str):  return f'\033[05;49;037m{text}\033[0m'
    def grey_blink(self, text: str):   return f'\033[05;49;090m{text}\033[0m'
    ## }}}
    ## bg {{{
    def red_bg(self, text: str):    return f'\033[07;49;031m{text}\033[0m'
    def green_bg(self, text: str):  return f'\033[07;49;032m{text}\033[0m'
    def yellow_bg(self, text: str): return f'\033[07;49;033m{text}\033[0m'
    def blue_bg(self, text: str):   return f'\033[07;49;034m{text}\033[0m'
    def purple_bg(self, text: str): return f'\033[07;49;035m{text}\033[0m'
    def cyan_bg(self, text: str):   return f'\033[07;49;036m{text}\033[0m'
    def white_bg(self, text: str):  return f'\033[07;49;037m{text}\033[0m'
    def grey_bg(self, text: str):   return f'\033[07;49;090m{text}\033[0m'
    def brown_bg(self, text: str):  return f'\033[48;05;094m{text}\033[0m'
    def orange_bg(self, text: str): return f'\033[48;05;202m{text}\033[0m'
    def olive_bg(self, text: str):  return f'\033[48;05;064m{text}\033[0m'
    ## }}}
    ## strikethrough {{{
    def red_strikethrough(self, text: str):    return f'\033[09;49;031m{text}\033[0m'
    def green_strikethrough(self, text: str):  return f'\033[09;49;032m{text}\033[0m'
    def yellow_strikethrough(self, text: str): return f'\033[09;49;033m{text}\033[0m'
    def blue_strikethrough(self, text: str):   return f'\033[09;49;034m{text}\033[0m'
    def purple_strikethrough(self, text: str): return f'\033[09;49;035m{text}\033[0m'
    def cyan_strikethrough(self, text: str):   return f'\033[09;49;036m{text}\033[0m'
    def white_strikethrough(self, text: str):  return f'\033[09;49;037m{text}\033[0m'
    def grey_strikethrough(self, text: str):   return f'\033[09;49;090m{text}\033[0m'
    ## }}}
    def heading(self, text: str): return self.purple(text)
    def ask(self, text: str):     return self.olive(text)
    def flag(self, text: str):    return self.purple(text)
## }}}
class Audio:  ## {{{
    def vol(self, arg: str):
        from re import match
        from subprocess import run, check_output
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

    def mic(self, arg: str):
        from re import match
        from subprocess import run, check_output
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

    def mon(self, arg: str):
        from re import match
        from subprocess import run, check_output
        mons = check_output(f'pacmd list-sources | grep -i "\.monitor" | grep -ioP "(?<=<).*?(?=>)"', shell=True, universal_newlines=True).strip().split()
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
## }}}
class Screen:  ## {{{

    def screen_1(self):
        from subprocess import check_output
        scr_1             = check_output('xrandr | grep -iw connected | grep -i primary', shell=True, universal_newlines=True).strip()
        scr_1_name, *junk = scr_1.split()
        scr_1_res, *junk  = scr_1.split()[3].split('+')
        scr_1_x, scr_1_y  = scr_1_res.split('x')

        return scr_1_name, scr_1_res, scr_1_x, scr_1_y

    def screen_2(self):
        from subprocess import check_output
        scr_2             = check_output('xrandr | grep -iw connected | grep -vi primary | sed "1q;d"' , shell=True, universal_newlines=True).strip()
        scr_2_name, *junk = scr_2.split()
        scr_2_res, *junk  = scr_2.split()[2].split('+')
        scr_2_x, scr_2_y  = scr_2_res.split('x')

        return scr_2_name, scr_2_res, scr_2_x, scr_2_y

    def screen_3(self):
        from subprocess import check_output
        scr_3             = check_output('xrandr | grep -iw connected | grep -vi primary | sed "2q;d"' , shell=True, universal_newlines=True).strip()
        scr_3_name, *junk = scr_3.split()
        scr_3_res, *junk  = scr_3.split()[2].split('+')
        ## scr_3 may have a name but no proper res (e.g. has 'normal' instead of '1920x1080') because
        ## screen 3 has been turned off at startup with 'xrandr --output "$scr_3_name" --off' command
        ## therefore it doesn't have proper x and y. So, we need try here
        ## TODO can this happen to scr_2 (in screen_2 function) too when second monitor is not attached? [14000328144732]
        try:
            scr_3_x, scr_3_y  = scr_3_res.split('x')
        except Exception:
            scr_3_x, scr_3_y  = None, None

        return scr_3_name, scr_3_res, scr_3_x, scr_3_y

    def screen_all(self):
        from subprocess import check_output
        scr_all_res = list(check_output('xrandr | grep -iw current', shell=True, universal_newlines=True).strip().split())
        scr_all_res = scr_all_res[7:10]
        scr_all_res = ''.join(scr_all_res).replace(',', '')

        return scr_all_res
## }}}
class Record:  ## {{{
    from halo import Halo

    def audio(self, duration: str, output: str, suffix: str, timer_secs: int):
        from subprocess import run
        from threading import Thread
        th = Thread(target=timer, args=(suffix, timer_secs), daemon=True)
        th.start()
        run(f'ffmpeg -f pulse -i {Audio().mon("index")} -f pulse -i default -filter_complex amix=inputs=2 -t {duration} {output} -loglevel quiet', shell=True)

    def screen(self, resolution: str, x_offset: int, duration: str, output: str, suffix: str, timer_secs: int):
        from subprocess import run
        from threading import Thread
        th = Thread(target=timer, args=(suffix, timer_secs), daemon=True)
        th.start()
        run(f'ffmpeg -f pulse -i {Audio().mon("index")} -f pulse -i default -filter_complex amix=inputs=2 -f x11grab -r 30 \
                         -video_size {resolution} -i :0.0+{x_offset},0 -vcodec libx264 -preset veryfast -crf 18 -acodec libmp3lame -q:a 1 \
                         -pix_fmt yuv420p -vf eq=saturation=1.3 -t {duration} {output} -loglevel quiet', shell=True)

    def video(self, duration: str, output: str, suffix: str, timer_secs: int):
        from subprocess import run
        from threading import Thread
        th = Thread(target=timer, args=(suffix, timer_secs), daemon=True)
        th.start()
        run(f'ffmpeg -f v4l2 -framerate 25 -video_size 1366x768 -i {def_video_dev()} -f pulse -i {Audio().mon("index")} \
                         -f pulse -i default -filter_complex amix=inputs=2 -t {duration} {output} -loglevel quiet', shell=True)

    @Halo(color='green', spinner='dots12')
    def audio_ul(self, output: str):
        from subprocess import run
        run(f'ffmpeg -f pulse -i {Audio().mon("index")} -f pulse -i default -filter_complex amix=inputs=2 {output} -loglevel quiet', shell=True)

    @Halo(color='green', spinner='dots12')
    def screen_ul(self, resolution: str, x_offset: int, output: str):
        from subprocess import run
        run(f'ffmpeg -f pulse -i {Audio().mon("index")} -f pulse -i default -filter_complex amix=inputs=2 -f x11grab -r 30 \
                         -video_size {resolution} -i :0.0+{x_offset},0 -vcodec libx264 -preset veryfast -crf 18 -acodec libmp3lame -q:a 1 \
                         -pix_fmt yuv420p -vf eq=saturation=1.3 {output} -loglevel quiet', shell=True)

    @Halo(color='green', spinner='dots12')
    def video_ul(self, output: str):
        from subprocess import run
        run(f'ffmpeg -f v4l2 -framerate 25 -video_size 1366x768 -i {def_video_dev()} -f pulse -i {Audio().mon("index")} \
                         -f pulse -i default -filter_complex amix=inputs=2 {output} -loglevel quiet', shell=True)
## }}}
def dorm(duration: int=1):  ## {{{
    from time import sleep
    sleep(duration)
## }}}
def invalid(text: str):  ## {{{
    print(Color().red(text))
    exit(38)
## }}}
def duration(seconds: int):  ## {{{
    seconds = int(seconds)
    ss = f'{int(seconds % 60):02}'
    mm = f'{int(seconds / 60 % 60):02}'
    hh = f'{int(seconds / 60 / 60 % 24):02}'
    dd = f'{int(seconds / 60 / 60 / 24):02}'

    if dd == '00':
        dur = f'{hh}:{mm}:{ss}'
    else:
        dur = f'{dd}:{hh}:{mm}:{ss}'

    return dur
## }}}
def duration_wrapper():  ## {{{
    from typing import Callable
    def dec(func: Callable):
        from functools import wraps
        from time import perf_counter
        @wraps(func)
        def wrapper(*args: str, **kwargs: str):
            start = perf_counter()
            func(*args, **kwargs)
            end = perf_counter()
            secs = end - start
            dur = duration(secs)

            return dur
        return wrapper
    return dec
## }}}
def get_headers():  ## {{{
    headers = { 'User-Agent'     : 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36',
                'Accept'         : 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                'Accept-Language': 'en-US,en;q=0.5',
                'Accept-Encoding': 'gzip',
                'DNT'            : '1',  ## do not track request header
                'Connection'     : 'close' }

    return headers
## }}}
def get_width():  ## {{{
    from shutil import get_terminal_size
    width, _ = get_terminal_size()
    ## OR:
    # import subprocess
    # width = subprocess.check_output('tput cols', shell=True,  universal_newlines=True).strip()

    return width
## }}}
def separator():  ## {{{
    width = int(get_width())
    sep = Color().grey('-'*width)

    return sep
## }}}
def fzf(items: List[str], header: str=''):  ## {{{
    from subprocess import check_output
    items = '\n'.join(items)
    try:
        item = check_output(f'echo -e "{items}" | fzf --header "{header}"', shell=True, universal_newlines=True).strip()
        print(f'{Color().brown("--=[")} {item} {Color().brown("]=--")}')
        return item
    except Exception:
        print(Color().red('No item selected'))
        exit(38)
## }}}
def get_input(prompt: str):  ## {{{
    while len(output := input(Color().ask(f'{prompt} '))) < 1:
        pass

    return output
## }}}
def get_single_input(prompt: str):  ## {{{ https://stackoverflow.com/questions/510357/how-to-read-a-single-character-from-the-user
    def _find_getch():
        from sys import stdin
        from termios import tcgetattr, tcsetattr, TCSADRAIN
        from tty import setraw
        def _getch():
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
    while (single_char := getch()) == '\r':
        print()

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
## }}}
def get_datetime(frmt: str):  ## {{{
    from datetime import datetime as dt
    from jdatetime import datetime as jdt
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
## }}}
def last_file_exists(last_file):  ## {{{
    from os import path
    condition = [path.exists(last_file)]
    result = all(condition)

    return result
## }}}
def get_last(last_file):  ## {{{
    with open(last_file, 'r') as LAST_FILE:
        output = LAST_FILE.read().splitlines()[-1]

    return output
## }}}
def save_as_last(last_file, text):  ## {{{
    current_datetime = get_datetime('jymdhms')
    weekday = get_datetime('jweekday')
    with open(last_file, 'a') as LAST_FILE:
        LAST_FILE.write(f'{"-"*30}\n{current_datetime}\t{weekday}\n{text}\n')
## }}}
def save_error(error_file, text):  ## {{{
    current_datetime = get_datetime('jymdhms')
    weekday = get_datetime('jweekday')
    with open(error_file, 'a') as ERROR_FILE:
        ERROR_FILE.write(f'{"-"*30}\n{current_datetime}\t{weekday}\n{text}\n')
## }}}
def msgn(message: str, title: str='', icon: str='', duration: int=10):  ## {{{
    ## https://notify2.readthedocs.io/en/latest/#notify2.Notification.set_urgency
    ## also have a look at https://www.devdungeon.com/content/desktop-notifications-linux-python
    import notify2
    notify2.init('app name')
    n = notify2.Notification(str(message), str(title), icon)
    n.timeout = duration*1000
    n.set_urgency(notify2.URGENCY_NORMAL)  ## URGENCY_CRITICAL, URGENCY_LOW & URGENCY_NORMAL
    n.show()
    notify2.uninit()
## }}}
def msgc(message: str, title: str='', icon: str=''):  ## {{{
    ## https://notify2.readthedocs.io/en/latest/#notify2.Notification.set_urgency
    ## also have a look at https://www.devdungeon.com/content/desktop-notifications-linux-python
    import notify2
    notify2.init('app name')
    n = notify2.Notification(str(message), str(title), icon)
    n.set_urgency(notify2.URGENCY_CRITICAL)  ## URGENCY_CRITICAL, URGENCY_LOW & URGENCY_NORMAL
    n.show()
    notify2.uninit()
## }}}
def countdown(start: int=5):  ## {{{
    for i in range(start, 0, -1):
        msgn(i, duration=1)
        dorm(1)
    dorm(1)
## }}}
def centralize(text: str, wrapper: str=' '):  ## {{{
    width = get_width()
    cent_text = text.center(width, wrapper)

    return cent_text
## }}}
def dmenu(items: List[str]=[], title: str=''):  ## {{{
    from os import getenv
    from subprocess import check_output
    items = '\n'.join(items)
    try:
        item = check_output(f'echo -e "{items}" | dmenu -i -l "{getenv("dmenulines")}" -nb "{getenv("dmenunb")}" -nf "{getenv("dmenunf")}" -sb "{getenv("dmenunb")}" -sf "{getenv("dmenusf")}" -fn "{getenv("dmenufn")}" -p "{title}"', shell=True, universal_newlines=True).strip()
        return item
    except Exception:
        print(Color().red('No item selected'))
        exit(38)
## }}}
def get_password(prompt: str):  ## {{{ https://linuxhint.com/python-getpass-module/
    from getpass import getpass
    while len(password := getpass(prompt=Color().ask(prompt))) < 1:
        pass

    return password
## }}}
def remove_leading_zeros(number: int):  ## {{{
    from re import sub
    number = str(number)
    number = sub(r'^0*', r'', number)

    return number
## }}}
def remove_trailing_slash(string: str):  ## {{{
    from re import sub
    string = str(string)
    string = sub(r'/$', r'', string)

    return string
## }}}
def set_widget(widget: str, attr: str, value: str):  ## {{{
    from os import getenv
    from subprocess import check_output, run
    if attr == 'fg':
        widget = f'{widget}_ct'
        if value == 'reset':
            fg = check_output(f'grep "{widget} *=" {getenv("HOME")}/.config/awesome/rc.lua', shell=True, universal_newlines=True).strip().replace(')', '').split()[-1]
            if   fg == 'fg_d' or fg == 'fg_l': value = getenv(fg)
            else:                              value = getenv('purple')
    run(f'echo "{widget}:set_{attr}(\'{value}\')" | awesome-client', shell=True)
## }}}
def record_icon():  ## {{{
    return '<b>RE</b>'
## }}}
def refresh_icon():  ## {{{
    from os import getenv

    return getenv('refresh_icon')
## }}}
def def_video_dev():  ## {{{
    return '/dev/video0'
## }}}
def update_audio():  ## {{{
    from os import getenv
    from subprocess import run
    run(f'{getenv("HOME")}/scripts/awesome-widgets audio', shell=True)
## }}}
def timer(suffix: str, timer_secs: int):  ## {{{
    start = int(get_datetime('jhms'))
    record_icon_suffix = f'{record_icon()}:{suffix}'

    for i in range(int(timer_secs)):
        current = int(get_datetime('jhms'))
        diff = current - start
        dur = duration(diff)
        hms = f'<b>{record_icon_suffix} {dur}</b>'
        set_widget('record', 'markup', hms)
        dorm(1)
## }}}
def uptime():  ## {{{
    with open('/proc/uptime', 'r') as UT:
        secs = UT.read().strip().split()[0]
        secs = int(float(secs))
    uptime = duration(secs)

    return uptime
## }}}
def open_windows():  ## {{{
    from Xlib import display

    screen = display.Display().screen()
    root_win = screen.root

    names = []
    for window in root_win.query_tree()._data['children']:
        name = window.get_wm_name()
        names.append(name)

    return names
## }}}
def send_email(subject: str, body: str, sender: str=getenv('email1'), receiver: str=getenv('email2')):  ## {{{
    ## https://realpython.com/python-send-email/
    from os import getenv
    from smtplib import SMTP_SSL
    from ssl import create_default_context

    if sender == getenv('email1'):
        password = getenv('email1_pass')
        server   = 'smtp.mail.yahoo.com'
    elif sender == getenv('email2'):
        password = getenv('email2_pass')
        server   = 'smtp.gmail.com'

    port    = 465
    context = create_default_context()
    text    = f'Subject: {subject}\n\n{body}'  ## do NOT change the format

    with SMTP_SSL(server, port, context=context) as server:
        try:
            server.login(sender, password)
            server.sendmail(sender, receiver, text)
        except Exception as exc:
            print(Color().red(f'ERROR sending mail:\n{exc!r}'))
            msgc('ERROR', f'sending email\n{exc!r}', f'{getenv("HOME")}/linux/themes/alert-w.png')
## }}}
def send_email_with_attachment(subject: str, body: str, attachment: str, sender: str=getenv('email1'), receiver: str=getenv('email2')):  ## {{{
    ## https://realpython.com/python-send-email/
    from email import encoders
    from email.mime.base import MIMEBase
    from email.mime.multipart import MIMEMultipart
    from email.mime.text import MIMEText
    from os import getenv
    from smtplib import SMTP_SSL
    from ssl import create_default_context

    if sender == getenv('email1'):
        password = getenv('email1_pass')
        server   = 'smtp.mail.yahoo.com'
    elif sender == getenv('email2'):
        password = getenv('email2_pass')
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
    with open(attachment, 'rb') as ATTACHMENT:
        ## add file as application/octet-stream
        ## email client can usually download this automatically as attachment
        part = MIMEBase('application', 'octet-stream')
        part.set_payload(ATTACHMENT.read())

    ## encode file in ASCII characters to send by email
    encoders.encode_base64(part)

    ## add header as key/value pair to attachment part
    part.add_header('Content-Disposition', f'attachment; filename= {attachment}')

    ## add attachment to message and convert message to string
    message.attach(part)
    text = message.as_string()

    ## log in to server using secure context and send email
    context = create_default_context()
    with SMTP_SSL(server, port, context=context) as server:
        try:
            server.login(sender, password)
            server.sendmail(sender, receiver, text)
        except Exception as exc:
            print(Color().red(f'ERROR sending mail:\n{exc!r}'))
            msgc('ERROR', f'sending email\n{exc!r}', f'{getenv("HOME")}/linux/themes/alert-w.png')
## }}}
def hash_string(string: str):  ## {{{
    from hashlib import sha1, sha256, sha512, md5
    string      = f'{string}\n'
    sha1_hash   = sha1(string.encode()).hexdigest()
    sha256_hash = sha256(string.encode()).hexdigest()
    sha512_hash = sha512(string.encode()).hexdigest()
    md5_hash    = md5(string.encode()).hexdigest()
    hashed = f'string\t{string}sha1\t{sha1_hash}\nsha256\t{sha256_hash}\nsha512\t{sha512_hash}\nmd5\t{md5_hash}'

    return hashed
## }}}
def hash_file(file: str):  ## {{{
    from hashlib import sha1, sha256, sha512, md5
    with open(file, 'r') as FILE:
        FILE = FILE.read()
    sha1_hash   = sha1(FILE.encode()).hexdigest()
    sha256_hash = sha256(FILE.encode()).hexdigest()
    sha512_hash = sha512(FILE.encode()).hexdigest()
    md5_hash    = md5(FILE.encode()).hexdigest()
    hashed = f'file\t{file}\nsha1\t{sha1_hash}\nsha256\t{sha256_hash}\nsha512\t{sha512_hash}\nmd5\t{md5_hash}'

    return hashed
## }}}
def garbage():  ## {{{
    from random import randbytes
    while True:
        text = randbytes(80).decode(errors='ignore')
        print(text, end='')
        dorm(0.01)
## }}}
def to_seconds(dur: str):  ## {{{ https://stackoverflow.com/questions/16742381/how-to-convert-youtube-api-duration-to-seconds/49976787#49976787
    '''converts youtube api duration (e.g. PT1H25M41S) to seconds (e.g. 5141)'''
    from re import match

    ## js-like parseInt (https://gist.github.com/douglasmiranda/2174255)
    def _js_parseInt(string):
        return int(''.join([c for c in string if c.isdigit()]))

    mtch = match('PT(\d+H)?(\d+M)?(\d+S)?', dur).groups()
    hours   = _js_parseInt(mtch[0]) if mtch[0] else 0
    minutes = _js_parseInt(mtch[1]) if mtch[1] else 0
    seconds = _js_parseInt(mtch[2]) if mtch[2] else 0
    dur = hours * 3600 + minutes * 60 + seconds

    return dur
## }}}
def compress_tar(inpt: str):  ## {{{
    from os import path, chdir, listdir
    from tarfile import open as tarfile_open
    inpt = remove_trailing_slash(inpt)
    root, base = path.split(inpt)

    dest_dir = root
    dest_tar = f'{base}.tar'
    chdir(dest_dir)
    if path.isdir(inpt):
        with tarfile_open(dest_tar, 'w') as NEW_TAR:
            chdir(base)
            for i in listdir():
                NEW_TAR.add(i)
    else:
        with tarfile_open(dest_tar, 'w') as NEW_TAR:
            NEW_TAR.add(base)
## }}}
def xtract_tar(inpt: str):  ## {{{
    from os import path, mkdir
    from tarfile import open as tarfile_open
    inpt = remove_trailing_slash(inpt)
    root_base, ext = path.splitext(inpt)
    dest_dir = root_base
    mkdir(dest_dir)

    with tarfile_open(inpt) as CUR_TAR:
        CUR_TAR.extractall(dest_dir)
## }}}
def compress_zip(inpt: str, password: str=''):  ## {{{
    from os import chdir, path, listdir
    from zipfile import ZipFile, ZIP_DEFLATED
    from pyminizip import compress
    inpt = remove_trailing_slash(inpt)
    root, base = path.split(inpt)
    dest_dir = root
    chdir(dest_dir)
    if password == '':
        dest_zip = f'{base}.zip'
        if path.isdir(inpt):
            with ZipFile(dest_zip, 'w', compression=ZIP_DEFLATED) as NEW_ZIP:
                chdir(inpt)
                for i in listdir():
                    NEW_ZIP.write(i)
        ## or just: shutil.make_archive(inpt, 'zip', inpt)  ## the problem is it creates a dir inside zip
        else:
            with ZipFile(dest_zip, 'w', compression=ZIP_DEFLATED) as NEW_ZIP:
                NEW_ZIP.write(base)
    else:
        if path.isdir(inpt): invalid('Files only. Currently, cannot create password-protected dirs.')
        dest_zip = f'{inpt}.zip'
        compress(inpt, None, dest_zip, password, 5)
## }}}
def xtract_zip(inpt: str, password: str=''):  ## {{{
    from os import path, mkdir
    from zipfile import ZipFile
    inpt = remove_trailing_slash(inpt)
    root_base, ext = path.splitext(inpt)
    dest_dir = root_base
    mkdir(dest_dir)

    if password == '':
        with ZipFile(inpt, 'r') as CUR_ZIP:
            CUR_ZIP.extractall(dest_dir)
    else:
        with ZipFile(inpt, 'r') as CUR_ZIP:
            CUR_ZIP.setpassword(pwd = bytes(password, 'utf-8'))
            CUR_ZIP.extractall(dest_dir)
## }}}
def xtract_rar(inpt: str, password: str=''):  ## {{{
    from os import path, mkdir, chdir
    from rarfile import RarFile
    inpt = remove_trailing_slash(inpt)
    root_base, ext = path.splitext(inpt)
    dest_dir = root_base
    mkdir(dest_dir)
    chdir(dest_dir)

    if password == '':
        with RarFile(inpt, 'r') as CUR_RAR:
            CUR_RAR.extractall()
    else:
        with RarFile(inpt, 'r') as CUR_RAR:
            CUR_RAR.extractall(pwd=password)
    ## previously: subprocess.run(f'unrar x {inpt} 1>/dev/null', shell=True)
## }}}
