#!/home/nnnn/main/scripts/venv/bin/python3

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/is-tor.py
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/is-tor.py
##    https://davoudarsalani.ir

from json import loads
from os import path, getenv
from sys import argv

from requests import Session
from gp import Color, msgn, get_headers

title = path.basename(__file__).replace('.py', '')
istor = False
ip = None
url = 'https://check.torproject.org/api/ip'
tor_proxy = 'socks5h://127.0.0.1:9050'
country_url = 'http://ip-api.com/json'
Col = Color()
Ses = Session()
hdrs = get_headers()
Ses.proxies = {
    'http': tor_proxy,
    'https': tor_proxy
}

script_args = argv[1:]
if script_args:
    first_arg = script_args[0]
else:
    first_arg = None

if first_arg == 'msg':
    msgn(f'<span color=\"{getenv("gruvbox_orange")}\">{title}</span> checking')
    attempts = 10
else:
    attempts = 1000
    print(Col.heading(title))

for attempt in range(1, attempts+1):
    if istor and ip:  ## JUMP_1
        break
    else:

        if attempt > 1:
            if first_arg == 'msg':
                msgn(f'<span color=\"{getenv("gruvbox_orange")}\">{title}</span> attempt {attempt}/{attempts}')
            else:
                print(f'attempt {attempt}/{attempts}')

        ## get tor status and ip
        try:
            response = Ses.get(url, headers=hdrs, timeout=20)
            response = loads(response.text)  ## {'IsTor': True, 'IP': 'YOUR-IP'}

            istor = response.get('IsTor', False)  ## True/False
            ip    = response.get('IP')
        except Exception as exc:
            pass

        if istor and ip:
            ## get country of ip
            try:
                response = Ses.get(f'{country_url}/{ip}', headers=hdrs, timeout=20)
                response = loads(response.text)  ## {'status': 'success', 'country': 'Sweden', 'countryCode': 'SE', 'region': 'AB', 'regionName': 'Stockholm County', 'city': 'Stockholm', 'zip': '100 05', 'lat': 59.3293, 'lon': 18.0686, 'timezone': 'Europe/Stockholm', 'isp': 'Svea Hosting AB', 'org': 'Svea Hosting AB', 'as': 'AS41634 Svea Hosting AB', 'query': '193.239.232.102'}

                country = response.get('country')
            except Exception as exc:
                pass

            if first_arg == 'msg':
                msgn(f'<span color=\"{getenv("gruvbox_green")}\">✔</span> <span color=\"{getenv("gruvbox_orange")}\">{title}</span> = true ({ip}, {country})')
            else:
                print(Col.green('✔ ') + Col.gray(f'true ({ip}, {country})'))
