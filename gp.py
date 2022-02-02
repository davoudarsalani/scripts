## @last-modified 1400-11-13 09:43:59 +0330 Wednesday


## for .venv_keylogger: keylogger
## for .venv: (
##   beautifulsoup4
##   black
##   clipboard
##   dbus-python
##   dmenu
##   google-api-python-client
##   halo
##   jdatetime
##   notify2
##   pillow
##   pycurl
##   pyfzf
##   pyminizip
##   pynput
##   python-magic
##   rarfile
##   requests
##   requests[socks]
##   tabulate
##   vext.gi
##   wget
##   youtube_dl
##   [jedi]
## )


from os import getenv  ## for send_email* functions
from typing import Any  ## for Audio, get_input, get_single_input, get_last, get_datetime


class Color:
    @staticmethod
    def red(text: str) -> str:
        return f'\033[00;49;031m{text}\033[0m'

    @staticmethod
    def green(text: str) -> str:
        return f'\033[00;49;032m{text}\033[0m'

    @staticmethod
    def yellow(text: str) -> str:
        return f'\033[00;49;033m{text}\033[0m'

    @staticmethod
    def blue(text: str) -> str:
        return f'\033[00;49;034m{text}\033[0m'

    @staticmethod
    def purple(text: str) -> str:
        return f'\033[00;49;035m{text}\033[0m'

    @staticmethod
    def cyan(text: str) -> str:
        return f'\033[00;49;036m{text}\033[0m'

    @staticmethod
    def white(text: str) -> str:
        return f'\033[00;49;037m{text}\033[0m'

    @staticmethod
    def grey(text: str) -> str:
        return f'\033[00;49;090m{text}\033[0m'

    @staticmethod
    def brown(text: str) -> str:
        return f'\033[38;05;094m{text}\033[0m'

    @staticmethod
    def orange(text: str) -> str:
        return f'\033[38;05;202m{text}\033[0m'

    @staticmethod
    def olive(text: str) -> str:
        return f'\033[38;05;064m{text}\033[0m'

    @staticmethod
    def red_bold(text: str) -> str:
        return f'\033[01;49;031m{text}\033[0m'

    @staticmethod
    def green_bold(text: str) -> str:
        return f'\033[01;49;032m{text}\033[0m'

    @staticmethod
    def yellow_bold(text: str) -> str:
        return f'\033[01;49;033m{text}\033[0m'

    @staticmethod
    def blue_bold(text: str) -> str:
        return f'\033[01;49;034m{text}\033[0m'

    @staticmethod
    def purple_bold(text: str) -> str:
        return f'\033[01;49;035m{text}\033[0m'

    @staticmethod
    def cyan_bold(text: str) -> str:
        return f'\033[01;49;036m{text}\033[0m'

    @staticmethod
    def white_bold(text: str) -> str:
        return f'\033[01;49;037m{text}\033[0m'

    @staticmethod
    def grey_bold(text: str) -> str:
        return f'\033[01;49;090m{text}\033[0m'

    @staticmethod
    def red_dim(text: str) -> str:
        return f'\033[02;49;031m{text}\033[0m'

    @staticmethod
    def green_dim(text: str) -> str:
        return f'\033[02;49;032m{text}\033[0m'

    @staticmethod
    def yellow_dim(text: str) -> str:
        return f'\033[02;49;033m{text}\033[0m'

    @staticmethod
    def blue_dim(text: str) -> str:
        return f'\033[02;49;034m{text}\033[0m'

    @staticmethod
    def purple_dim(text: str) -> str:
        return f'\033[02;49;035m{text}\033[0m'

    @staticmethod
    def cyan_dim(text: str) -> str:
        return f'\033[02;49;036m{text}\033[0m'

    @staticmethod
    def white_dim(text: str) -> str:
        return f'\033[02;49;037m{text}\033[0m'

    @staticmethod
    def grey_dim(text: str) -> str:
        return f'\033[02;49;090m{text}\033[0m'

    @staticmethod
    def red_italic(text: str) -> str:
        return f'\033[03;49;031m{text}\033[0m'

    @staticmethod
    def green_italic(text: str) -> str:
        return f'\033[03;49;032m{text}\033[0m'

    @staticmethod
    def yellow_italic(text: str) -> str:
        return f'\033[03;49;033m{text}\033[0m'

    @staticmethod
    def blue_italic(text: str) -> str:
        return f'\033[03;49;034m{text}\033[0m'

    @staticmethod
    def purple_italic(text: str) -> str:
        return f'\033[03;49;035m{text}\033[0m'

    @staticmethod
    def cyan_italic(text: str) -> str:
        return f'\033[03;49;036m{text}\033[0m'

    @staticmethod
    def white_italic(text: str) -> str:
        return f'\033[03;49;037m{text}\033[0m'

    @staticmethod
    def grey_italic(text: str) -> str:
        return f'\033[03;49;090m{text}\033[0m'

    @staticmethod
    def red_underline(text: str) -> str:
        return f'\033[04;49;031m{text}\033[0m'

    @staticmethod
    def green_underline(text: str) -> str:
        return f'\033[04;49;032m{text}\033[0m'

    @staticmethod
    def yellow_underline(text: str) -> str:
        return f'\033[04;49;033m{text}\033[0m'

    @staticmethod
    def blue_underline(text: str) -> str:
        return f'\033[04;49;034m{text}\033[0m'

    @staticmethod
    def purple_underline(text: str) -> str:
        return f'\033[04;49;035m{text}\033[0m'

    @staticmethod
    def cyan_underline(text: str) -> str:
        return f'\033[04;49;036m{text}\033[0m'

    @staticmethod
    def white_underline(text: str) -> str:
        return f'\033[04;49;037m{text}\033[0m'

    @staticmethod
    def grey_underline(text: str) -> str:
        return f'\033[04;49;090m{text}\033[0m'

    @staticmethod
    def red_blink(text: str) -> str:
        return f'\033[05;49;031m{text}\033[0m'

    @staticmethod
    def green_blink(text: str) -> str:
        return f'\033[05;49;032m{text}\033[0m'

    @staticmethod
    def yellow_blink(text: str) -> str:
        return f'\033[05;49;033m{text}\033[0m'

    @staticmethod
    def blue_blink(text: str) -> str:
        return f'\033[05;49;034m{text}\033[0m'

    @staticmethod
    def purple_blink(text: str) -> str:
        return f'\033[05;49;035m{text}\033[0m'

    @staticmethod
    def cyan_blink(text: str) -> str:
        return f'\033[05;49;036m{text}\033[0m'

    @staticmethod
    def white_blink(text: str) -> str:
        return f'\033[05;49;037m{text}\033[0m'

    @staticmethod
    def grey_blink(text: str) -> str:
        return f'\033[05;49;090m{text}\033[0m'

    @staticmethod
    def red_bg(text: str) -> str:
        return f'\033[07;49;031m{text}\033[0m'

    @staticmethod
    def green_bg(text: str) -> str:
        return f'\033[07;49;032m{text}\033[0m'

    @staticmethod
    def yellow_bg(text: str) -> str:
        return f'\033[07;49;033m{text}\033[0m'

    @staticmethod
    def blue_bg(text: str) -> str:
        return f'\033[07;49;034m{text}\033[0m'

    @staticmethod
    def purple_bg(text: str) -> str:
        return f'\033[07;49;035m{text}\033[0m'

    @staticmethod
    def cyan_bg(text: str) -> str:
        return f'\033[07;49;036m{text}\033[0m'

    @staticmethod
    def white_bg(text: str) -> str:
        return f'\033[07;49;037m{text}\033[0m'

    @staticmethod
    def grey_bg(text: str) -> str:
        return f'\033[07;49;090m{text}\033[0m'

    @staticmethod
    def brown_bg(text: str) -> str:
        return f'\033[48;05;094m{text}\033[0m'

    @staticmethod
    def orange_bg(text: str) -> str:
        return f'\033[48;05;202m{text}\033[0m'

    @staticmethod
    def olive_bg(text: str) -> str:
        return f'\033[48;05;064m{text}\033[0m'

    @staticmethod
    def red_strikethrough(text: str) -> str:
        return f'\033[09;49;031m{text}\033[0m'

    @staticmethod
    def green_strikethrough(text: str) -> str:
        return f'\033[09;49;032m{text}\033[0m'

    @staticmethod
    def yellow_strikethrough(text: str) -> str:
        return f'\033[09;49;033m{text}\033[0m'

    @staticmethod
    def blue_strikethrough(text: str) -> str:
        return f'\033[09;49;034m{text}\033[0m'

    @staticmethod
    def purple_strikethrough(text: str) -> str:
        return f'\033[09;49;035m{text}\033[0m'

    @staticmethod
    def cyan_strikethrough(text: str) -> str:
        return f'\033[09;49;036m{text}\033[0m'

    @staticmethod
    def white_strikethrough(text: str) -> str:
        return f'\033[09;49;037m{text}\033[0m'

    @staticmethod
    def grey_strikethrough(text: str) -> str:
        return f'\033[09;49;090m{text}\033[0m'

    def heading(self, text: str) -> str:
        return self.green(text)

    def ask(self, text: str) -> str:
        return self.olive(text)

    def flag(self, text: str) -> str:
        return self.purple(text)

    def default(self, text: str) -> str:
        return self.white_dim(text)


class Audio:
    @staticmethod
    def vol(arg: str) -> Any:
        from re import match
        from subprocess import run, check_output

        # port  = check_output(f'pacmd list-sinks | grep -iA 65 "*" | grep -i "active port" | grep -ioP "(?<=<).*?(?=>)"', shell=True, universal_newlines=True).strip()
        name = check_output(f'pacmd list-sinks | grep -iA 1 "*" | grep -i "name:" | grep -ioP "(?<=<).*?(?=>)"', shell=True, universal_newlines=True).strip()
        index = check_output(f'pacmd list-sinks | grep -i "*"', shell=True, universal_newlines=True).strip().split()[-1]
        level = check_output(f'pacmd list-sinks | grep -iA 6 {name} | grep -i "volume: front"', shell=True, universal_newlines=True).strip().split()[4].replace("%", "")
        state = check_output(f'pacmd list-sinks | grep -iA 3 {name} | grep -i "state:"', shell=True, universal_newlines=True).strip().split()[-1]

        if not match('^bluez_sink', name):
            mute_status = check_output(f'pacmd list-sinks | grep -i "muted"', shell=True, universal_newlines=True).strip().split()[1]
        else:
            mute_status = check_output(f'pacmd list-sinks | grep -i "muted"', shell=True, universal_newlines=True).strip().split()[-1]

        if arg == 'name':
            return name
        elif arg == 'index':
            return index
        elif arg == 'level':
            return level
        elif arg == 'state':
            return state
        elif arg == 'mute_status':
            return mute_status
        # elif arg == 'port':        return port
        elif arg == 'mute':
            run(f'pactl set-sink-mute {index} 1', shell=True)
        elif arg == 'unmute':
            run(f'pactl set-sink-mute {index} 0', shell=True)

    @staticmethod
    def mic(arg: str) -> Any:
        from re import match
        from subprocess import run, check_output

        # port        = check_output(f'pacmd list-sources | grep -iA 65 "*" | grep -i "active port" | grep -ioP "(?<=<).*?(?=>)"', shell=True, universal_newlines=True).strip()
        name = check_output(f'pacmd list-sources | grep -iA 1 "*" | grep -i "name:" | grep -ioP "(?<=<).*?(?=>)"', shell=True, universal_newlines=True).strip()
        index = check_output(f'pacmd list-sources | grep -i "*"', shell=True, universal_newlines=True).strip().split()[-1]
        level = check_output(f'pacmd list-sources | grep -iA 6 {name} | grep -i "volume: front"', shell=True, universal_newlines=True).strip().split()[4].replace('%', '')
        state = check_output(f'pacmd list-sources | grep -iA 3 {name} | grep -i "state:"', shell=True, universal_newlines=True).strip().split()[-1]
        mute_status = check_output(f'pacmd list-sources | grep -A 10 {name} | grep -i "muted"', shell=True, universal_newlines=True).strip().split()[-1]

        if arg == 'name':
            return name
        elif arg == 'index':
            return index
        elif arg == 'level':
            return level
        elif arg == 'state':
            return state
        elif arg == 'mute_status':
            return mute_status
        # elif arg == 'port':        return port
        elif arg == 'mute':
            run(f'pactl set-source-mute   {index} 1', shell=True)
        elif arg == 'unmute':
            run(f'pactl set-source-mute   {index} 0', shell=True)
        elif arg == '0':
            run(f'pactl set-source-volume {index} 0%', shell=True)
        elif arg == '25':
            run(f'pactl set-source-volume {index} 25%', shell=True)

    @staticmethod
    def mon(arg: str) -> Any:
        from re import match
        from subprocess import run, check_output

        mons = check_output(f'pacmd list-sources | grep -i "\.monitor" | grep -ioP "(?<=<).*?(?=>)"', shell=True, universal_newlines=True).strip().split()
        for eachmon in mons:
            name = eachmon
            if match('^bluez_sink', name):
                break

        index = check_output(f'pacmd list-sources | grep -iB 1 {name} | grep -i "index"', shell=True, universal_newlines=True).strip().split()[-1]
        level = check_output(f'pacmd list-sources | grep -iA 6 {name} | grep -i "volume: front"', shell=True, universal_newlines=True).strip().split()[4].replace('%', '')
        state = check_output(f'pacmd list-sources | grep -iA 3 {name} | grep -i "state:"', shell=True, universal_newlines=True).strip().split()[-1]
        mute_status = check_output(f'pacmd list-sources | grep -A 10 {name} | grep -i "muted"', shell=True, universal_newlines=True).strip().split()[-1]

        if arg == 'name':
            return name
        elif arg == 'index':
            return index
        elif arg == 'level':
            return level
        elif arg == 'state':
            return state
        elif arg == 'mute_status':
            return mute_status
        elif arg == 'mute':
            run(f'pactl set-source-mute   {index} 1', shell=True)
        elif arg == 'unmute':
            run(f'pactl set-source-mute   {index} 0', shell=True)
        elif arg == '0':
            run(f'pactl set-source-volume {index} 0%', shell=True)
        elif arg == '100':
            run(f'pactl set-source-volume {index} 100%', shell=True)


class Screen:
    @staticmethod
    def screen_1() -> tuple[str, str, int, int]:
        from subprocess import check_output

        scr_1 = check_output('xrandr | grep -iw connected | grep -i primary', shell=True, universal_newlines=True).strip()
        scr_1_name, *junk = scr_1.split()
        scr_1_res, *junk = scr_1.split()[3].split('+')
        scr_1_x, scr_1_y = scr_1_res.split('x')

        return scr_1_name, scr_1_res, scr_1_x, scr_1_y

    @staticmethod
    def screen_2() -> tuple[str, str, int, int]:
        from subprocess import check_output

        scr_2 = check_output('xrandr | grep -iw connected | grep -vi primary | sed "1q;d"', shell=True, universal_newlines=True).strip()
        scr_2_name, *junk = scr_2.split()
        scr_2_res, *junk = scr_2.split()[2].split('+')
        scr_2_x, scr_2_y = scr_2_res.split('x')

        return scr_2_name, scr_2_res, scr_2_x, scr_2_y

    @staticmethod
    def screen_3() -> tuple[str, str, int, int]:
        from subprocess import check_output

        scr_3 = check_output('xrandr | grep -iw connected | grep -vi primary | sed "2q;d"', shell=True, universal_newlines=True).strip()
        scr_3_name, *junk = scr_3.split()
        scr_3_res, *junk = scr_3.split()[2].split('+')
        ## scr_3 may have a name but no proper res (e.g. has 'normal' instead of '1920x1080') because
        ## screen 3 has been turned off at startup with 'xrandr --output "$scr_3_name" --off' command
        ## therefore it doesn't have proper x and y. So, we need try here
        ## TODO can this happen to scr_2 (in screen_2 function) too when second monitor is not attached?
        try:
            scr_3_x, scr_3_y = scr_3_res.split('x')
        except Exception:
            scr_3_x, scr_3_y = None, None

        return scr_3_name, scr_3_res, scr_3_x, scr_3_y

    @staticmethod
    def screen_all() -> str:
        from subprocess import check_output

        scr_all_res = list(check_output('xrandr | grep -iw current', shell=True, universal_newlines=True).strip().split())
        scr_all_res = scr_all_res[7:10]
        scr_all_res = ''.join(scr_all_res).replace(',', '')

        return scr_all_res


class Record:
    from halo import Halo

    def __init__(self):
        self.Aud = Audio()
        self.def_video_dev = def_video_dev()

    def audio(self, duration: str, output: str, suffix: str, timer_secs: int) -> None:
        from subprocess import run
        from threading import Thread

        th = Thread(target=timer, args=(suffix, timer_secs), daemon=True)
        th.start()
        run(f'ffmpeg -f pulse -i {self.Aud.mon("index")} -f pulse -i default -filter_complex amix=inputs=2 -t {duration} {output} -loglevel quiet', shell=True)

    def screen(self, resolution: str, x_offset: int, duration: str, output: str, suffix: str, timer_secs: int) -> None:
        from subprocess import run
        from threading import Thread

        th = Thread(target=timer, args=(suffix, timer_secs), daemon=True)
        th.start()
        run(
            f'ffmpeg -f pulse -i {self.Aud.mon("index")} -f pulse -i default -filter_complex amix=inputs=2 -f x11grab -r 30 \
              -video_size {resolution} -i :0.0+{x_offset},0 -vcodec libx264 -preset veryfast -crf 18 -acodec libmp3lame -q:a 1 \
              -pix_fmt yuv420p -vf eq=saturation=1.3 -t {duration} {output} -loglevel quiet',
            shell=True,
        )

    def video(self, duration: str, output: str, suffix: str, timer_secs: int) -> None:
        from subprocess import run
        from threading import Thread

        th = Thread(target=timer, args=(suffix, timer_secs), daemon=True)
        th.start()
        run(
            f'ffmpeg -f v4l2 -framerate 25 -video_size 1366x768 -i {self.def_video_dev} -f pulse -i {self.Aud.mon("index")} \
              -f pulse -i default -filter_complex amix=inputs=2 -t {duration} {output} -loglevel quiet',
            shell=True,
        )

    @Halo(color='green', spinner='dots12')
    def audio_ul(self, output: str) -> None:
        from subprocess import run

        run(f'ffmpeg -f pulse -i {self.Aud.mon("index")} -f pulse -i default -filter_complex amix=inputs=2 {output} -loglevel quiet', shell=True)

    @Halo(color='green', spinner='dots12')
    def screen_ul(self, resolution: str, x_offset: int, output: str) -> None:
        from subprocess import run

        run(
            f'ffmpeg -f pulse -i {self.Aud.mon("index")} -f pulse -i default -filter_complex amix=inputs=2 -f x11grab -r 30 \
              -video_size {resolution} -i :0.0+{x_offset},0 -vcodec libx264 -preset veryfast -crf 18 -acodec libmp3lame -q:a 1 \
              -pix_fmt yuv420p -vf eq=saturation=1.3 {output} -loglevel quiet',
            shell=True,
        )

    @Halo(color='green', spinner='dots12')
    def video_ul(self, output: str) -> None:
        from subprocess import run

        run(
            f'ffmpeg -f v4l2 -framerate 25 -video_size 1366x768 -i {self.def_video_dev} -f pulse -i {self.Aud.mon("index")} \
              -f pulse -i default -filter_complex amix=inputs=2 {output} -loglevel quiet',
            shell=True,
        )


def fzf(items: list[str], header: str = '') -> str:
    from os import getenv
    from pyfzf.pyfzf import FzfPrompt

    if header:
        header = f'--header {header}'

    Col = Color()
    fzf = FzfPrompt()
    fzf_opts = f'{getenv("FZF_DEFAULT_OPTS")} {header}'

    try:
        item = fzf.prompt(items, fzf_opts)
        item = item[0]
        print(f'{Col.brown("--=[")} {item} {Col.brown("]=--")}')

        return item
    except Exception:
        print(Col.red('No item selected'))
        exit(38)


def invalid(text: str) -> None:
    print(Color().red(text))
    exit(38)


def relative_date(start_date: str):
    ## start_date is in 2019-05-03T07:07:11Z format

    start_date_in_seconds = convert_to_second(start_date)
    now_in_seconds = get_datetime('seconds')
    diff = now_in_seconds - start_date_in_seconds

    return f"{convert_second(diff, 'verbose')} ago"


def convert_to_second(fulldate: str) -> int:
    from datetime import datetime

    return int(datetime.strptime(fulldate, '%Y-%m-%dT%H:%M:%S%Z').timestamp())


def convert_second(seconds: int, verbose: bool = False) -> str:
    from re import sub

    seconds = int(seconds)
    ss = f'{int(seconds % 60):02}'
    mi = f'{int(seconds / 60 % 60):02}'
    hh = f'{int(seconds / 3600 % 24):02}'
    dd = f'{int(seconds / 3600 / 24 % 30):02}'
    mo = f'{int(seconds / 3600 / 24 / 30 % 12):02}'
    yy = f'{int(seconds / 3600 / 24 / 30 / 12):02}'

    if yy == '00' and mo == '00' and dd == '00':
        if verbose:
            result = f'{hh} hours, {mi} minutes and {ss} seconds'
        else:
            result = f'{hh}:{mi}:{ss}'
    elif yy == '00' and mo == '00':
        if verbose:
            result = f'{dd} days, {hh} hours, {mi} minutes and {ss} seconds'
        else:
            result = f'{dd}:{hh}:{mi}:{ss}'
    elif yy == '00':
        if verbose:
            result = f'{mo} months, {dd} days, {hh} hours, {mi} minutes and {ss} seconds'
        else:
            result = f'{mo}:{dd}:{hh}:{mi}:{ss}'
    else:
        if verbose:
            result = f'{yy} years, {mo} months, {dd} days, {hh} hours, {mi} minutes and {ss} seconds'
        else:
            result = f'{yy}:{mo}:{dd}:{hh}:{mi}:{ss}'

    ## NOTE the same modifications in JUMP_4 are applied in
    ##        1. convert_second function in gb
    ##        2. 'relative' method of whatever-its-name-is class in models.py in django app
    ##      so any changes you make here, make sure to update them too

    ## JUMP_4 remove items whose values are 00, and adjust comma and 'and'
    result = sub(r'00 [a-z]+s, ', r'', result)
    result = sub(r'00 [a-z]+s and ', r'', result)
    result = sub(r'00 [a-z]+s$', r'', result)
    result = sub(r', ([0-9][0-9] [a-z]+s )', r' and \1', result)
    result = sub(r'and 00 [a-z]+s ', r'', result)
    result = sub(r' and $', r'', result)
    result = sub(r', ([0-9][0-9] [a-z]+)$', r' and \1', result)
    result = sub(r' and ([0-9][0-9] [a-z]+) and', r', \1 and', result)
    result = sub(r', +$', r'', result)
    result = sub(r', ([0-9][0-9] [a-z]+s)$', r' and \1', result)

    ## JUMP_4 remove plural s when value is 01
    result = sub(r'(01 [a-z]+)s ', r'\1 ', result)
    result = sub(r'(01 [a-z]+)s, ', r'\1, ', result)
    result = sub(r'(01 [a-z]+)s$', r'\1', result)

    return result


def duration_wrapper() -> str:
    from typing import Callable

    def dec(func: Callable) -> str:
        from functools import wraps
        from time import perf_counter

        @wraps(func)
        def wrapper(*args: str, **kwargs: str) -> str:
            start = perf_counter()
            func(*args, **kwargs)
            end = perf_counter()
            secs = end - start

            return convert_second(secs)

        return wrapper

    return dec


def get_headers() -> dict[str, str]:
    return {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip',
        'DNT': '1',  ## do not track request header
        'Connection': 'close',
    }


def get_width() -> int:
    from shutil import get_terminal_size

    return get_terminal_size()[0]
    ## OR:
    # import subprocess
    # return subprocess.check_output('tput cols', shell=True, universal_newlines=True).strip()


def get_input(prompt: str) -> Any:
    answer = input(Color().ask(f'{prompt} '))
    if answer:
        return answer


def get_single_input(prompt: str) -> Any:
    def _find_getch() -> Any:
        from sys import stdin
        from termios import tcgetattr, tcsetattr, TCSADRAIN
        from tty import setraw

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
    from datetime import datetime as dt
    from jdatetime import datetime as jdt

    if frmt == 'ymdhms':
        output = dt.now().strftime('%Y%m%d%H%M%S')
    elif frmt == 'ymd':
        output = dt.now().strftime('%Y%m%d')
    elif frmt == 'hms':
        output = dt.now().strftime('%H%M%S')
    elif frmt == 'seconds':
        output = dt.now().strftime('%s')
    elif frmt == 'weekday':
        output = dt.now().strftime('%A')
    elif frmt == 'jymdhms':
        output = jdt.now().strftime('%Y%m%d%H%M%S')
    elif frmt == 'jymd':
        output = jdt.now().strftime('%Y%m%d')
    elif frmt == 'jhms':
        output = jdt.now().strftime('%H%M%S')
    elif frmt == 'jseconds':
        output = int(jdt.now().timestamp())  ## exceptionally written in this format. have to use int to get rid of decimals
    elif frmt == 'jweekday':
        output = jdt.now().strftime('%A')

    return output


def if_exists(dest) -> str:
    from os import path

    append_index = 2
    if path.exists(dest):
        while path.exists(f'{dest}_{append_index:02}'):
            append_index += 1
        dest = f'{dest}_{append_index:02}'

    return dest


def last_file_exists(last_file) -> bool:
    from os import path

    condition = [path.exists(last_file)]

    return all(condition)


def get_last(last_file) -> Any:
    with open(last_file, 'r') as opened_last_file:
        output = opened_last_file.read().splitlines()[-1]

    return output


def save_as_last(last_file, text) -> None:
    current_datetime = get_datetime('jymdhms')
    weekday = get_datetime('jweekday')
    with open(last_file, 'w') as opened_last_file:
        opened_last_file.write(f'{current_datetime}\t{weekday}\n{text}\n')


def save_error(error_file, text) -> None:
    current_datetime = get_datetime('jymdhms')
    weekday = get_datetime('jweekday')
    with open(error_file, 'w') as opened_error_file:
        opened_error_file.write(f'{current_datetime}\t{weekday}\n{text}\n')


def msgn(message: str, title: str = '', icon: str = '', duration: int = 10) -> None:
    ## https://notify2.readthedocs.io/en/latest/#notify2.Notification.set_urgency
    ## also have a look at https://www.devdungeon.com/content/desktop-notifications-linux-python
    import notify2

    notify2.init('app name')
    n = notify2.Notification(str(message), str(title), icon)
    n.timeout = duration * 1000
    n.set_urgency(notify2.URGENCY_NORMAL)  ## URGENCY_CRITICAL, URGENCY_LOW & URGENCY_NORMAL
    n.show()
    notify2.uninit()


def msgc(message: str, title: str = '', icon: str = '') -> None:
    ## https://notify2.readthedocs.io/en/latest/#notify2.Notification.set_urgency
    ## also have a look at https://www.devdungeon.com/content/desktop-notifications-linux-python
    import notify2

    notify2.init('app name')
    n = notify2.Notification(str(message), str(title), icon)
    n.set_urgency(notify2.URGENCY_CRITICAL)  ## URGENCY_CRITICAL, URGENCY_LOW & URGENCY_NORMAL
    n.show()
    notify2.uninit()


def countdown(start: int = 5) -> None:
    from time import sleep

    for i in range(start, 0, -1):
        msgn(i, duration=1)
        sleep(1)
    sleep(1)


def centralize(text: str, wrapper: str = ' ') -> str:
    width = get_width()

    return text.center(width, wrapper)


def dmenu(items: list[str] = [], title: str = '', fg: str = '') -> str:
    from os import getenv
    import dmenu

    if fg == 'red':
        sb = getenv('red_dark')
    else:
        sb = getenv('dmenusb')

    try:
        return dmenu.show(
            items,
            case_insensitive=True,
            lines=getenv('dmenulines'),
            background=getenv('dmenunb'),
            foreground=getenv('dmenunf'),
            background_selected=sb,
            foreground_selected=getenv('dmenusf'),
            font=getenv('dmenufn'),
            prompt=title,
        )
    except Exception:
        print(Color().red('No item selected'))
        exit(38)


def rofi(items: list[str] = [], title: str = '', fg: str = '') -> str:
    from os import getenv
    from subprocess import check_output

    items = '\n'.join(items)

    if not fg == 'red':
        theme = f'{getenv("HOME")}/.config/rofi/onedark.rasi'
    else:
        theme = f'{getenv("HOME")}/.config/rofi/onedark-red.rasi'

    try:
        return check_output(f'echo -e "{items}" | rofi -theme {theme} -dmenu -i -p "{title}"', shell=True, universal_newlines=True).strip()
    except Exception:
        print(Color().red('No item selected'))
        exit(38)


def get_password(prompt: str) -> str:
    from getpass import getpass

    while len(password := getpass(prompt=Color().ask(prompt))) < 1:
        pass

    return password


def remove_leading_zeros(number: int) -> int:
    from re import sub

    number = str(number)
    number = sub(r'^0*', r'', number)

    return number


def remove_trailing_slash(string: str) -> str:
    from re import sub

    string = str(string)
    string = sub(r'/$', r'', string)

    return string


def set_widget(widget: str, attr: str, value: str) -> None:
    from os import getenv
    from subprocess import check_output, run

    if attr == 'fg':
        widget = f'{widget}_ct'
        if value == 'reset':
            fg = check_output(f'grep "{widget} *=" {getenv("HOME")}/.config/awesome/rc.lua', shell=True, universal_newlines=True).strip().replace(')', '').split()[-1]
            if fg == 'fg_d' or fg == 'fg_l':
                value = getenv(fg)
            else:
                value = getenv('purple')
    run(f'echo "{widget}:set_{attr}(\'{value}\')" | awesome-client', shell=True)


def record_icon() -> str:
    return 'RE'


def refresh_icon() -> str:
    from os import getenv

    return getenv('refresh_icon')


def def_video_dev() -> str:
    return '/dev/video0'


def update_audio() -> None:
    from os import getenv
    from subprocess import run

    run(f'{getenv("HOME")}/scripts/awesome-widgets audio', shell=True)


def timer(suffix: str, timer_secs: int) -> None:
    from time import sleep

    start = int(get_datetime('jhms'))
    record_icon_suffix = f'{record_icon()}:{suffix}'

    for i in range(int(timer_secs)):
        current = int(get_datetime('jhms'))
        diff = current - start
        dur = convert_second(diff)
        hms = f'{record_icon_suffix} {dur}'
        set_widget('record', 'markup', hms)
        sleep(1)


def uptime(verbose: bool = False) -> str:
    with open('/proc/uptime', 'r') as opened_uptime_file:
        secs = opened_uptime_file.read().strip().split()[0]
        secs = int(float(secs))
    if verbose:
        return convert_second(secs, verbose=True)
    else:
        return convert_second(secs)


def open_windows() -> list[str]:
    from Xlib import display

    screen = display.Display().screen()
    root_win = screen.root

    names = []
    for window in root_win.query_tree()._data['children']:
        name = window.get_wm_name()
        names.append(name)

    return names


def send_email(subject: str, body: str, sender: str = getenv('email1'), receiver: str = getenv('email2')) -> None:
    ## https://realpython.com/python-send-email/
    from os import getenv
    from smtplib import SMTP_SSL
    from ssl import create_default_context

    if sender == getenv('email1'):
        password = getenv('email1_password1')
        server = 'smtp.mail.yahoo.com'
    elif sender == getenv('email2'):
        password = getenv('email2_password1')
        server = 'smtp.gmail.com'

    port = 465
    context = create_default_context()
    text = f'Subject: {subject}\n\n{body}'  ## NOTE do NOT change the format

    with SMTP_SSL(server, port, context=context) as opened_server:
        try:
            opened_server.login(sender, password)
            opened_server.sendmail(sender, receiver, text)
        except Exception as exc:
            print(Color().red(f'ERROR sending mail:\n{exc!r}'))
            msgc('ERROR', f'sending email\n{exc!r}', f'{getenv("HOME")}/linux/themes/alert-w.png')


def send_email_with_attachment(subject: str, body: str, attachment: str, sender: str = getenv('email1'), receiver: str = getenv('email2')) -> None:
    ## https://realpython.com/python-send-email/
    from email import encoders
    from email.mime.base import MIMEBase
    from email.mime.multipart import MIMEMultipart
    from email.mime.text import MIMEText
    from os import getenv
    from smtplib import SMTP_SSL
    from ssl import create_default_context

    if sender == getenv('email1'):
        password = getenv('email1_password1')
        server = 'smtp.mail.yahoo.com'
    elif sender == getenv('email2'):
        password = getenv('email2_password1')
        server = 'smtp.gmail.com'

    port = 465

    ## create a multipart message and set headers
    message = MIMEMultipart()
    message['From'] = sender
    message['To'] = receiver
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
            msgc('ERROR', f'sending email\n{exc!r}', f'{getenv("HOME")}/linux/themes/alert-w.png')


def hash_string(string: str) -> str:
    from hashlib import sha1, sha256, sha512, md5

    string = f'{string}\n'
    sha1_hash = sha1(string.encode()).hexdigest()
    sha256_hash = sha256(string.encode()).hexdigest()
    sha512_hash = sha512(string.encode()).hexdigest()
    md5_hash = md5(string.encode()).hexdigest()

    return f'string\t{string}sha1\t{sha1_hash}\nsha256\t{sha256_hash}\nsha512\t{sha512_hash}\nmd5\t{md5_hash}'


def hash_file(file: str) -> str:
    from hashlib import sha1, sha256, sha512, md5

    with open(file, 'r') as opened_file:
        opened_file = opened_file.read()
    sha1_hash = sha1(opened_file.encode()).hexdigest()
    sha256_hash = sha256(opened_file.encode()).hexdigest()
    sha512_hash = sha512(opened_file.encode()).hexdigest()
    md5_hash = md5(opened_file.encode()).hexdigest()

    return f'file\t{file}\nsha1\t{sha1_hash}\nsha256\t{sha256_hash}\nsha512\t{sha512_hash}\nmd5\t{md5_hash}'


def garbage() -> None:
    from random import randbytes
    from time import sleep

    while True:
        text = randbytes(80).decode(errors='ignore')
        print(text, end='')
        sleep(0.01)


def to_seconds(dur: str) -> int:
    '''converts youtube api duration (e.g. PT1H25M41S) to seconds (e.g. 5141)'''
    from re import match

    ## js-like parseInt (https://gist.github.com/douglasmiranda/2174255)
    def _js_parseInt(string) -> int:
        return int(''.join([c for c in string if c.isdigit()]))

    mtch = match('PT(\d+H)?(\d+M)?(\d+S)?', dur).groups()
    hours = _js_parseInt(mtch[0]) if mtch[0] else 0
    minutes = _js_parseInt(mtch[1]) if mtch[1] else 0
    seconds = _js_parseInt(mtch[2]) if mtch[2] else 0

    return hours * 3600 + minutes * 60 + seconds


def if_tor() -> None:
    import socket
    import sys

    try:
        tor_c = socket.create_connection(('127.0.0.1', 9051))
        tor_c.send('AUTHENTICATE "{}"\r\nGETINFO status/circuit-established\r\nQUIT\r\n'.format('YOUR_PWD'))
        response = tor_c.recv(1024)
        print(response)
        if 'circuit-established=1' not in response:
            print('Something is not right.')
        else:
            print('Looks good.')
        tor_c.close()
    except Exception as exc:
        print(Color().red(f'{exc!r}'))


###########################
def compress_tar(inpt: str) -> None:
    from os import path, chdir, listdir
    from tarfile import open as tarfile_open

    inpt = remove_trailing_slash(inpt)
    root, base = path.split(inpt)

    dest_dir = root
    dest_tar = f'{base}.tar'
    chdir(dest_dir)
    if path.isdir(inpt):
        with tarfile_open(dest_tar, 'w') as opened_new_tarfile:
            chdir(base)
            for i in listdir():
                opened_new_tarfile.add(i)
    else:
        with tarfile_open(dest_tar, 'w') as opened_new_tarfile:
            opened_new_tarfile.add(base)


def xtract_tar(inpt: str) -> None:
    from os import path, mkdir
    from tarfile import open as tarfile_open

    inpt = remove_trailing_slash(inpt)
    root_base, _ = path.splitext(inpt)
    dest_dir = root_base
    mkdir(dest_dir)

    with tarfile_open(inpt) as opened_cur_tarfile:
        opened_cur_tarfile.extractall(dest_dir)


def compress_zip(inpt: str, password: str = '') -> None:
    from os import chdir, path, listdir
    import shutil
    from zipfile import ZipFile, ZIP_DEFLATED
    from pyminizip import compress

    inpt = remove_trailing_slash(inpt)
    root, base = path.split(inpt)
    dest_dir = root
    chdir(dest_dir)
    if password == '':
        dest_zip = f'{base}.zip'
        if path.isdir(inpt):
            shutil.make_archive(inpt, 'zip', inpt)

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
        if path.isdir(inpt):
            invalid('Files only. Currently, cannot create password-protected dirs.')
        dest_zip = f'{inpt}.zip'
        compress(inpt, None, dest_zip, password, 5)


def xtract_zip(inpt: str, password: str = '') -> None:
    from os import path, mkdir
    from zipfile import ZipFile

    inpt = remove_trailing_slash(inpt)
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


def xtract_rar(inpt: str, password: str = '') -> None:
    from os import path, mkdir, chdir
    from rarfile import RarFile

    inpt = remove_trailing_slash(inpt)
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
