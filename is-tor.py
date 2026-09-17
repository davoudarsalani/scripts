#!/home/nnnn/main/scripts/venv/bin/python3

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/is-tor.py
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/is-tor.py
##    https://davoudarsalani.ir


from os import path, getenv
from sys import argv

from requests import Session

from utils import (
    HTTP_HEADERS,
    TIMEOUT,
    Color,
    msgn,
)


title       = path.basename(__file__)
url         = 'https://check.torproject.org/api/ip'
# country_url = 'http://ip-api.com/json'
Col         = Color()

attempts = 10

script_args = argv[1:]
if script_args:
    first_arg = script_args[0]
else:
    first_arg = None

if first_arg == 'msg':
    msgn(f'<span color=\"{getenv("gruvbox_orange")}\">{title}</span> checking')
else:
    print(Col.heading(title))

for attempt in range(1, attempts+1):
    if attempt > 1:
        if first_arg == 'msg':
            msgn(f'<span color=\"{getenv("gruvbox_orange")}\">{title}</span> attempt {attempt}/{attempts}')
        else:
            print(f'attempt {attempt}/{attempts}')

    ## get IsTor and IP
    try:
        with Session() as ses:
            tor_proxy = 'socks5h://127.0.0.1:9050'
            ses.proxies = {
                'http': tor_proxy,
                'https': tor_proxy,
            }

            resp = ses.get(url, headers=HTTP_HEADERS, timeout=TIMEOUT)
            resp.raise_for_status()

            dic = resp.json()
            ## dic = {
            ##     'IsTor': True,
            ##     'IP': '<YOUR-IP>',
            ## }

            istor = dic.get('IsTor', False)  ## True/False
            ip    = dic.get('IP')
    except Exception as exc:
        istor = False
        ip    = None

    if istor or ip:
        if first_arg == 'msg':
            msgn(f'<span color=\"{getenv("gruvbox_green")}\">✔</span> <span color=\"{getenv("gruvbox_orange")}\">{istor=}</span> (IP: {ip})')
        else:
            print(Col.green('✔ ') + Col.gray(f'{istor=} (IP: {ip})'))

        break

    '''
    ## get country of ip
    try:
        with Session() as ses:
            resp = ses.get(f'{country_url}/{ip}', headers=HTTP_HEADERS, timeout=TIMEOUT)
            resp.raise_for_status()

            dic = resp.json()
            ## dic = {
            ##     'status': 'success',
            ##     'country': 'Sweden',
            ##     'countryCode': 'SE',
            ##     'region': 'AB',
            ##     'regionName': 'Stockholm County',
            ##     'city': 'Stockholm',
            ##     'zip': '100 05',
            ##     'lat': 59.3293,
            ##     'lon': 18.0686,
            ##     'timezone': 'Europe/Stockholm',
            ##     'isp': 'Svea Hosting AB',
            ##     'org': 'Svea Hosting AB',
            ##     'as': 'AS41634 Svea Hosting AB',
            ##     'query': '<YOUR-IP>',
            ## }

            country = dic.get('country', 'Unknown Country')

            if first_arg == 'msg':
                msgn(f'<span color=\"{getenv("gruvbox_green")}\">✔</span> <span color=\"{getenv("gruvbox_orange")}\">{title}</span> = true ({ip}, {country})')
            else:
                print(Col.green('✔ ') + Col.gray(f'true ({ip}, {country})'))

            break
    except Exception as exc:
        pass
    '''
