#!/usr/bin/env python

## last modified: 1400-09-08 16:38:01 +0330 Monday

## imports {{{
from __future__ import unicode_literals
from dataclasses import dataclass, field
from datetime import timedelta, datetime as dt
from functools import partial
from getopt import getopt
from glob import glob
from inspect import stack
from math import floor, log, pow as math_pow
from os import path, mkdir, chdir, getenv
from pathlib import Path
from random import shuffle
from re import sub, match
from subprocess import run, check_output
from sys import argv
from time import sleep
from typing import Any, Type
from urllib.request import urlopen, ProxyHandler, build_opener, install_opener

from pycurl import Curl
from requests import Session
from tabulate import tabulate
from wget import download as wget_download
from youtube_dl import YoutubeDL
from gp import Color, duration, duration_wrapper, fzf, get_datetime, get_input, get_single_input, invalid, get_width, get_headers, if_exists
## }}}
def display_help() -> None:  ## {{{
    run('clear', shell=True)
    print(f'''{Col.heading(f'{title}')} {Col.yellow('help')}
{Col.flag('-s --source=')}a text file e.g. $HOME/downloads/lucy,
            a url e.g. https://www.youtube.com/watch?v=WpqCLcAXkJs or https://www.davoudarsalani.ir/Files/Temp/002.jpg,
            a youtube playlist id e.g. PLzMcBGfZo4-nK0Pyubp7yIG0RdXp6zklu or PL-zMcBGfZo4-nK0Pyubp7yIG0RdXp6zklu
            or free
{Col.flag('-f --file-type=')}{Col.default('[o]')}/v/s/vs/a/t
{Col.flag('-d --downloader=')}{Col.default('[urlopen]')}/requests/wget/curl for o,
                or {Col.default('[youtube_dl]')}/curl for v/s/vs/a/t
{Col.flag('-q --quality=')}{Col.default('[22]')}/243/best/etc
{Col.flag('-i --increment=')}{Col.default('[None]')}/1/24/etc
{Col.flag('-r --retries=')}{Col.default('[5]')}/3/10/etc
{Col.flag('-w --when=')}{Col.default('[n]')}/h
{Col.flag('-t --tor')}
{Col.flag('-n --no-information')}
{Col.flag('-v --verbose')}
{Col.flag('-p --purge')}''')  ## JUMP_1 whatever downloader you add/remove, update the allowed list of downloaders in Ini.verify_args()
    exit()
## }}}
def separator() -> str:  ## {{{
    width = int(get_width())

    return Col.grey('-'*width)
## }}}
def make_attempts() -> list[int]:  ## {{{
    return [_ for _ in range(1, int(Ini.retries)+1)]
## }}}
def make_qualities() -> list[str]:  ## {{{
    return ['18', '22', '133', '134', '135', '136', '137', '140', '160', '242', '243', '244', '247', '248', '249', '250', '251', '278', '394', '395', '396', '397', '398', '399', 'best']
## }}}
def make_errors() -> dict[str, str]:  ## {{{
    '''possible errors (i.e. keys) and what we should do (i.e. values)'''

    return {
        ## [[ mainly happening in youtube-dl
        'No video formats found':            '',  ## 'break' not necessary because it was seen to be running ok in the next Cur.attempt
        'Too Many Requests':                 'restart',
        'requested format not available':    'best',
        'PERROR torsocks':                   'break',
        'video doesnt have subtitles':       'break',
        'No subtitle format found matching': 'break',
        'Unable to extract video title':     'break',
        'is not a valid URL':                'break',
        'This video is unavailable':         'break',
        'This video is not available':       'break',
        'YouTube said: Invalid parameters':  'break',
        'unable to download video data':     'break',
        'No video results':                  'break',
        'An extractor error has occurred':   'break',
        'Unsupported URL':                   'break',
        'Signature extraction failed':       'break',
        'Incorrect padding':                 'break',
        '404 Not Found':                     'break',
        '403: Forbidden':                    'break',
        'unable to resolve host address':    'break',
        'Could not resolve host':            'break',
        'Unable to connect to server':       'break',
        ## ]]

        ## [[ mainly happening in youtube_dl and wget modules
        'Connection refused': 'break',
        ## happened when tor is off
        ## Full: Unable to download webpage: <urlopen error [Errno 111] Connection refused>

        'ConnectionError': 'break',
        ## happened for o when url (domain part) is misspelled (e.g. https://www.davoni.ir/Files/Temp/002.jpg)
        ## Full: ConnectionError(MaxRetryError("HTTPSConnectionPool(host=\'www.davoni.ir\', port=443): Max retries exceeded with url: /Files/Temp/002.jp
        ##       (Caused by NewConnectionError(\'<urllib3.connection.HTTPSConnection object at 0x7f3a26fcba60>:
        ##       Failed to establish a new connection: [Errno -2] Name or service not known\'))"))

        'ConnectTimeout': 'break',
        ## happened for File.get_info() when url is censored
        ## Full: ConnectTimeout(MaxRetryError("HTTPConnectionPool(host=\'wsdownload.bbc.co.uk\', port=80): Max retries exceeded with url:
        ##       /learningenglish/pdf/2014/09/140924101602_140924_vwitn_inmates_bank.pdf (Caused by ConnectTimeoutError(<urllib3.connection.HTTPConnection
        ##       object at 0x7fcb37ab2b20>, \'Connection to wsdownload.bbc.co.uk timed out. (connect timeout=20)\'))"))

        'DownloadError': 'break',
        ## Full: DownloadError("ERROR: Unable to download API page: Remote end closed connection without response (caused by RemoteDisconnected(\'Remote
        ##       and closed connection without response\')); please report this issue on https://yt-dl.org/bug . Make sure you are using the latest version;
        ##       see https://yt-dl.org/update  on how to update. Be sure to call youtube-dl with the --verbose flag and include its complete output.")
        ##
        ## happened when youtube url is incomplete
        ## Full: DownloadError('ERROR: Incomplete YouTube ID gllU. URL https://www.youtube.com/watch?v=gllU looks truncated.')
        ##
        ## happened when youtube video is private
        ## Full: DownloadError("ERROR: Private video\\nSign in if you\'ve been granted access to this video")

        'HTTPError': 'break',
        ## happened for o when url (file name part) is misspelled (e.g. https://www.davoudarsalani.ir/Files/Temp/002.jp)
        ## Full: HTTPError('404 Client Error: Not Found for url: https://www.davoudarsalani.ir/Files/Temp/002.jp')
        ##
        ## happened for o when url (file name part) is misspelled (e.g. https://raw.githubusercontent.com/ran.jpg)
        ## Full: <HTTPError 400: 'Bad Request'>
        ## Full: HTTPError('400 Client Error: Bad Request for url: https://raw.githubusercontent.com/ran.jpg')

        ## happened for o when url is censored
        ## Full: HTTPError('403 Client Error: Forbidden for url: http://open.live.bbc.co.uk/p09cn7sc.mp3')
        ## Full: <HTTPError 403: 'Forbidden'

        'IndexError': 'break',
        ## happened for Youtube.get_info() when url is misspelled (e.g. it's incomplete) or private and can't get info, and therefore 'items' list is empty
        ## Full: IndexError('list index out of range')

        'URLError': 'break',
        ## happened for File.get_info() when url is censored
        ## Full: URLError(ConnectionResetError(104, 'Connection reset by peer'))
        ##
        ## happened for File.get_info() with wget module when url (domain part) is missplelled (e.g. https://www.davoni.ir/Files/Temp/002.jpg)
        ## Full: URLError(gaierror(-2, 'Name or service not known'))
        ##
        ## happened when url is censored
        ## Full: URLError('unknown url type: socks5')

        'ExtractorError': 'break',
        ## Full: ExtractorError('No video formats found')

        'RemoteDisconnected': 'break',
        ## Full: RemoteDisconnected('Remote end closed connection without response')

        'RegexNotFoundError': 'break',
        ## Full: RegexNotFoundError('Unable to extract Initial JS player signature function name; please report this issue on https://yt-dl.org/bug .
        ##       Make sure you are using the latest version; type  youtube-dl -U  to update. Be sure to call youtube-dl with the --verbose flag
        ##       and include its complete output.',)); please report this issue on https://yt-dl.org/bug . Make sure you are using the latest version;
        ##       type  youtube-dl -U  to update. Be sure to call youtube-dl with the --verbose flag and include its complete output.

        'MissingSchema': 'break',
        ## Full: MissingSchema("Invalid URL \'\': No schema supplied. Perhaps you meant http://?")

        'NameError': 'break',
        ## Full: NameError("name \'xxxxxxx\' is not defined")

        'ValueError': 'break',
        ## Full: ValueError("unknown url type: \'\'")

        ## error(28, 'Connection timed out after 20001 milliseconds')
        ## error(23, 'Failure writing output to destination')
        ## ]]

        ## [[ happening in error files (i.e. error files of bwu, weather, etc. in $HOME/scripts/.last directory) just to add more examples
        'AttributeError': 'break',
        ## Full: AttributeError("'NoneType' object has no attribute 'text'")

        'OSError': 'break',
        ## Full: OSError(101, 'Network is unreachable')

        'ReadTimeout': 'break',
        ## Full: ReadTimeout(ReadTimeoutError("HTTPSConnectionPool(host='api.openweathermap.org', port=443): Read timed out. (read timeout=20)"))

        'ServerNotFoundError':'break',
        ## Full: ServerNotFoundError('Unable to find the server at youtube.googleapis.com')

        'SSLCertVerificationError':'break',
        ## Full: SSLCertVerificationError(1, '[SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed:
        ##       self signed certificate in certificate chain (_ssl.c:1123)')

        'SSLEOFError': 'break',
        ## Full: SSLEOFError(8, 'EOF occurred in violation of protocol (_ssl.c:1123)')

        'SSLError': 'break',
        ## Full: SSLError(MaxRetryError("HTTPSConnectionPool(host='<ADDR>', port=443): Max retries exceeded with url: <ADDR>
        ##       (Caused by SSLError(SSLCertVerificationError(1, '[SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed:
        ##       self signed certificate in certificate chain (_ssl.c:1123)')))"))

        'TypeError': 'break',
        ## Full: TypeError('Missing required parameter "part"')

        'TimeoutError': 'break',
        ## Full: TimeoutError(110, 'Connection timed out')

        'timeout': 'break',
        ## Full: timeout('_ssl.c:1112: The handshake operation timed out')
        ## Full: timeout('timed out')

        'HttpError': 'break',
        ## Full: <HttpError 400 when requesting <ADDR> returned "API key not valid. Please pass a valid API key.".
        ##       Details: "[{'message': 'API key not valid. Please pass a valid API key.', 'domain': 'global', 'reason': 'badRequest'}]">
        ## Full: <HttpError 400 when requesting <ADDR> returned "No filter selected. Expected one of: id, managedByMe, forUsername, mine, mySubscribers, categoryId".
        ##       Details: "[{'message': 'No filter selected. Expected one of: id, managedByMe, forUsername, mine, mySubscribers, categoryId',
        ##       'domain': 'youtube.parameter', 'reason': 'missingRequiredParameter', 'location': 'parameters.', 'locationType': 'other'}]">

        'abort': 'break',
        ## Full: abort('command: STATUS => IMAP4rev1 Server logging out')
        ## Full: abort('socket error: EOF')

        'ConnectionError': 'break',
        ## Full: ConnectionError(MaxRetryError("HTTPSConnectionPool(host='api.openweathermap.org', port=443):
        ##       Max retries exceeded with url: /data/2.5/onecall?lang=en&lat=29.4519&lon=60.8842&units=metric&exclude=hourly,minutely&appid=5283a501dcfcf51f4cb59e29e1d70382
        ##       (Caused by NewConnectionError('<urllib3.connection.HTTPSConnection object at 0x7efc639130d0>:
        ##       Failed to establish a new connection: [Errno -3] Temporary failure in name resolution'))"))
        ## Full: ConnectionError(ProtocolError('Connection aborted.', ConnectionResetError(104, 'Connection reset by peer')))
        ## Full: ConnectionError(ProtocolError('Connection aborted.', RemoteDisconnected('Remote end closed connection without response')))
        ## Full: ConnectionError(ReadTimeoutError("HTTPSConnectionPool(host='stackoverflow.com', port=443): Read timed out."))

        'ConnectionResetError': 'break',
        ## Full: ConnectionResetError(104, 'Connection reset by peer')

        'gaierror': 'break',
        ## Full: gaierror(-3, 'Temporary failure in name resolution')
        ## ]]
    }
## }}}
def convert_byte(size_in_bytes) -> str:  ## {{{ https://stackoverflow.com/questions/5194057/better-way-to-convert-file-sizes-in-python
    if size_in_bytes == 0:
        return '0B'

    suff = ('B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB')
    i = int(floor(log(size_in_bytes, 1024)))
    p = math_pow(1024, i)
    conv = f'{float(size_in_bytes / p):.2f}'

    return f'{conv}{suff[i]}'
## }}}
def restart_tor() -> None:  ## {{{
    ## restart tor only if it is already on
    try:
        tor_status = check_output('pgrep "tor"', shell=True, universal_newlines=True).strip()
    except Exception:
        tor_status = 'off'

    if not tor_status == 'off':
        if path.exists('/bin/pacman'):
            run('sudo systemctl restart tor', shell=True)
        elif path.exists('/bin/apt'):
            run('sudo service tor restart', shell=True)
        else:
            print(Col.red({'ERROR': 'TOR not restarted (unknown OS)'}))
            return

        sleep(15)
## }}}
def savelog_print(text: Any, fg: str='', prnt: bool=True) -> None:  ## {{{
    text = str(text)

    ## savelog
    if Ini.log_file:
        with open(Ini.log_file, 'a') as opened_log_file:
            opened_log_file.write(f'{text}\n')

    ## print
    if prnt:
        ## TODO get rid of multiple ifs
        if not fg:              print(text)
        elif fg == 'blue':      print(Col.blue(text))
        elif fg == 'brown':     print(Col.brown(text))
        elif fg == 'red':       print(Col.red(text))
        elif fg == 'white_dim': print(Col.white_dim(text))
        elif fg == 'white':     print(Col.white(text))
        elif fg == 'yellow':    print(Col.yellow(text))
## }}}
def analyze(stderr: str, nth_attempt: int, class_ins: Type, caller: str='') -> None:  ## {{{ TODO is Type correct?
    class_ins.should_restart_tor = False  ## TODO is it needed here?

    if nth_attempt < len(class_ins.attempts):
        for error_k, error_v in class_ins.errors.items():
            if error_k in stderr:
                if Ini.verbose:
                    class_ins.error_msg = stderr
                else:
                    class_ins.error_msg = error_k

                if error_v == 'break':
                    class_ins.should_break = True
                elif error_v == 'restart':
                    class_ins.should_restart_tor = True
                elif error_v == 'best':
                    Ini.quality = 'best'

                break
        else:
            class_ins.error_msg = f'UNKNOWN: {stderr}'
            class_ins.should_restart_tor = True
    else:
        class_ins.error_msg = f'Failed after {nth_attempt} attempts. Last error: {stderr}'
        class_ins.should_break = True  ## <--,-- this is the last Cur.attempt and the loop will automatically break anyawy,
                                       ##    '-- but it is needed here for the url to be added to failures

    if caller == 'download':
        savelog_print(class_ins.error_dict, 'red')
        if class_ins.should_break:
            Ini.add_to_failures()

    if class_ins.should_restart_tor:
        restart_tor()
## }}}
def normalize(text: str) -> str:  ## {{{
    text = text.lower()
    text = sub(r'[\s_]', r'-', text)  ##    ,-- \w does not include _
    text = sub(r'[^\w-]', r'', text)  ## <--'-- that's why _ is included in the previous command
    text = sub(r'-+', r'-', text)

    return text
## }}}
def calculate_order() -> dict[str, str]:  ## {{{
    perc = int((Cur.index * 100) / Ini.urls_length)

    return {f'{Cur.index}/{Ini.urls_length}': f'%{perc}'}
## }}}
@duration_wrapper()
def main() -> None:  ## {{{
    print(Col.heading(title))

    Ini.getopts()

    items = ['download', 'help']
    item = fzf(items)

    if item == 'download':

        Ini.verify_args()
        savelog_print(f'{Ini}\n', 'blue')

        if Ini.is_playlist:
            savelog_print(f'{Pla}\n', 'white')

        while Ini.when == 'h' and not Ini.permission:
            Ini.check_to_start()
            sleep(60)

        for url in Ini.urls:

            Ini.create_current(url)

            for Cur.attempt in Cur.attempts:
                Cur.should_break = False

                Ini.check_to_exit()

                savelog_print(Cur.attempt_message, 'white_dim')
                Cur.download_duration = Cur.download()

                if Cur.should_break:
                    break

                ## TODO we can sleep between retries here
            ## END Cur.attempts

            if Ini.increment:
                Ini.increment += 1

            Cur.report()
        ## END urls
    elif item == 'help':
        display_help()
## }}}

@dataclass
class Initial:  ## {{{
    ## {{{
    time: int                   = field(repr=False, default=get_datetime('jhms'))
    attrs: dict[str, str]       = field(repr=False, default_factory=dict)
    urls: list[str]             = field(repr=False, default_factory=list)
    failures: list[str]         = field(repr=False, default_factory=list)
    failures_count: int         = field(repr=False, default=0)
    failed_table: str           = field(repr=False, default=None)
    table_header: list[str]     = field(repr=False, default_factory=list)
    table_rows: list[str]       = field(repr=False, default_factory=list)
    permission: bool            = field(repr=False, default=False)
    total_duration: str         = field(repr=False, default=None)
    total_downloaded_raw: int   = field(repr=False, default=None)
    total_downloaded: str       = field(repr=False, default=None)
    wait_duration: str          = field(repr=False, default=None)
    happy_hours_start_time: int = field(repr=False, default=21000)
    happy_hours_end_time: int   = field(repr=False, default=63000)
    is_playlist: bool           = field(repr=False, default=False)
    increment_prefix: str       = field(repr=False, default='')  ## NOTE do NOT replace '' with None
    valid_qualities: list[str]  = field(repr=False, default_factory=make_qualities)
    datetime: int               = get_datetime('jymdhms')
    weekday: int                = get_datetime('jweekday').lower()
    dest_dir: str               = None

    source: str          = None
    file_type: str       = 'o'
    downloader: bool     = False
    quality: str         = '22'
    increment: int       = None
    retries: int         = 5
    when: str            = 'n'
    tor: bool            = False
    no_information: bool = False
    verbose: bool        = False
    purge : bool         = False
    ## }}}
    def getopts(self) -> None:  ## {{{
        try:
            duos, duos_long = getopt(
                script_args,
                'hs:f:d:q:i:r:w:tnvp',
                ['help', 'source=', 'file-type=', 'downloader=', 'quality=', 'increment=', 'retries=', 'when=', 'tor', 'no-information', 'verbose', 'purge']
            )
            for opt, arg in duos:
                if   opt in ('-h', '--help'):           display_help()
                elif opt in ('-s', '--source'):         self.source         = arg
                elif opt in ('-f', '--file-type'):      self.file_type      = arg
                elif opt in ('-d', '--downloader'):     self.downloader     = arg
                elif opt in ('-q', '--quality'):        self.quality        = arg
                elif opt in ('-i', '--increment'):      self.increment      = arg
                elif opt in ('-r', '--retries'):        self.retries        = arg
                elif opt in ('-w', '--when'):           self.when           = arg
                elif opt in ('-t', '--tor'):            self.tor            = True
                elif opt in ('-n', '--no-information'): self.no_information = True
                elif opt in ('-v', '--verbose'):        self.verbose        = True
                elif opt in ('-p', '--purge'):          self.purge          = True
        except Exception as exc:
            getopts_error_msg = f'{exc!r}'
            invalid({'GETOPTS ERROR': getopts_error_msg})
    ## }}}
    def verify_args(self) -> None:  ## {{{
            ## {{{ self.source + self.urls, self.dest_dir & self.log_file
            ## https://www.geeksforgeeks.org/python-check-url-string/
            url_regex = r"(?i)\b((?:https?://|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'\".,<>?«»“”‘’]))"
            playlist_id_regex = '^PL'  ## TODO better regex (I don't think - is required after PL)

            if not self.source:
                self.source = get_input('Source')

            ## check if self.source is a file
            if path.isfile(self.source):

                ## create self.urls list from self.source
                with open(self.source, 'r') as opened_source:
                    lines = opened_source.read().splitlines()  ## OR: opened_source.readlines()
                self.urls = list(filter(lambda line: not line.startswith('#') and line, lines))
                if not self.urls:
                    invalid('Source contains no downloadable urls')

                root_base, _ = path.splitext(self.source)  ## '$HOME/downloads/lucy', '.txt'
                self.dest_dir = root_base

            ## check if we should download videos from my website
            ## better be placed before the statement that makes sure self.source is not a directory
            elif self.source == 'free':
                v_dirs = glob(f'{getenv("HOME")}/website/DL/Video/*')
                for v_dir in v_dirs:
                    v_count = len(list(glob(f'{v_dir}/*mp4')))
                    if v_count:
                        for number in range(1, v_count + 1):
                            _, base = path.split(v_dir)  ## '$HOME/website/DL/Video', 'Sprouts'
                            self.urls.append(f'https://www.dl.davoudarsalani.ir/DL/Video/{base}/{number:03}.mp4')

                shuffle(self.urls)

                self.dest_dir = f'{getenv("HOME")}/downloads/free'

            ## make sure self.source is not a directory
            elif path.isdir(self.source):
                invalid('Source cannot be a directory')

            ## check if self.source is a url
            elif match(url_regex, self.source):
                ## create self.urls list from self.source
                self.urls = [self.source]

                if 'youtube' in self.source:
                    _, *url_id = self.source.split('=')  ## [WpqCLcAXkJs] or []
                    url_id = ''.join(url_id)
                    ## url_id may be left empty here due to bad self.source (e.g. https://www.youtube.com/watch?vWpqCLcAXkJs)
                    ## if so, we have nothing else to do but exit
                    if not url_id:
                        invalid('url seems incorrect.')

                    self.dest_dir = f'{getenv("HOME")}/downloads/{url_id}'
                else:
                    _, source_base = path.split(self.source)  ## 'https://www.davoudarsalani.ir/Files/Temp', '001.jpg'
                    root_source_base, _ = path.splitext(source_base)  ## '001', '.jpg'
                    self.dest_dir = f'{getenv("HOME")}/downloads/{root_source_base}'

            ## check if self.source is a playlist id
            elif match(playlist_id_regex, self.source):
                global Pla

                self.is_playlist = True
                Pla = Playlist()
                Pla.get_info()

                ## create self.urls list from Pla.pl_urls which is s list
                self.urls = list(filter(lambda line: not line.startswith('#') and line, Pla.pl_urls))
                if not self.urls:
                    invalid('No urls extracted from playlist id')
                self.dest_dir = f'{getenv("HOME")}/downloads/{normalize(self.source)}'

            else:
                invalid('Source neither exists nor is a valid url')

            ## FIXME find how to remove trailing/leading space self.urls members
            ## TODO remove repeated urls and print if so

            if self.purge:
                self.dest_dir = f'/tmp/purge_{self.time}'

            self.dest_dir = if_exists(self.dest_dir)
            mkdir(self.dest_dir)
            chdir(self.dest_dir)
            ## }}}
            ## {{{ file_type
            if self.file_type not in ['v', 's', 'vs', 'a', 't', 'o']:
                invalid('Invalid file type')
            ## }}}
            ## downloader {{{ JUMP_1
            if self.downloader and ((self.file_type in ['v', 's', 'vs', 't', 'a'] and not self.downloader == 'curl') or (self.file_type == 'o' and self.downloader not in ['requests', 'wget', 'curl'])):
                invalid(f'invalid downloader for {self.file_type}')
            ## }}}
            ## quality {{{
            if self.quality not in self.valid_qualities:
                invalid(f'Invalid quality. It has to be one of these: {self.valid_qualities}')
            ## }}}
            ## increment {{{
            if self.increment:
                try:
                    self.increment = int(self.increment)
                except Exception:
                    invalid('increment should be a number')
            ## }}}
            ## retries {{{
            try:
                self.retries = int(self.retries)  ## make sure self.retries is an int
                _ = 1 / self.retries  ## make sure self.retries is not 0
                self.retries = abs(self.retries)  ## make sure self.retries is greater than 0
            except Exception:
                invalid('retries should be a number and greater than zero')
            ## }}}
            ## when {{{
            if self.when not in ['n', 'h']:
                invalid('Invalid time')
            ## }}}
    ## }}}
    def create_current(self, url) -> None:  ## {{{
        global Cur

        if self.file_type in ['v', 's', 'vs', 'a', 't']:
            Cur = Youtube()
        elif self.file_type == 'o':
            Cur = File()

        Cur.get_info(url)  ## TODO how can we pass url directly when creating the class above?
    ## }}}
    def calculate_total_downloaded(self) -> None:  ## {{{
        ## FIXME <--,-- we are currently calculating dest_dir size after each download but this is not a reliable way
        ##          |-- because new files may replace existing files that have the same name.
        ##          |-- what's more, adding Cur.file_raw_size to Ini.total_downloaded_raw after each download is not reliable either
        ##          |-- because 1: sometimes Cur.file_raw_size is either NOINFO (if requested so), ERROR or 0,
        ##          '-- or 2: we dont't even have the file size for v, s, vs, a, and t
        root_directory = Path(self.dest_dir)
        self.total_downloaded_raw = sum(file.stat().st_size for file in root_directory.glob('**/*'))
        self.total_downloaded = convert_byte(self.total_downloaded_raw)
    ## }}}
    def add_to_failures(self) -> None:  ## {{{
        self.failures.append({**Cur.order, 'url': Cur.url, **Cur.error_dict})
        self.failures_count += 1
    ## }}}
    def draw_failed_table(self) -> str:  ## {{{
        if self.failures:
            # self.table_header = ['count', 'more info']
            self.table_rows = [[f'{fail_index}/{self.failures_count}', failure] for fail_index, failure in enumerate(self.failures, start=1)]
            self.failed_table = tabulate(self.table_rows, headers=self.table_header, tablefmt='grid')

            savelog_print(self.failed_table, 'red')
    ## }}}
    def update_time(self) -> None:  ## {{{
        self.time = int(get_datetime('jhms'))
    ## }}}
    def check_to_start(self) -> None:  ## {{{
        self.update_time()
        self.calculate_wait_duration()

        if self.happy_hours_end_time > self.time > self.happy_hours_start_time:
            self.permission = True
        else:
            savelog_print({'time': self.time, 'wait': self.wait_duration}, 'brown')
    ## }}}
    def check_to_exit(self) -> None:  ## {{{
        self.update_time()

        if self.when == 'h' and self.time > self.happy_hours_end_time:
            savelog_print('Happy hours over. Exit.', 'brown')
            exit()
    ## }}}
    def calculate_wait_duration(self) -> None:  ## {{{ https://stackoverflow.com/questions/36810003/calculate-seconds-from-now-to-specified-time-today-or-tomorrow
        hr = int(str(self.happy_hours_start_time)[:1])  ## 2
        mins = int(str(self.happy_hours_start_time)[1:3])  ## 10
        now = dt.now()  ## 2021-08-05 18:55:06.865231
        secsleft = int((timedelta(hours=24) - (now - now.replace(hour=hr, minute=mins, second=0, microsecond=0))).total_seconds() % (24 * 3600))
        self.wait_duration = duration(secsleft)
    ## }}}
    def report(self) -> None:  ## {{{
        ## report failures if any
        Ini.draw_failed_table()

        self.update_time()
        savelog_print({'time': self.time, 'took': self.total_duration}, 'brown')
    ## }}}
    @property
    def urls_length(self) -> int:  ## {{{
        return len(self.urls)
    ## }}}
    @property
    def log_file(self) -> str:  ## {{{
        return f'{self.dest_dir}/log'
    ## }}}
    @property
    def total_downloaded_dict(self) -> dict[str, str]:  ## {{{
        self.calculate_total_downloaded()
        return {'total downloaded': self.total_downloaded}
    ## }}}
    @property
    def failures_count_dict(self) -> dict[str, str]:  ## {{{
        if self.failures_count:
            return {'failures': self.failures_count}
        return {}
    ## }}}
## }}}
@dataclass
class Profile:  ## {{{
    ## {{{
    errors: dict[str, str]   = field(repr=False, default_factory=make_errors)
    attempts: list[int]      = field(repr=False, default_factory=make_attempts)
    attempt: int             = field(repr=False, default=None)
    get_info_attempt: int    = field(repr=False, default=None)
    counter: int             = field(repr=False, default=0)
    index: int               = field(repr=False, default=None)
    should_break: bool       = field(repr=False, default=False)
    should_restart_tor: bool = field(repr=False, default=False)
    error_msg: str           = field(repr=False, default=None)
    download_duration: str   = field(repr=False, default=None)

    order: dict[str, str] = field(default_factory=dict)
    time: int             = None
    url: int              = None
    outputname: str       = None
    ## }}}
    def report(self) -> None:  ## {{{
        savelog_print({**self.download_duration_dict, **Ini.total_downloaded_dict, **Ini.failures_count_dict}, 'brown')
        savelog_print(separator())
    ## }}}
    def index_up(self) -> None:  ## {{{
        Profile.counter += 1
        self.index = Profile.counter
    ## }}}
    @property
    def download_duration_dict(self) -> dict[str, str]:  ## {{{
        return {'took': self.download_duration}
    ## }}}
    @property
    def error_dict(self) -> dict[str, str]:  ## {{{
        return {'ERROR MSG': self.error_msg}
    ## }}}
    @property
    def attempt_dict(self) -> dict[str, int]:  ## {{{
        return {'attempt': self.attempt}
    ## }}}
    @property
    def attempt_message(self) -> None:  ## {{{
        if self.attempt == 1:
            return self
        return self.attempt_dict
    ## }}}
## }}}
@dataclass
class File(Profile):  ## {{{
    ## {{{
    progress_file_downloaded_raw: int  = field(repr=False, default=0)  ## NOTE do NOT replace 0 with None because it'll be later added to in JUMP_4
    progress_file_downloaded: int      = field(repr=False, default=None)
    progress_file_downloaded_perc: int = field(repr=False, default=None)
    chunksize: int                     = field(repr=False, default=8192)  ## 8192 is 8KB
    file_raw_size_validity: bool       = field(repr=False, default=False)
    file_raw_size_invalidity_msg: str  = field(repr=False, default=None)

    file_raw_size: int      = field(repr=False, default=None)
    file_size: str          = None
    file_content_type: str  = None
    file_last_modified: str = None
    ## }}}
    def __post_init__(self):  ## {{{
        super().__init__()
        self.index_up()
    ## }}}
    def get_info(self, url) -> None:  ## {{{
        if Ini.increment:
            Ini.increment_prefix = f'{Ini.increment:03}-RNMD-'

        time = get_datetime('jhms')
        order = calculate_order()

        ## get outputname
        _, base = path.split(url)  ## 'https://www.davoudarsalani.ir/Files/Temp', '001.jpg'
        root_base, ext = path.splitext(base)  ## '001', '.jpg'
        outputname = normalize(root_base)
        outputname = f'{Ini.increment_prefix}{outputname}{ext}'

        ## not necessary because we use urlopen, and not requests, to get info
        # if Ini.tor:
        #     Ses.proxies = {'http': tor_proxy, 'https': tor_proxy}

        ## get file_content_type, file_last_modified, file_raw_size, file_size
        if Ini.no_information:
            info = order, time, url, 'NOINFO', 'NOINFO', 'NOINFO', 'NOINFO', outputname
        else:
            for self.get_info_attempt in self.attempts:
                self.should_break = False

                try:
                    ## get headers (method 1: using urlopen) TODO make it less of a mess!
                    ## https://stackoverflow.com/questions/22676/how-to-download-a-file-over-http
                    headers = {}
                    for h in str(urlopen(url).info()).strip().split('\n'):
                        header_k, header_v = h.split(':', 1)
                        headers[header_k] = header_v.strip()

                    ## get headers (method 2: using requests)
                    # get_info_requests_response = Ses.head(url, headers=hdrs, timeout=20)
                    # headers = get_info_requests_response.headers
                    # status_code = get_info_requests_response.status_code  ## 200

                    file_content_type = headers.get('Content-Type', 'ERROR')    ## <--, <--,-- if url (domain part) is misspelled, file_content_type is assigned 'ERROR'
                    file_last_modified = headers.get('Last-Modified', 'ERROR')  ## <--|    |-- in except, but if url (file name part) is misspelled, the file_content_type
                    file_raw_size = int(headers.get('Content-Length', 0))       ## <--|    '-- is always 'text/html; charset=UTF-8' regardless of the real file type
                    file_size = convert_byte(file_raw_size)                     ##    '-- exceptionally used get because the key is not always there

                    info = order, time, url, file_raw_size, file_size, file_content_type, file_last_modified, outputname

                    self.should_break = True

                except Exception as exc:
                    method_name = stack()[0][3]
                    analyze(f'{exc!r}', nth_attempt=self.get_info_attempt, class_ins=Cur, caller=method_name)
                    info = order, time, url, 'ERROR', 'ERROR', 'ERROR', 'ERROR', outputname

                if self.should_break:
                    break

        self.order, self.time, self.url, self.file_raw_size, self.file_size, self.file_content_type, self.file_last_modified, self.outputname = info
        self.check_raw_size_validity()  ## self.file_raw_size may be set as NOINFO (if requested so), ERROR or 0
    ## }}}
    def check_raw_size_validity(self) -> None:  ## {{{
        '''helps decide which progress_info to display'''

        try:
            _ = int(self.file_raw_size)  ## make sure self.file_raw_size is an int
            _ = 1 / self.file_raw_size  ## make sure self.file_raw_size is not 0
            self.file_raw_size_validity = True
        except Exception:
            if 'ERROR' in str(self.file_raw_size):
                self.file_raw_size_invalidity_msg = 'ERROR'
            elif 'NOINFO' in str(self.file_raw_size):
                self.file_raw_size_invalidity_msg = 'NOINFO'
            elif 'ZeroDivisionError' in str(self.file_raw_size):
                self.file_raw_size_invalidity_msg = '0 raw size'
            else:
                self.file_raw_size_invalidity_msg = f'UNKNOWN: {self.file_raw_size}'

            self.file_raw_size_validity = False
    ## }}}
    def calculate_progress(self) -> None:  ## {{{
            self.progress_file_downloaded_raw += self.chunksize  ## JUMP_4
            self.progress_file_downloaded = convert_byte(self.progress_file_downloaded_raw)
            self.progress_file_downloaded_perc = (self.progress_file_downloaded_raw * 100) / self.file_raw_size

            ## FIXME <--,-- self.progress_file_downloaded_perc exceeds 100. what's more, adding if chunk:
            ##          '-- at JUMP_2 prevents it from reaching 100, so here's a dirty trick:
            if self.progress_file_downloaded_raw > self.file_raw_size:
                self.progress_file_downloaded = self.file_size
            if self.progress_file_downloaded_perc > 100:
                self.progress_file_downloaded_perc = 100
    ## }}}
    @duration_wrapper()
    def download(self) -> None:  ## {{{
        try:
            if not Ini.downloader:  ## {{{ uses urlopen

                if Ini.tor:
                    ## FIXME not tested if proxy really works for urlopen. Needs more tests.
                    ## https://stackoverflow.com/questions/3168171/how-can-i-open-a-website-with-urllib-via-proxy-in-python
                    ## https://stackoverflow.com/questions/34576665/setting-proxy-to-urllib-request-python3
                    proxy_support = ProxyHandler({'http': tor_proxy, 'https': tor_proxy})
                    proxy_opener = build_opener(proxy_support)
                    # install_opener(proxy_opener)
                    download_urlopen_response = proxy_opener.open(self.url)
                else:
                    download_urlopen_response = urlopen(self.url)

                with open(self.outputname, 'wb') as opened_outputname:
                    if self.file_raw_size_validity:
                        for chunk in iter(partial(download_urlopen_response.read, self.chunksize), b''):
                            ## JUMP_2
                            opened_outputname.write(chunk)
                            self.calculate_progress()
                            print(Col.purple(self.progress_info_dict), end=endpoint)
                    else:
                        for chunk in iter(partial(download_urlopen_response.read, self.chunksize), b''):
                            print(Col.orange(self.progress_info_error_dict), end=endpoint)
                            opened_outputname.write(chunk)
            ## }}}
            elif Ini.downloader == 'requests':  ## {{{
                if Ini.tor:
                    Ses.proxies = {'http': tor_proxy, 'https': tor_proxy}

                ## https://stackoverflow.com/questions/16694907/download-large-file-in-python-with-requests
                with Ses.get(self.url, headers=hdrs, timeout=20, stream=True) as opened_session:
                    opened_session.raise_for_status()

                    with open(self.outputname, 'wb') as opened_outputname:

                        if self.file_raw_size_validity:
                            for chunk in opened_session.iter_content(chunk_size=self.chunksize):
                                ## JUMP_2
                                opened_outputname.write(chunk)
                                self.calculate_progress()
                                print(Col.purple(self.progress_info_dict), end=endpoint)
                        else:
                            for chunk in opened_session.iter_content(chunk_size=self.chunksize):
                                print(Col.orange(self.progress_info_error_dict), end=endpoint)
                                opened_outputname.write(chunk)
            ## }}}
            elif Ini.downloader == 'wget':  ## {{{

                ## https://stackoverflow.com/questions/58125279/python-wget-module-doesnt-show-progress-bar
                ## https://www.itersdesktop.com/2020/09/06/downloading-files-in-python-using-wget-module/
                def wget_bar(progress_file_downloaded_raw, total=self.file_raw_size, width=80) -> None:  ## JUMP_5 FIXME can't use self.progress_file_downloaded_raw
                    self.progress_file_downloaded = convert_byte(progress_file_downloaded_raw)
                    self.progress_file_downloaded_perc = (progress_file_downloaded_raw /total) * 100
                    print(Col.purple(self.progress_info_dict), end=endpoint)

                ## FIXME doesn't show
                def wget_bar_error(progress_file_downloaded_raw, total=self.file_raw_size, width=80) -> None:  ## JUMP_5 FIXME can't use self.progress_file_downloaded_raw
                    print(Col.orange(self.progress_info_error_dict), end=endpoint)

                if Ini.tor:
                    ## FIXME find how to set proxy for wget
                    ## JUMP_6 FIXME it prompts for every url
                    continue_without_proxy = get_single_input('Setting tor for wget for o is not possible at the moment. Continue without proxy?')
                    if not continue_without_proxy == 'y':
                        exit()

                ## wget is able to get progress_file_downloaded_raw and self.file_raw_size on the go anyway, but it is better to respect the info already present
                if self.file_raw_size_validity:
                    wget_download(url=self.url, out=self.outputname, bar=wget_bar)
                else:
                    wget_download(url=self.url, out=self.outputname, bar=wget_bar_error)
            ## }}}
            elif Ini.downloader == 'curl':  ## {{{ http://pycurl.io/docs/latest/index.html
                ## examples: https://www.programcreek.com/python/example/1602/pycurl
                cc = Curl()  ## curl connection
                cc.setopt(cc.URL, self.url)
                cc.setopt(cc.CONNECTTIMEOUT, 20)
                cc.setopt(cc.USERAGENT, 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:8.0) Gecko/20100101 Firefox/8.0')  ## get_headers() or hdrs wouldn't work
                # cc.setopt(cc.TIMEOUT, 120)
                # cc.setopt(cc.FOLLOWLOCATION, True)  ## following redirects

                if Ini.tor:
                    cc.setopt(cc.PROXY, '127.0.0.1')
                    cc.setopt(cc.PROXYPORT, 9050)
                    cc.setopt(cc.PROXYTYPE, cc.PROXYTYPE_SOCKS5_HOSTNAME)  ## https://stackoverflow.com/questions/32396115/access-denied-to-a-website-using-tor
                    # cc.setopt(cc.PROXYTYPE, cc.PROXYTYPE_SOCKS5)  ## https://stackoverflow.com/questions/8252722/tor-with-pycurl-usage

                with open(self.outputname, 'wb') as opened_outputname:
                    ## TODO show progress bar
                    cc.setopt(cc.WRITEDATA, opened_outputname)
                    cc.perform()

                cc.close()
            ## }}}

            print()  ## to prevent the removal of progress_info
            self.should_break = True

        except Exception as exc:
            method_name = stack()[0][3]
            analyze(f'{exc!r}', nth_attempt=self.attempt, class_ins=Cur, caller=method_name)
    ## }}}
    @property
    def progress_info_dict(self) -> dict[str, str]:  ## {{{
        return {f'{self.progress_file_downloaded}/{self.file_size}': f'%{self.progress_file_downloaded_perc:.2f}'}
    ## }}}
    @property
    def progress_info_error_dict(self) -> dict[str, str]:  ## {{{
        return {'BAR ERROR MSG': self.file_raw_size_invalidity_msg}
    ## }}}
## }}}
@dataclass
class Youtube(Profile):  ## {{{
    ## {{{
    progress_status: str                = field(repr=False, default=None)
    progress_speed_raw: int             = field(repr=False, default=None)
    progress_speed: str                 = field(repr=False, default=None)
    progress_elapsed: int               = field(repr=False, default=None)
    progress_eta: int                   = field(repr=False, default=None)
    progress_video_raw_size: int        = field(repr=False, default=None)
    progress_video_size: str            = field(repr=False, default=None)
    progress_video_downloaded_raw: int  = field(repr=False, default=None)
    progress_video_downloaded: str      = field(repr=False, default=None)
    progress_video_downloaded_perc: int = field(repr=False, default=None)
    progress_info_error: str            = field(repr=False, default=None)

    video_title: str         = None
    video_uploader: str      = None
    video_channel: str       = None
    video_duration: int      = None
    video_view_count: int    = None
    video_like_count: int    = None
    video_ext: str           = None
    ## }}}
    def __post_init__(self):  ## {{{
        super().__init__()
        self.index_up()
    ## }}}
    def get_info(self, url) -> None:  ## {{{
        if Ini.increment:
            Ini.increment_prefix = f'{Ini.increment:03}-RNMD-'

        order = calculate_order()
        time = get_datetime('jhms')
        video_id = url.split('=')[1]  ## WpqCLcAXkJs

        options = {
            'proxy': tor_proxy,
            'no_color': True,  ## better be uncommented, otherwise analyze can't display error messages properly
            'skip_download': True,
            'logger': YoutubedlLoggerEmpty(),  ## because we don't need stdout/stderr when we are in get_info
        }

        if Ini.no_information:
            outputname = f'{Ini.increment_prefix}{video_id}'  ## 081-RNMD-WpqCLcAXkJs or WpqCLcAXkJs
            info = order, time, url, 'NOINFO', 'NOINFO', 'NOINFO', 'NOINFO', 'NOINFO', 'NOINFO', 'NOINFO', 'NOINFO', outputname
        else:
            for self.get_info_attempt in self.attempts:
                self.should_break = False

                try:
                    with YoutubeDL(options) as opened_youtubedl:
                        # opened_youtubedl.cache.remove()
                        video_obj = opened_youtubedl.extract_info(url, download=False)

                    video_title = video_obj['title']  ## '"Hide and Seek" l At Home With Olaf'
                    video_uploader = video_obj['uploader']  ## 'Walt Disney Animation Studios'
                    video_channel = video_obj['channel']  ## 'Walt Disney Animation Studios'
                    video_duration = video_obj['duration']  ## 41
                    video_duration = duration(video_duration)  ## 00:00:41
                    video_view_count = f'{video_obj["view_count"]:,d}'  ## 1,362,401
                    video_like_count = f'{video_obj["like_count"]:,d}'  ## 13,730
                    video_ext = video_obj['ext']  ## mp4

                    outputname = normalize(video_title)
                    outputname = f'{Ini.increment_prefix}{outputname}-{video_id}'

                    info = order, time, url, video_title, video_uploader, video_channel, video_duration, video_view_count, video_like_count, video_ext, outputname

                    self.should_break = True

                except Exception as exc:
                    outputname = f'{Ini.increment_prefix}{video_id}'  ## 081-RNMD-WpqCLcAXkJs or WpqCLcAXkJs

                    method_name = stack()[0][3]
                    analyze(f'{exc!r}', nth_attempt=self.get_info_attempt, class_ins=Cur, caller=method_name)
                    info = order, time, url, 'ERROR', 'ERROR', 'ERROR', 'ERROR', 'ERROR', 'ERROR', 'ERROR', 'ERROR', outputname

                if self.should_break:
                    break

        self.order, self.time, self.url, self.video_title, self.video_uploader, self.video_channel, self.video_duration, self.video_view_count, self.video_like_count, self.video_ext, self.outputname = info
    ## }}}
    @duration_wrapper()
    def download(self) -> None:  ## {{{
        ## useful links {{{
        ## https://stackoverflow.com/questions/18054500/how-to-use-youtube-dl-from-a-python-program
        ## https://github.com/ytdl-org/youtube-dl/blob/master/README.md#embedding-youtube-dl
        ## https://github.com/ytdl-org/youtube-dl/blob/3e4cedf9e8cd3157df2457df7274d0c842421945/youtube_dl/YoutubeDL.py#L137-L312 (available options)
        ## https://github.com/ytdl-org/youtube-dl/blob/master/youtube_dl/YoutubeDL.py#L128-L278 (available options)
        ## https://www.programcreek.com/python/example/98358/youtube_dl.YoutubeDL
        ## https://programtalk.com/python-examples/youtube_dl.YoutubeDL/
        ## https://codingdict.com/sources/py/youtube_dl/16491.html
        ## https://vimsky.com/zh-tw/examples/detail/python-method-youtube_dl.YoutubeDL.html
        ## }}}

        ## FIXME does not display for s and t
        ## https://stackoverflow.com/questions/23727943/how-to-get-information-from-youtube-dl-in-python
        def progress_hook(progress_response) -> None:
            self.progress_status = progress_response['status']
            ## try is used just to make sure nothing goes wrong
            try:
                ## we have to use the if statement, otherwise the progress_info_dict will be screwed
                ## when the exception swoops in with a message like {'ERROR MSG': "KeyError('speed')"}
                ## when download is finished because it has jumped to except down below
                if self.progress_status == 'downloading':
                    self.progress_speed_raw = progress_response['speed']
                    self.progress_speed = convert_byte(self.progress_speed_raw)

                    self.progress_elapsed = int(progress_response['elapsed'])
                    self.progress_elapsed = duration(self.progress_elapsed)

                    self.progress_eta = int(progress_response['eta'])
                    self.progress_eta = duration(self.progress_eta)

                    self.progress_video_raw_size = progress_response['total_bytes']
                    self.progress_video_size = convert_byte(self.progress_video_raw_size)

                    self.progress_video_downloaded_raw = progress_response['downloaded_bytes']
                    self.progress_video_downloaded = convert_byte(self.progress_video_downloaded_raw)

                    self.video_downloaded_percent = (self.progress_video_downloaded_raw * 100) / self.progress_video_raw_size

                    print(Col.purple(self.progress_info_dict), end=endpoint)
            except Exception as exc:
                self.progress_info_error = f'{exc!r}'
                print(Col.orange(self.progress_info_error_dict), end=endpoint)

        options = {
            # 'outtmpl': '%(title)s--%(width)sx%(height)s-f%(format_id)s.%(ext)s',
            'outtmpl': f'{self.outputname}.%(ext)s',
            'no_color': True,  ## better be uncommented, otherwise analyze can't display error messages properly
            'proxy': tor_proxy,
            'nooverwrites': True,
            'progress_hooks': [progress_hook],
            'logger': YoutubedlLoggerW(),
        }

        if not Ini.downloader:  ## uses youtube_dl
            pass
        elif Ini.downloader == 'curl':
            options = {**options, 'external_downloader': 'curl'}
        elif Ini.downloader and not Ini.downloader == 'curl':
            ## FIXME <--,-- currently wget and axel throw error and we're stuck with curl here
            ##          |-- so we should find out how to safely use wget or axel as downloader
            ##          |-- wget throws 'DownloadError('ERROR: wget exited with code 8')' for v, vs and a but works well for s and t
            ##          '-- axel throws 'DownloadError('ERROR: axel exited with code 1')' for v, vs and a but works well for s and t
            ## JUMP_6 FIXME it prompts for every url
            continue_with_default_downloader = get_single_input('Setting downloader other than curl for v/s/vs/a/t is not possible at the moment. Continue with default downloader (i.e. youtube_dl)?')
            if not continue_with_default_downloader == 'y':
                exit()

        langs = ['en', 'en-AU', 'en-CA', 'en-GB', 'en-IE', 'en-NZ', 'en-US']
        if   Ini.file_type == 'v':  options = {**options, 'format': Ini.quality}
        elif Ini.file_type == 's':  options = {**options, 'writesubtitles': True, 'writeautomaticsub': True, 'subtitleslangs': langs, 'skip_download': True}
        elif Ini.file_type == 'vs': options = {**options, 'writesubtitles': True, 'writeautomaticsub': True, 'subtitleslangs': langs, 'format': Ini.quality}
        elif Ini.file_type == 'a':  options = {**options, 'format': 'bestaudio', 'postprocessors': [{'key': 'FFmpegExtractAudio', 'preferredcodec': 'mp3'}]}
        elif Ini.file_type == 't':  options = {**options, 'write_all_thumbnails': True, 'writethumbnail': True, 'skip_download': True}

        try:
            with YoutubeDL(options) as opened_youtubedl:
                opened_youtubedl.download([self.url])
            print()  ## to prevent the removal of progress_info
            self.should_break = True
        except Exception as exc:
            method_name = stack()[0][3]
            analyze(f'{exc!r}', nth_attempt=self.attempt, class_ins=Cur, caller=method_name)
    ## }}}
    @property
    def progress_info_dict(self) -> dict[str, str]:  ## {{{
        return {
            f'{self.progress_video_downloaded}/{self.progress_video_size}': f'%{self.video_downloaded_percent:.2f}',
            'speed': self.progress_speed,
            'elapsed': self.progress_elapsed,
            'eta': self.progress_eta,
        }
    ## }}}
    @property
    def progress_info_error_dict(self) -> dict[str, str]:  ## {{{
        return {'BAR ERROR MSG': f'{self.progress_status} {self.progress_info_error}'}
    ## }}}
## }}}
@dataclass
class Playlist(Profile):  ## {{{
    ## {{{
    pl_fullinfo: dict[str, str] = field(repr=False, default_factory=dict)
    pl_urls: list[str]          = field(repr=False, default_factory=list)

    pl_title: str         = None
    pl_uploader: str      = None
    pl_entries: list[str] = field(repr=False, default_factory=list)
    pl_entries_count: int = None
    ## }}}
    def __post_init__(self):  ## {{{
        super().__init__()
    ## }}}
    def get_info(self) -> None:  ## {{{
        options = {
            'proxy': tor_proxy,
            'skip_download': True,
            'extract_flat': True,
            'dump_single_json': True,  ## why was previously 'dumpjson'?
            'logger': YoutubedlLoggerW(),
        }

        ## 'if Ini.no_information' is not needed here because it will actually make the whole process pointless!

        for self.get_info_attempt in self.attempts:
            self.should_break = False

            try:
                ## https://stackoverflow.com/questions/53288922/youtube-dl-dump-json-returning-different-extractor-output-for-playlist-when-ca
                with YoutubeDL(options) as opened_youtubedl:
                    self.pl_fullinfo = opened_youtubedl.extract_info(f'https://www.youtube.com/playlist?list={Ini.source}', download=False)  ## self.pl_fullinfo is a dict

                pl_title = self.pl_fullinfo['title']
                pl_uploader = self.pl_fullinfo['uploader']
                pl_entries = self.pl_fullinfo['entries']
                pl_entries_count = len(self.pl_fullinfo['entries'])

                ## add each entry['id'] to self.pl_urls to be later added to Ini.source in Initial.verify_args()
                for entry in pl_entries:
                    self.pl_urls.append(f'https://www.youtube.com/watch?v={entry["id"]}')

                info = pl_title, pl_uploader, pl_entries_count

                self.should_break = True

            except Exception as exc:
                method_name = stack()[0][3]
                analyze(f'{exc!r}', nth_attempt=self.get_info_attempt, class_ins=Pla, caller=method_name)
                info = 'ERROR', 'ERROR', 'ERROR'

            if self.should_break:
                break

        self.pl_title, self.pl_uploader, self.pl_entries_count = info
        ## }}}
## }}}
class YoutubedlLoggerW:  ## {{{
    '''logger for youtube_dl displaying warning messages'''

    @staticmethod
    def debug(log_msg) -> None:
        pass

    @staticmethod
    def warning(log_msg) -> None:
        ## we don't want to see warnings like 'en-AU subtitles not available for WpqCLcAXkJs' for s and vs
        if 'subtitles not available for' not in log_msg:
            savelog_print({'WARNING MSG': log_msg}, 'yellow')

    @staticmethod
    def error(log_msg) -> None:
        pass
## }}}
class YoutubedlLoggerEmpty:  ## {{{
    '''logger for youtube_dl displaying no messages'''

    @staticmethod
    def debug(log_msg) -> None:
        pass

    @staticmethod
    def warning(log_msg) -> None:
        pass

    @staticmethod
    def error(log_msg) -> None:
        pass
## }}}

if __name__ == '__main__':
    title = path.basename(__file__).replace('.py', '')
    tor_proxy = 'socks5://127.0.0.1:9050'
    script_args = argv[1:]
    endpoint = '\r'
    hdrs = get_headers()
    Ses = Session()
    Col = Color()
    Ini = Initial()

    Ini.total_duration = main()
    Ini.report()

## we can use these to analyze warnings in warning methods in YoutubedlLogger* classes {{{
# warnings = [
#     'Unable to download thumbnail "https://i.ytimg.com/vi_webp/f_bml-MILAs/maxresdefault.webp": <urlopen error EOF occurred in violation of protocol (_ssl.c:1129)>',
#     'Could not send HEAD request to https://www.youtube.com/watch?=vglU: <urlopen error [Errno 111] Connection refused>',
#     'Could not send HEAD request to https://www.youtube.com/watch?=vglU: HTTP Error 429: Too Many Requests',
#     'Unable to download webpage: <urlopen error [Errno 111] Connection refused>',
#     'Unable to download webpage: Remote end closed connection without response',
#     'Unable to download webpage: HTTP Error 429: Too Many Requests',
#     'Falling back on generic information extractor.',
# ]
## }}}
