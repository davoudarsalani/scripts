#!/usr/bin/env python

from os import getenv
from sys import argv

from jdatetime import datetime as jdt
from requests import Session
from gp import get_headers, msgc, msgn, set_widget, refresh_icon, last_file_exists, save_as_last, save_error, get_last

lang = 'en'
lat = 29.4519
lon = 60.8842
appid = getenv('api_weather')
url = f'https://api.openweathermap.org/data/2.5/onecall?lang={lang}&lat={lat}&lon={lon}&units=metric&exclude=hourly,minutely&appid={appid}'
s = Session()
hdrs = get_headers()
last_file = f'{getenv("HOME")}/scripts/.last/weather'
error_file = f'{getenv("HOME")}/scripts/.error/weather'
arg = argv[1]

def get_info():  ## {{{
    resp = s.get(url, headers=hdrs, timeout=20)
    resp = resp.json()  ## dict

    return resp
## }}}
def get_current():  ## {{{
    current     = resp['current']  ## dict
    dt          = current['dt']  ## int
    weekday     = jdt.fromtimestamp(dt).strftime('%A')[:3]
    temp        = int(current['temp'])  ## int
    weather     = current['weather']  ## list
    description = weather[0]['description']

    return weekday, temp, description
## }}}
def get_forecast():  ## {{{
    dt          = day['dt']  ## int
    weekday     = jdt.fromtimestamp(dt).strftime('%A')[:3]
    temp        = day['temp']  ## dict
    temp_min    = int(temp['min'])
    temp_max    = int(temp['max'])
    weather     = day['weather']  ## list
    description = weather[0]['description']

    return weekday, temp_min, temp_max, description
## }}}

if arg == 'update':
    set_widget('weather', 'fg', 'reset')
    set_widget('weather', 'markup', refresh_icon())

    try:
        resp = get_info()

        ## get last temp
        if last_file_exists(last_file):
            temp_last = int(get_last(last_file))

        ## get new temp, description
        _, temp, description = get_current()

        ## save temp as last to compare in our next read
        save_as_last(last_file, temp)

        ## compare
        if last_file_exists(last_file):
            if temp == temp_last:
                icon = ''
            else:
                if temp > temp_last:
                    diff = temp - temp_last
                    icon = f'+{diff} '
                elif temp < temp_last:
                    diff = temp_last - temp
                    icon = f'-{diff} '
        else:
            icon = ''

        text = f'{icon}{temp}° {description}'

    except Exception as exc:
        text = 'WE'

        ## save error
        save_error(error_file, f'{exc!r}')

        set_widget('weather', 'fg', getenv('red'))

    finally:
        set_widget('weather', 'markup', text)

elif arg == 'forecast':
    try:
        resp = get_info()

        ## current
        message = f'<span color=\"{getenv("orange")}\">Current</span>\n'
        weekday, temp, description = get_current()
        message = f'{message}{weekday}\t{temp}°\t\t\t{description}'

        ## forecast
        message = f'{message}\n\n<span color=\"{getenv("orange")}\">Forecast</span>\n'
        days = resp['daily']  ## list
        for day in days:  ## day is a dict
            weekday, temp_min, temp_max, description = get_forecast()

            if weekday == 'Fri' or weekday == 'Sat':
                tabs = '\t'*2
            else:
                tabs = '\t'
            message = f'{message}{weekday}{tabs}{temp_min}°   {temp_max}°\t{description}\n'

        message = message.strip()

        msgn(message, duration=20)

    except Exception as exc:
        msgc('ERROR', f'gettin forecast\n{exc!r}', f'{getenv("HOME")}/linux/themes/alert-w.png')
