#!/usr/bin/env python

## imports {{{
from __future__ import unicode_literals
from getopt import getopt
from glob import glob
from math import floor, pow, log
from os import path, mkdir, chdir, getenv
from pathlib import Path
from random import shuffle
from re import sub, match
from subprocess import run, check_output
from sys import argv
from typing import Dict, List

from requests import Session
from tabulate import tabulate
from wget import download as wget_download
from youtube_dl import YoutubeDL
from gp import Color, dorm, duration, duration_wrapper, fzf, get_datetime, get_input, get_single_input, invalid, separator, get_headers
## }}}
class File:  ## {{{
    def __init__(self, order: Dict[str, str]=[], current_time: int='', url: str='', size: str='', raw_size: int='', content_type: str='', last_modified: str='', outputname: str='', error: Dict[str, str]=[]):  ## {{{
        self.order         = order
        self.current_time  = current_time
        self.url           = url
        self.size          = size
        self.raw_size      = raw_size
        self.content_type  = content_type
        self.last_modified = last_modified
        self.outputname    = outputname
        self.error         = error
## }}}
    def get_info(self):  ## {{{
        global attempt, should_break, reason, raw_size

        ## get x-value
        if x_value:
            joined_x_value = f'{x_value:03}-RNMD-'
        else:
            joined_x_value = ''

        ## get outputname
        _, base = path.split(url)  ## 'https://www.davoudarsalani.ir/Files/Fun/', '001.jpg'
        root_base, ext = path.splitext(base)  ## '001', '.jpg'
        outputname = remove_special_characters(root_base)
        outputname = f'{joined_x_value}{outputname}{ext}'

        if torsocks:
            s.proxies = {'http': proxy, 'https': proxy}

        ## get size, type, last modified
        if ignore_information:
            raw_size, size, content_type, last_modified, error = ('IGNORED',)*4 + ({},)
        else:
            for attempt in attempts:
                should_break = False

                try:
                    response = s.head(url, headers=hdrs, timeout=20)
                    status_code = response.status_code  ## 200
                    headers = response.headers

                    content_type = headers.get('Content-Type', 'ERROR')    ##      <--, <--,-- if url (domain part) is misspelled, the file_type will be automatically assigned 'ERROR' in except
                    last_modified = headers.get('Last-Modified', 'ERROR')  ##      <--|    |-- but if url (file name part) is misspelled, the file_type will always be 'text/html; charset=UTF-8'
                    raw_size = int(headers.get('Content-Length', 0))       ## <--, <--|    '-- no matter what the real file type is
                    error = {}                                             ##    |    |-- exceptionally used get because the key is not always there
                                                                           ##    |    '-- ## TODO make these case insensitive, or are they already? [14000223000000]
                                                                           ##    |-- it is made global because
                                                                           ##    |-- it is also used in download for o to show percentage
                                                                           ##    '-- NOTE: any change you make to this, make sure to check there too for possible screw-ups
                    size = convert_byte(raw_size)
                    should_break = True

                except Exception as exc:
                    analyze(f'{exc!r}', caller='get_info')
                    raw_size, size, content_type, last_modified, error = ('ERROR',)*4 + ({'ERROR': reason},)

                if should_break:
                    break

        return size, raw_size, content_type, last_modified, outputname, error
## }}}
    @property
    def info_dict(self):  ## {{{
        allinfo = {**self.order, 'time': self.current_time, 'url': self.url, 'size': self.size, 'type': self.content_type, 'last modified': self.last_modified, 'outputname': self.outputname, **self.error}
        return allinfo
## }}}
## }}}
class Video:  ## {{{
    def __init__(self, order: Dict[str, str]=[], current_time: int='', url: str='', title: str='', uploader: str='', channel: str='', dur: str='', view_count: int='', like_count: int='', dislike_count: int='', ext: str='', outputname: str='', error: Dict[str, str]=[]):  ## {{{
        self.order         = order
        self.current_time  = current_time
        self.url           = url
        self.title         = title
        self.uploader      = uploader
        self.channel       = channel
        self.dur           = dur
        self.view_count    = view_count
        self.like_count    = like_count
        self.dislike_count = dislike_count
        self.ext           = ext
        self.outputname    = outputname
        self.error         = error
## }}}
    def get_info(self):  ## {{{
        global x_value, attempt, should_break

        if x_value:
            joined_x_value = f'{x_value:03}-RNMD-'
        else:
            joined_x_value = ''

        video_id = url.split('=')[-1]  ## WpqCLcAXkJs

        options = {
            'proxy': proxy,
            'no_color': True,
            'skip_download': True,
            'logger': Ydl_Empty_Logger(),  ## because we don't need stdout/stderr when getting info
        }

        if ignore_information:
            outputname = f'{joined_x_value}{video_id}'  ## 081-RNMD-WpqCLcAXkJs or WpqCLcAXkJs
            title, uploader, channel, dur, view_count, like_count, dislike_count, ext, error = ('IGNORED',)*8 + ({},)
        else:
            for attempt in attempts:
                should_break = False

                try:
                    with YoutubeDL(options) as Y_DL:
                        # Y_DL.cache.remove()
                        obj = Y_DL.extract_info(url, download=False)

                    title = obj['title']  ## '"Hide and Seek" l At Home With Olaf'
                    uploader = obj['uploader']  ## 'Walt Disney Animation Studios'
                    channel = obj['channel']  ## 'Walt Disney Animation Studios'
                    dur = obj['duration']  ## 41
                    dur = duration(dur)  ## 00:00:41
                    view_count = f'{obj["view_count"]:,d}'  ## 1,362,401
                    like_count = f'{obj["like_count"]:,d}'  ## 13,730
                    dislike_count = f'{obj["dislike_count"]:,d}'  ## 2,416
                    ext = obj['ext']  ## mp4

                    outputname = remove_special_characters(title)
                    outputname = f'{joined_x_value}{outputname}'

                    error = {}
                    should_break = True

                except Exception as exc:
                    outputname = f'{joined_x_value}{video_id}'  ## 081-RNMD-WpqCLcAXkJs or WpqCLcAXkJs

                    analyze(f'{exc!r}', caller='get_info')
                    title, uploader, channel, dur, view_count, like_count, dislike_count, ext, error = ('ERROR',)*8 + ({'ERROR': reason},)

                if should_break:
                    break

        return title, uploader, channel, dur, view_count, like_count, dislike_count, ext, outputname, error
## }}}
    @property
    def info_dict(self):  ## {{{
        allinfo = {**self.order, 'time': self.current_time, 'url': self.url, 'title': self.title, 'uploader': self.uploader, 'channel': self.channel, 'duration': self.dur, 'views': self.view_count, 'likes': self.like_count, 'dislikes': self.dislike_count, 'ext': self.ext, 'outputname': self.outputname, **self.error}
        return allinfo
## }}}
## }}}
class Ydl_W_Logger(object):  ## {{{
    '''logger for youtube_dl displaying warning messages'''

    def debug(self, msg):
        pass

    def warning(self, msg):
        ## we don't want to see warnings like 'en-AU subtitles not available for WpqCLcAXkJs' for s and vs
        if not 'subtitles not available for' in msg:
            append_to_log(str({'WARNING': msg})+'\n')
            print(Color().yellow_dim({'WARNING': msg}))

    def error(self, msg):
        pass
## }}}
class Ydl_DW_Logger(object):  ## {{{
    '''logger for youtube_dl displaying debug and warning messages'''

    def debug(self, msg):
        append_to_log(f'{msg}\n')
        print(msg)

    def warning(self, msg):
        ## we don't want to see warnings like 'en-AU subtitles not available for WpqCLcAXkJs' for s and vs
        if not 'subtitles not available for' in msg:
            append_to_log(str({'WARNING': msg})+'\n')
            print(Color().yellow_dim({'WARNING': msg}))

    def error(self, msg):
        pass
## }}}
class Ydl_Empty_Logger(object):  ## {{{
    '''logger for youtube_dl displaying no messages'''

    def debug(self, msg):
        pass

    def warning(self, msg):
        pass

    def error(self, msg):
        pass

## }}}
def help():  ## {{{
    run('clear', shell=True)
    print(f'''{Color().heading(f'{title}')} {Color().yellow('Help')}
single  {Color().flag(f'-f --file-type=')}v/s/vs/a/t/o
        {Color().flag(f'-v --video-quality=')}e.g. 22, best, etc
        {Color().flag(f'-u --url=')}
        {Color().flag(f'-d --downloader')}
        {Color().flag(f'-t --torsocks')}
        {Color().flag(f'-i --ignore-information')}
        {Color().flag(f'-c --complete-error')}

bulk    {Color().flag(f'-w --when=')}n/h
        {Color().flag(f'-f --file-type=')}v/s/vs/a/t/o
        {Color().flag(f'-v --video-quality=')}e.g. 22, best, etc
        {Color().flag(f'-s --source-file=')}
        {Color().flag(f'-x --x-value=')}
        {Color().flag(f'-d --downloader')}
        {Color().flag(f'-t --torsocks')}
        {Color().flag(f'-i --ignore-information')}
        {Color().flag(f'-c --complete-error')}

get youtube playlist urls  {Color().flag(f'-p --playlist-id=')}e.g. PL-osiE80TeTt2d9bfVyTiXJA-UTHn6WwU
                           {Color().flag(f'-o --output-file=')}
                           {Color().flag(f'-c --complete-error')}

video available formats  {Color().flag(f'-u --url=')}
                         {Color().flag(f'-i --ignore-information')}
                         {Color().flag(f'-c --complete-error')}''')
    exit()
## }}}
def getopts():  ## {{{
    global main_args, x_value, downloader, torsocks, ignore_information, complete_error
    main_args, x_value, downloader, torsocks, ignore_information, complete_error = ({},) + (None,) + (False,)*4

    try:
        duos, duos_long = getopt(
                              script_args,
                              'hw:f:v:u:s:x:p:o:dtic',
                              ['help',
                               'when=',
                               'file-type=',
                               'video-quality=',
                               'url=',
                               'source-file=',
                               'x-value=',
                               'playlist-id=',
                               'output-file=',
                               'downloader',
                               'torsocks',
                               'ignore-information',
                               'complete-error']
                          )
        for opt, arg in duos:
            if   opt in ('-h', '--help'):               help()
            elif opt in ('-w', '--when'):               main_args['when'] = arg
            elif opt in ('-f', '--file-type'):          main_args['file-type'] = arg
            elif opt in ('-v', '--video-quality'):      main_args['video-quality'] = arg
            elif opt in ('-u', '--url'):                main_args['url'] = arg
            elif opt in ('-s', '--source-file'):        main_args['source-file'] = arg
            elif opt in ('-p', '--playlist-id'):        main_args['playlist-id'] = arg
            elif opt in ('-o', '--output-file'):        main_args['output-file'] = arg
            elif opt in ('-x', '--x-value'):            main_args['x-value'] = arg
            elif opt in ('-d', '--downloader'):         main_args['downloader'] = True
            elif opt in ('-t', '--torsocks'):           main_args['torsocks'] = True
            elif opt in ('-i', '--ignore-information'): main_args['ignore-information'] = True
            elif opt in ('-c', '--complete-error'):     main_args['complete-error'] = True
    except Exception as exc:
        reason = f'{exc!r}'
        invalid({'GETOPTS ERROR': reason})
## }}}
def prompt(*args: str):  ## {{{
    global when, file_type, video_quality, url, source_file, playlist_id, output_file, x_value, downloader, torsocks, ignore_information, complete_error
    global main_args, display_args, urls, dest_dir

    for arg in args:
        if arg == '-w':
            when = main_args.get('when')
            if not when: when = get_single_input('When (n/h)')
            if when not in ['n', 'h']: invalid('Invalid time')
            display_args['when'] = when

        elif arg == '-f':
            file_type = main_args.get('file-type')
            if not file_type: file_type = get_input('File type (v/s/vs/a/t/o)')
            if file_type not in ['v', 's', 'vs', 'a', 't', 'o']: invalid('Invalid file type')

            if file_type in ['v', 'vs']: prompt('-v')
            elif file_type == 'o': prompt('-t')

            # ## we may need downloader only for youtube_dl
            # if file_type in ['v', 's', 'vs', 'a', 't']:
            #     prompt('-d')

            display_args['file-type'] = file_type

        elif arg == '-v':
            video_quality = main_args.get('video-quality')
            if not video_quality: video_quality = get_input('Video quality (e.g. 22, best, etc)')
            display_args['video-quality'] = video_quality

        elif arg == '-u':
            url = main_args.get('url')
            if not url: url = get_input('URL')
            display_args['url'] = url

        elif arg == '-s':
            source_file = main_args.get('source-file')
            if not source_file: source_file = get_input('Source file')
            ## check if source_file exists
            if not path.exists(source_file): invalid('No such file')
            ## check if source_file is a directory
            if path.isdir(source_file): invalid('Source file cannot be a directory')

            ## create urls list from source_file
            with open(source_file, 'r') as SOURCE_FILE:
                lines = SOURCE_FILE.read().splitlines()
            urls = list(filter(lambda line:not line.startswith('#'), lines))  ## OR: [line for line in lines if not line.startswith('#')]
            if not urls:
                invalid('Source file contains no downloadable urls')

            root_base, ext = path.splitext(source_file)
            dest_dir = root_base
            dest_dir = if_exists(dest_dir)

            display_args['source-file'] = sub(getenv('HOME'), '~', source_file)
            display_args['destination-directory'] = sub(getenv('HOME'), '~', dest_dir)

        elif arg == '-p':
            playlist_id = main_args.get('playlist-id')
            if not playlist_id: playlist_id = get_input('Playlist id (e.g. PL-osiE80TeTt2d9bfVyTiXJA-UTHn6WwU)')
            display_args['playlist-id'] = playlist_id

        elif arg == '-o':
            output_file = main_args.get('output-file')
            if not output_file: output_file = get_input('Output file')
            output_file = if_exists(output_file)
            display_args['output-file'] = sub(getenv('HOME'), '~', output_file)

        elif arg == '-x':
            x_value = main_args.get('x-value', None)
            if x_value:
                try:              x_value = int(x_value)
                except Exception: invalid('x-value should be a number')
                display_args['x-value'] = x_value

        elif arg == '-d':
            downloader = main_args.get('downloader', False)
            if downloader: display_args['downloader'] = downloader

        elif arg == '-t':
            torsocks = main_args.get('torsocks', False)
            if torsocks: display_args['torsocks'] = torsocks

        elif arg == '-i':
            ignore_information = main_args.get('ignore-information', False)
            if ignore_information: display_args['ignore-information'] = ignore_information

        elif arg == '-c':
            complete_error = main_args.get('complete-error', False)
            if complete_error: display_args['complete-error'] = complete_error
## }}}
def convert_byte(size_in_bytes):  ## {{{ https://stackoverflow.com/questions/5194057/better-way-to-convert-file-sizes-in-python
    if size_in_bytes == 0:
        return '00B'

    suff = ('B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB')
    i = int(floor(log(size_in_bytes, 1024)))
    p = pow(1024, i)
    conv = f'{float(size_in_bytes / p):.2f}'

    return f'{conv}{suff[i]}'
## }}}
def check_to_start():  ## {{{
    current_time = int(get_datetime('jhms'))
    start_permission = current_time > 21000 and current_time < 63000

    return start_permission
## }}}
def check_to_exit():  ## {{{
    current_time = int(get_datetime('jhms'))
    exit_permission = current_time > 63000

    return exit_permission
## }}}
def if_exists(dest):  ## {{{
    append_index = 2
    if path.exists(dest):
        while path.exists(f'{dest}_{append_index:02}'):
            append_index += 1
        dest = f'{dest}_{append_index:02}'

    return dest
## }}}
def restart_tor():  ## {{{
    ## sometimes tor is restarted just because error is unknown although torsocks was not passed for o
    ## so we need the if statement here:
    if torsocks or file_type in ['v', 's', 'vs', 'a', 't']:
        if path.exists('/bin/pacman'):
            run('sudo systemctl restart tor', shell=True)
        elif path.exists('/bin/apt'):
            run('sudo service tor restart', shell=True)
        else:
            print(Color().red({'ERROR': 'TOR not restarted (unknown OS)'}))
            return

        dorm(15)
## }}}
def draw_table(rows: List[str], header: List[str]=[]):  ## {{{
    table = tabulate(rows, headers=header, tablefmt='grid')

    return table
## }}}
def dest_dir_size():  ## {{{
    root_directory = Path(dest_dir)
    dir_raw_size = sum(file.stat().st_size for file in root_directory.glob('**/*'))
    return dir_raw_size
## }}}
def append_to_log(text: str):  ## {{{
    ## some methods in Ydl_*_Logger classes are instructed to append_to_log
    ## but log_file is present only in bulk mode, so we need try here
    try:
        log_file
        with open(log_file, 'a') as LOG_FILE:
            LOG_FILE.write(text)
    except Exception:
        pass
## }}}
def analyze(cmd_stderr: str, caller: str=''):  ## {{{
    global reason, should_break, video_quality, failed_sites, order, url, attempt, downloader

    should_restart_tor = False

    conditions = [
        'ERROR' not in cmd_stderr,
        'Error' not in cmd_stderr,
        'WARNING' not in cmd_stderr,
        'Could not resolve host' not in cmd_stderr,
        'Unable to connect to server' not in cmd_stderr,
        'unable to resolve host address' not in cmd_stderr
    ]
    no_errors = all(conditions)

    if no_errors:
        should_break = True
        return

    ## possible errors (i.e. keys) and what we should do (i.e. values) if they happen
    errors = {

        ## <<< mainly happening in youtube-dl >>>

        'No video formats found':            '',  ## 'break' not necessary because it was seen to be running ok in the next attempt
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


        ## <<< mainly happening in youtube_dl and wget modules >>>

        'Connection refused': 'break',
        ## happened when tor is off
        ## Full: Unable to download webpage: <urlopen error [Errno 111] Connection refused>

        'ConnectionError': 'break',
        ## happened for o when url (domain part) is misspelled (e.g. https://www.davoni.ir/Files/Fun/002.jpg)
        ## Full: ConnectionError(MaxRetryError("HTTPSConnectionPool(host=\'www.davoni.ir\', port=443): Max retries exceeded with url: /Files/Fun/002.jp
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
        ## happened for o when url (file name part) is misspelled (e.g. https://www.davoudarsalani.ir/Files/Fun/002.jp)
        ## Full: HTTPError('404 Client Error: Not Found for url: https://www.davoudarsalani.ir/Files/Fun/002.jp')
        ##
        ## happened for o when url is censored
        ## Full: HTTPError('403 Client Error: Forbidden for url: http://open.live.bbc.co.uk/p09cn7sc.mp3')

        'IndexError': 'break',
        ## happened for Video.get_info() when url is misspelled (e.g. it's incomplete) private and can't get info, and therefore 'items' list is empty
        ## Full: IndexError('list index out of range')

        'URLError': 'break',
        ## happened for File.get_info() when url is censored
        ## Full: URLError(ConnectionResetError(104, 'Connection reset by peer'))
        ##
        ## happened for File.get_info() with wget module when url (domain part) is missplelled (e.g. https://www.davoni.ir/Files/Fun/002.jpg)
        ## Full: URLError(gaierror(-2, 'Name or service not known'))

        'ExtractorError': 'break',
        ## Full: ExtractorError('No video formats found')

        'RegexNotFoundError': 'break',
        ## Full: RegexNotFoundError('Unable to extract Initial JS player signature function name; please report this issue on https://yt-dl.org/bug .
        ##       Make sure you are using the latest version; type  youtube-dl -U  to update. Be sure to call youtube-dl with the --verbose flag
        ##       and include its complete output.',)); please report this issue on https://yt-dl.org/bug . Make sure you are using the latest version;
        ##       type  youtube-dl -U  to update. Be sure to call youtube-dl with the --verbose flag and include its complete output.


        ## <<< happening in error files (i.e. error files of bwu, weather, etc. in $HOME/scripts/.last directory) just to add more examples >>>

        'AttributeError':           'break',  ## Full: AttributeError("'NoneType' object has no attribute 'text'")
        'OSError':                  'break',  ## Full: OSError(101, 'Network is unreachable')
        'ReadTimeout':              'break',  ## Full: ReadTimeout(ReadTimeoutError("HTTPSConnectionPool(host='api.openweathermap.org', port=443): Read timed out. (read timeout=20)"))
        'ServerNotFoundError':      'break',  ## Full: ServerNotFoundError('Unable to find the server at youtube.googleapis.com')
        'SSLCertVerificationError': 'break',  ## Full: SSLCertVerificationError(1, '[SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: self signed certificate in certificate chain (_ssl.c:1123)')
        'SSLEOFError':              'break',  ## Full: SSLEOFError(8, 'EOF occurred in violation of protocol (_ssl.c:1123)')
        'SSLError':                 'break',  ## Full: SSLError(MaxRetryError("HTTPSConnectionPool(host='<ADDR>', port=443): Max retries exceeded with url: <ADDR> (Caused by SSLError(SSLCertVerificationError(1, '[SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: self signed certificate in certificate chain (_ssl.c:1123)')))"))
        'TypeError':                'break',  ## Full: TypeError('Missing required parameter "part"')
        'TimeoutError':             'break',  ## Full: TimeoutError(110, 'Connection timed out')
        'timeout':                  'break',  ## Full: <--,-- timeout('_ssl.c:1112: The handshake operation timed out')
                                              ##          '-- timeout('timed out')
    }

    if attempt < len(attempts):
        for err_key, err_value in errors.items():
            if err_key in cmd_stderr:
                if complete_error:
                    reason = cmd_stderr
                else:
                    reason = err_key
                if err_value == 'break':
                    should_break = True
                elif err_value == 'restart':
                    should_restart_tor = True
                elif err_value == 'best':
                    video_quality = 'best'
                break
            else:
                reason = f'UNKNOWN: {cmd_stderr}'
                should_restart_tor = True
    elif attempt == len(attempts):
        reason = f'Failed after {attempt} attempts. Last error: {cmd_stderr}'
        should_break = True  ## this is the last attempt and the loop will automatically break anyawy, but it is needed here for the url to be added to failed_sites

    ## now let's see what we should do
    if caller == 'bulk':
        append_to_log(str({'ERROR': reason})+'\n')
        if should_break:
            failed_sites.append({**order, 'url': url, 'ERROR': reason})

    ## print error
    if not caller == 'get_info':
        print(Color().red({'ERROR': reason}))

    if should_restart_tor:
        restart_tor()
## }}}
def remove_special_characters(text: str):  ## {{{
    edited_text = text.lower()
    edited_text = sub(r' ', r'-', edited_text)
    edited_text = sub(r'[!@#$%^&*()_+={}\[\]\|\\;\':\",.<>/?`~]', r'', edited_text)  ## - and . are intentionally excluded. If you want to include -, it should be included as \-

    edited_text = sub(r'---', r'-', edited_text)
    edited_text = sub(r'--', r'-', edited_text)

    return edited_text
## }}}
def get_youtube_playlist_urls():  ## {{{
    global attempt, should_break

    prompt('-p', '-o', '-c')

    print(Color().white_dim(display_args))
    print()

    options = {
        'proxy': proxy,
        'skip_download': True,
        'extract_flat': True,
        'dumpjson': True,
        'logger': Ydl_W_Logger(),
    }

    playlist_url = f'https://www.youtube.com/playlist?list={playlist_id}'

    for attempt in attempts:
        should_break = False

        if attempt > 1:
            attempt_message = {'attempt': attempt}
            print(Color().blue(attempt_message))

        try:
            ## https://stackoverflow.com/questions/53288922/youtube-dl-dump-json-returning-different-extractor-output-for-playlist-when-ca
            with YoutubeDL(options) as Y_DL:
                response = Y_DL.extract_info(playlist_url, download=False)

            entries = response['entries']
            count = len(entries)

            for indx, entry in enumerate(entries, start=1):
                video_id = entry['id']
                video_title = entry['title']
                video_dur = entry['duration']  ## 500.0
                video_uploader = entry['uploader']
                text = f'## {indx}/{count}   Duration: {duration(video_dur)}   Title: {video_title}\nhttps://www.youtube.com/watch?v={video_id}'

                with open(output_file, 'a') as OUTPUT_FILE:
                    OUTPUT_FILE.write(f'{text}\n')

            should_break = True
        except Exception as exc:
            analyze(f'{exc!r}')

        if should_break:
            break
## }}}
def video_available_formats():  ## {{{
    global attempt, should_break

    prompt('-u', '-i', '-c')

    print(Color().white_dim(display_args))
    print()

    order = {}
    title, uploader, channel, dur, view_count, like_count, dislike_count, ext, outputname, error = Video().get_info()
    current = Video(order, get_datetime('jhms'), url, title, uploader, channel, dur, view_count, like_count, dislike_count, ext, outputname, error)

    for attempt in attempts:
        should_break = False

        if attempt == 1:
            attempt_message = current.info_dict
        else:
            attempt_message = {'attempt': attempt}
        print(Color().blue(attempt_message))

        options = {
            'no_color': True,  ## better be uncommented, otherwise analyze can't read error messages properly
            'proxy': proxy,
            'skip_download': True,
            'listformats': True,
            'logger': Ydl_DW_Logger(),
        }

        try:
            with YoutubeDL(options) as Y_DL:
                Y_DL.download([url])
            should_break = True
        except Exception as exc:
            analyze(f'{exc!r}', caller='video_available_formats')

        if should_break:
            break
## }}}
@duration_wrapper()
def download(caller: str):  ## {{{
    global should_break

    if   file_type in ['v', 's', 'vs', 'a', 't']:  ## {{{
        ## useful links {{{
        ## https://stackoverflow.com/questions/18054500/how-to-use-youtube-dl-from-a-python-program
        ## https://github.com/ytdl-org/youtube-dl/blob/master/README.md#embedding-youtube-dl
        ## https://github.com/ytdl-org/youtube-dl/blob/3e4cedf9e8cd3157df2457df7274d0c842421945/youtube_dl/YoutubeDL.py#L137-L312 (available options)
        ## https://github.com/ytdl-org/youtube-dl/blob/master/youtube_dl/YoutubeDL.py#L128-L278 (available options)
        ## https://www.programcreek.com/python/example/98358/youtube_dl.YoutubeDL
        ## }}}

        ## FIXME does not display for s and t [14000223000000]
        def hook(response):  ## https://stackoverflow.com/questions/23727943/how-to-get-information-from-youtube-dl-in-python
            status = response['status']
            ## try is used just to make sure nothing goes wrong
            try:
                ## we have to use the if statement and drop else and finally
                ## otherwise the download_info will be screwed when the exception swoops
                ## with a message like {'ERROR': "KeyError('speed')"} when download is finished
                if status == 'downloading':
                    speed = response['speed']
                    speed = convert_byte(speed)

                    elapsed = response['elapsed']
                    elapsed = duration(int(elapsed))

                    eta = response['eta']
                    eta = duration(int(eta))

                    total_bytes = response['total_bytes']
                    total_conv  = convert_byte(total_bytes)

                    downloaded_bytes = response['downloaded_bytes']
                    downloaded_conv  = convert_byte(downloaded_bytes)

                    downloaded_percent = (downloaded_bytes*100)/total_bytes

                    download_info = {f'{downloaded_conv}/{total_conv}': f'%{downloaded_percent:.2f}', 'speed': speed, 'elapsed': elapsed, 'ETA': eta}
                    print(Color().purple_dim(download_info), end='\r')
            except Exception as exc:
                ## TODO analyze erros locally, like the one we do for o down below. We just need more examples of exc to use in analyze [14000223000000]
                download_info = {'ERROR': f'{status} {exc!r}'}

        options = {
            # 'outtmpl': '%(title)s--%(width)sx%(height)s-f%(format_id)s.%(ext)s',
            'outtmpl': f'{outputname}.%(ext)s',
            'no_color': True,  ## better be uncommented, otherwise analyze can't display error messages properly
            'proxy': proxy,
            'nooverwrites': True,
            'progress_hooks': [hook],
            'logger': Ydl_W_Logger(),
        }

        if downloader:
            options = {**options, 'external_downloader': 'curl'}  ## <--,-- wget throws DownloadError('ERROR: wget exited with code 8') for v, vs and a but wrorks well for s and t
                                                                  ##    '-- axel throws DownloadError('ERROR: axel exited with code 1') for v, vs and a but wrorks well for s and t

        langs = ['en', 'en-AU', 'en-CA', 'en-GB', 'en-IE', 'en-NZ', 'en-US']
        if   file_type == 'v':  options = {**options, 'format': video_quality}
        elif file_type == 's':  options = {**options, 'writesubtitles': True, 'writeautomaticsub': True, 'subtitleslangs': langs, 'skip_download': True}
        elif file_type == 'vs': options = {**options, 'writesubtitles': True, 'writeautomaticsub': True, 'subtitleslangs': langs, 'format': video_quality}
        elif file_type == 'a':  options = {**options, 'format': 'bestaudio', 'postprocessors': [{'key': 'FFmpegExtractAudio', 'preferredcodec': 'mp3'}]}
        elif file_type == 't':  options = {**options, 'write_all_thumbnails': True, 'writethumbnail': True, 'skip_download': True}

        try:
            with YoutubeDL(options) as Y_DL:
                Y_DL.download([url])
            print()  ## to prevent the removal of download_info
            should_break = True
        except Exception as exc:
            analyze(f'{exc!r}', caller=caller)
    ## }}}
    elif file_type == 'o':  ## {{{

        def check_raw_size_validity():
            global total_bytes
            total_bytes = int(raw_size)  ## make sure raw_size is an int
            _ = 1 / raw_size  ## make sure raw_size is not 0

        def analyze_locally(local_cmd_stderr: str):
            '''it is called "local" because it is meant for within download function o section only'''

            # global reason
            if 'ERROR' in local_cmd_stderr:
                reason = 'ERROR'
            elif 'IGNORED' in local_cmd_stderr:
                reason = 'IGNORED'
            elif 'ZeroDivisionError' in local_cmd_stderr:
                reason = '0 raw size'
            else:
                reason = f'UNKNOWN: {local_cmd_stderr}'

            print(Color().orange({'BAR ERROR': reason}))

        try:
            if downloader:
                def wget_bar(downloaded, total_bytes, width=80):  ## https://www.itersdesktop.com/2020/09/06/downloading-files-in-python-using-wget-module/
                    downloaded_perc = downloaded/total_bytes*100
                    downloaded_conv = convert_byte(downloaded)
                    total_conv = convert_byte(total_bytes)
                    download_info = {f'{downloaded_conv}/{total_conv}': f'%{downloaded_perc:.2f}'}
                    print(Color().purple_dim(download_info), end='\r')

                if torsocks:
                    ## FIXME find how to set proxy for wget [14000314155813]
                    continue_without_proxy = get_single_input('Setting torsocks for downloader for o is not possible at the moment. Continue without proxy?')
                    if not continue_without_proxy == 'y':
                        exit()

                ## File.get_info() may send raw_size as IGNORED (if requested so), ERROR or 0, therefore try is needed here
                ## wget is able to get downloaded and total_bytes on the go anyway, but it is better to respct the info already present
                try:
                    check_raw_size_validity()
                    wget_download(url=url, out=outputname, bar=wget_bar)
                except Exception as exc:
                    analyze_locally(f'{exc!r}')
                    wget_download(url=url, out=outputname) #, bar=wget_error_bar)

            else:
                if torsocks:
                    s.proxies = {'http': proxy, 'https': proxy}

                ## https://stackoverflow.com/questions/16694907/download-large-file-in-python-with-requests
                with s.get(url, headers=hdrs, timeout=20, stream=True) as SESSION:
                    SESSION.raise_for_status()

                    with open(outputname, 'wb') as OUTPUTNAME:
                        chunksize = 8192  ## 8192 is 8KB
                        downloaded_bytes = 0

                        ## File.get_info() may send raw_size as IGNORED (if requested so), ERROR or 0, therefore try is needed here
                        try:
                            check_raw_size_validity()
                            total_conv = convert_byte(total_bytes)
                            for chunk in SESSION.iter_content(chunk_size=chunksize):
                                OUTPUTNAME.write(chunk)
                                downloaded_bytes += chunksize
                                downloaded_conv = convert_byte(downloaded_bytes)
                                downloaded_percent = (downloaded_bytes*100)/total_bytes  ## FIXME <--,-- exceeds 100 [14000223000000]
                                                                                         ##          |-- also, adding if chunk: before OUTPUTNAME.write(chunk)
                                                                                         ##          '-- prevents downloaded_percent from reaching 100

                                download_info = {f'{downloaded_conv}/{total_conv}': f'%{downloaded_percent:.2f}'}
                                print(Color().purple_dim(download_info), end='\r')  ## we can't move this line to finally because bytes are written chunk by chunk
                        except Exception as exc:
                            analyze_locally(f'{exc!r}')

                            for chunk in SESSION.iter_content(chunk_size=chunksize):
                                OUTPUTNAME.write(chunk)

            print()  ## to prevent the removal of download_info
            should_break = True

        except Exception as exc:
            analyze(f'{exc!r}', caller=caller)
    ## }}}
## }}}
@duration_wrapper()
def single():  ## {{{
    global outputname, attempt, should_break

    prompt('-f', '-u', '-d', '-i', '-c')

    order = {}
    if   file_type in ['v', 's', 'vs', 'a', 't']:
        title, uploader, channel, dur, view_count, like_count, dislike_count, ext, outputname, error = Video().get_info()
        current = Video(order, get_datetime('jhms'), url, title, uploader, channel, dur, view_count, like_count, dislike_count, ext, outputname, error)
    elif file_type == 'o':
        size, raw_size, content_type, last_modified, outputname, error = File().get_info()
        current = File(order, get_datetime('jhms'), url, size, raw_size, content_type, last_modified, outputname, error)

    outputname = f'{hnd}/{outputname}'
    outputname = if_exists(outputname)
    current.outputname = sub(getenv('HOME'), '~', outputname)

    print(Color().white_dim(display_args))
    print()

    for attempt in attempts:
        should_break = False

        if attempt == 1:
            attempt_message = current.info_dict
        else:
            attempt_message = {'attempt': attempt}
        print(Color().blue(attempt_message))

        download(caller='single')

        if should_break:
            break
## }}}
@duration_wrapper()
def bulk():  ## {{{
    global dest_dir, log_file, outputname, failed_sites, order, should_break, attempt, urls, url, x_value

    failed_sites = []

    prompt('-w', '-f', '-s', '-x', '-d', '-i', '-c')

    mkdir(dest_dir)
    chdir(dest_dir)

    log_file = f'{dest_dir}/log'

    append_to_log(str(display_args)+'\n\n')
    print(Color().white_dim(display_args))

    print()

    while True:
        permission = check_to_start()
        if when == 'h' and not permission:
            ## not yet
            append_to_log(str({'time': get_datetime('jhms')})+'\n')
            print(Color().brown({'time': get_datetime('jhms')}))
            dorm(60)
        else:
            for url in urls:

                urls_length = len(urls)
                nth = urls.index(url)+1
                perc = int(nth*100/urls_length)
                order = {f'{nth}/{urls_length}': f'%{perc}'}

                if   file_type in ['v', 's', 'vs', 'a', 't']:
                    title, uploader, channel, dur, view_count, like_count, dislike_count, ext, outputname, error = Video().get_info()
                    current = Video(order, get_datetime('jhms'), url, title, uploader, channel, dur, view_count, like_count, dislike_count, ext, outputname, error)
                elif file_type == 'o':
                    size, raw_size, content_type, last_modified, outputname, error = File().get_info()
                    current = File(order, get_datetime('jhms'), url, size, raw_size, content_type, last_modified, outputname, error)

                outputname = f'{dest_dir}/{outputname}'
                current.outputname = sub(getenv('HOME'), '~', outputname)

                for attempt in attempts:
                    should_break = False

                    should_exit = check_to_exit()
                    if when == 'h' and should_exit:
                        append_to_log('\nHappy hours over. Exit.\n')
                        print('\nHappy hours over. Exit.')
                        exit()

                    if attempt == 1:
                        attempt_message = current.info_dict
                    else:
                        attempt_message = {'attempt': attempt}
                    append_to_log(f'{attempt_message}\n')
                    print(Color().blue(attempt_message))

                    url_duration = download(caller='bulk')

                    if should_break:
                        break
                ## END attempt

                raw_dest_dir_size = dest_dir_size()
                converted_dest_dir_size = convert_byte(raw_dest_dir_size)
                append_to_log(str({'url duration': url_duration, 'dest dir size': converted_dest_dir_size})+'\n')
                print(Color().brown({'url duration': url_duration, 'dest dir size': converted_dest_dir_size}))

                append_to_log('-'*60+'\n')
                print(separator())

                if x_value:
                    x_value += 1
            ## END urls

            ## fails report
            if failed_sites:
                table_header = [f'{len(failed_sites)} fails']
                table_rows = [[failed_site] for failed_site in failed_sites]
                failed_table = draw_table(table_rows, table_header)

                append_to_log(f'{failed_table}\n')
                print(Color().red(failed_table))

            break
        ## END if
    ## END while
## }}}
def main():  ## {{{
    getopts()

    print(Color().heading(title))

    main_items = ['single', 'bulk', 'get youtube playlist urls', 'video available formats', 'help']
    main_item = fzf(main_items)

    if   main_item == 'single':
        total_duration = single()
        print(Color().brown({'time': get_datetime('jhms'), 'total duration': total_duration}))
    elif main_item == 'bulk':
        total_duration = bulk()
        append_to_log(str({'time': get_datetime('jhms'), 'total duration': total_duration})+'\n')
        print(Color().brown({'time': get_datetime('jhms'), 'total duration': total_duration}))
    elif main_item == 'get youtube playlist urls':
        get_youtube_playlist_urls()
    elif main_item == 'video available formats':
        video_available_formats()
    elif main_item == 'help':
        help()
## }}}
## variables {{{
title = path.basename(__file__).replace('.py', '')
hnd = f'{getenv("HOME")}/downloads'
s = Session()
hdrs = get_headers()
proxy = 'socks5://127.0.0.1:9050'
display_args = {'datetime': get_datetime('jymdhms')}
script_args = argv[1:]
attempts = [att for att in range(1, 6)]
## }}}

if __name__ == '__main__':
    main()
