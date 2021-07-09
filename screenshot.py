#!/usr/bin/env python

from os import path, remove, getenv
from gi import require_version
require_version('Gdk', '3.0')
from gi.repository import Gdk
from PIL import Image
from pynput.mouse import Listener

from gp import Screen, get_datetime, dmenu, msgn, countdown

def convert_to_jpg(png_image: str):  ## {{{
    global output
    im = Image.open(f'{png_image}')
    im = im.convert('RGB')
    p_name, p_ext = path.splitext(png_image)
    output = f'{p_name}.jpg'
    im.save(output, quality=100)
    try:
        remove(png_image)
    except Exception:
        pass
## }}}

main_items = ['screen 1', 'screen 2', 'screen all', 'current window', 'selected area']
main_item = dmenu(main_items, 'screenshot')

now = get_datetime('jymdhms')
global output
output = f'{getenv("HOME")}/downloads/{now}-SS.png'

scr_1_name, scr_1_res, scr_1_x, scr_1_y = Screen().screen_1()
scr_2_name, scr_2_res, scr_2_x, scr_2_y = Screen().screen_2()
scr_all_res = Screen().screen_all()

## https://askubuntu.com/questions/1011507/screenshot-of-an-active-application-using-python
if   main_item == 'screen 1':
    countdown()
    window = Gdk.get_default_root_window()
    pb = Gdk.pixbuf_get_from_window(window, 0, 0, int(scr_1_x), int(scr_1_y))
    pb.savev(output, 'png', (), ())
    # convert_to_jpg(output)
    msgn('screen 1', f'<span color=\"{getenv("orange")}\">{output}</span>')
elif main_item == 'screen 2':
    countdown()
    window = Gdk.get_default_root_window()
    pb = Gdk.pixbuf_get_from_window(window, int(scr_1_x), 0, int(scr_2_x), int(scr_2_y))
    pb.savev(output, 'png', (), ())
    # convert_to_jpg(output)
    msgn('screen 2', f'<span color=\"{getenv("orange")}\">{output}</span>')
elif main_item == 'screen all':
    countdown()
    window = Gdk.get_default_root_window()
    pb = Gdk.pixbuf_get_from_window(window, *window.get_geometry())
    pb.savev(output, 'png', (), ())
    # convert_to_jpg(output)
    msgn('screen all', f'<span color=\"{getenv("orange")}\">{output}</span>')
elif main_item == 'current window':
    countdown()
    window = Gdk.get_default_root_window()
    screen = window.get_screen()
    typ = window.get_type_hint()
    for i, w in enumerate(screen.get_window_stack()):
        pb = Gdk.pixbuf_get_from_window(w, *w.get_geometry())
        pb.savev(output, 'png', (), ())
    # convert_to_jpg(output)
    msgn('current window', f'<span color=\"{getenv("orange")}\">{output}</span>')

elif main_item == 'selected area':
    ## https://nitratine.net/blog/post/how-to-get-mouse-clicks-with-python/

    ## get x_1 and y_1
    def on_click_1(x: int, y: int, button, pressed: bool):
        if pressed:
            listener_1.stop()
            global x_1, y_1
            x_1 = x
            y_1 = y
            return x_1, y_1

    with Listener(on_click=on_click_1) as listener_1:
        listener_1.join()

    ## get x_2 and y_2
    def on_click_2(x: int, y: int, button, pressed: bool):
        if pressed:
            listener_2.stop()
            global x_2, y_2
            x_2 = x
            y_2 = y
            return x_2, y_2

    with Listener(on_click=on_click_2) as listener_2:
        listener_2.join()

    x_2 = x_2 - x_1
    y_2 = y_2 - y_1

    window = Gdk.get_default_root_window()
    pb = Gdk.pixbuf_get_from_window(window, int(x_1), int(y_1), int(x_2), int(y_2))
    pb.savev(output, 'png', (), ())
    # convert_to_jpg(output)
    msgn('selected area', f'<span color=\"{getenv("orange")}\">{output}</span>')
else:
    exit()
