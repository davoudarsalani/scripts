#!/home/nnnn/main/scripts/venv/bin/python3

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/screenshot.py
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/screenshot.py
##    https://davoudarsalani.ir

from os import path, remove, getenv

from gi import require_version
require_version('Gdk', '3.0')
from gi.repository import Gdk
from PIL import Image
from gp import Screen, get_datetime, pip_to_dmenu, msgn, msgc, countdown

def convert_to_jpg(png_image: str) -> None:  ## {{{
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
main_item = pip_to_dmenu(main_items, 'screenshot')

now = get_datetime('jymdhms')
global output
output = f'{getenv("HOME")}/main/downloads/{now}-SS.png'

Scr = Screen()
scr_1_name, scr_1_res, scr_1_x, scr_1_y, scr_1_x_offset, scr_1_y_offset = Scr.screen_1()
scr_2_name, scr_2_res, scr_2_x, scr_2_y, scr_2_x_offset, scr_2_y_offset = Scr.screen_2()
scr_all_res = Scr.screen_all()

## https://askubuntu.com/questions/1011507/screenshot-of-an-active-application-using-python
if   main_item == 'screen 1':  ## {{{
    try:
        countdown()
        window = Gdk.get_default_root_window()
        pb = Gdk.pixbuf_get_from_window(window, 0, 0, int(scr_1_x), int(scr_1_y))
        pb.savev(output, 'png', (), ())
        # convert_to_jpg(output)
        msgn('screen 1', f'<span color=\"{getenv("gruvbox_orange")}\">{output}</span>')
    except Exception as exc:
        msgc('ERROR', f'taking screenshot of <span color=\"{getenv("gruvbox_orange")}\">screen 1</span>\n{exc!r}', f'{getenv("HOME")}/main/configs/themes/alert-w.png')
## }}}
elif main_item == 'screen 2':  ## {{{
    try:
        countdown()
        window = Gdk.get_default_root_window()
        pb = Gdk.pixbuf_get_from_window(window, int(scr_1_x), 0, int(scr_2_x), int(scr_2_y))
        pb.savev(output, 'png', (), ())
        # convert_to_jpg(output)
        msgn('screen 2', f'<span color=\"{getenv("gruvbox_orange")}\">{output}</span>')
    except Exception as exc:
        msgc('ERROR', f'taking screenshot of <span color=\"{getenv("gruvbox_orange")}\">screen 2</span>\n{exc!r}', f'{getenv("HOME")}/main/configs/themes/alert-w.png')
## }}}
elif main_item == 'screen all':  ## {{{
    try:
        countdown()
        window = Gdk.get_default_root_window()
        pb = Gdk.pixbuf_get_from_window(window, *window.get_geometry())
        pb.savev(output, 'png', (), ())
        # convert_to_jpg(output)
        msgn('screen all', f'<span color=\"{getenv("gruvbox_orange")}\">{output}</span>')
    except Exception as exc:
        msgc('ERROR', f'taking screenshot of <span color=\"{getenv("gruvbox_orange")}\">screen all</span>\n{exc!r}', f'{getenv("HOME")}/main/configs/themes/alert-w.png')
## }}}
elif main_item == 'current window':  ## {{{
    try:
        countdown()
        window = Gdk.get_default_root_window()
        screen = window.get_screen()
        typ = window.get_type_hint()
        for i, w in enumerate(screen.get_window_stack()):
            pb = Gdk.pixbuf_get_from_window(w, *w.get_geometry())
            pb.savev(output, 'png', (), ())
        # convert_to_jpg(output)
        msgn('current window', f'<span color=\"{getenv("gruvbox_orange")}\">{output}</span>')
    except Exception as exc:
        msgc('ERROR', f'taking screenshot of <span color=\"{getenv("gruvbox_orange")}\">current window</span>\n{exc!r}', f'{getenv("HOME")}/main/configs/themes/alert-w.png')
## }}}
elif main_item == 'selected area':  ## {{{
    ## https://nitratine.net/blog/post/how-to-get-mouse-clicks-with-python/
    try:
        from pynput.mouse import Listener
        '''
        NOTE
        this import used to be at the top of screen, where it's supposed to,
        but after some update, it started throwing an error (JUMP_1),
        so I decided to move it here.

        ERROR:START JUMP_1:
        Traceback (most recent call last):
          File "/home/nnnn/main/scripts/./screenshot.py", line 11, in <module>
            from pynput.mouse import Listener
          File "/home/nnnn/main/scripts/.venv/lib/python3.10/site-packages/pynput/__init__.py", line 40, in <module>
            from . import keyboard
          File "/home/nnnn/main/scripts/.venv/lib/python3.10/site-packages/pynput/keyboard/__init__.py", line 31, in <module>
            backend = backend(__name__)
          File "/home/nnnn/main/scripts/.venv/lib/python3.10/site-packages/pynput/_util/__init__.py", line 76, in backend
            raise ImportError('this platform is not supported: {}'.format(
        ImportError: this platform is not supported: ('failed to acquire X connection: libtk8.6.so: cannot open shared object file: No such file or directory', ImportError('libtk8.6.so: cannot open s
        hared object file: No such file or directory'))

        Try one of the following resolutions:

        * Please make sure that you have an X server running, and that the DISPLAY environment variable is set correctly
        ERROR:END
        '''

        ## get x_1 and y_1
        def on_click_1(x: int, y: int, button, pressed: bool) -> tuple[int, int]:
            if pressed:
                opened_listener_1.stop()
                global x_1, y_1
                x_1 = x
                y_1 = y
                return x_1, y_1

        with Listener(on_click=on_click_1) as opened_listener_1:
            opened_listener_1.join()

        ## get x_2 and y_2
        def on_click_2(x: int, y: int, button, pressed: bool) -> tuple[int, int]:
            if pressed:
                opened_listener_2.stop()
                global x_2, y_2
                x_2 = x
                y_2 = y
                return x_2, y_2

        with Listener(on_click=on_click_2) as opened_listener_2:
            opened_listener_2.join()

        x_2 = x_2 - x_1
        y_2 = y_2 - y_1

        window = Gdk.get_default_root_window()
        pb = Gdk.pixbuf_get_from_window(window, int(x_1), int(y_1), int(x_2), int(y_2))
        pb.savev(output, 'png', (), ())
        # convert_to_jpg(output)
        msgn('selected area', f'<span color=\"{getenv("gruvbox_orange")}\">{output}</span>')
    except Exception as exc:
        msgc('ERROR', f'taking screenshot of <span color=\"{getenv("gruvbox_orange")}\">selected area</span>\n{exc!r}', f'{getenv("HOME")}/main/configs/themes/alert-w.png')
## }}}
else:  ## {{{
    exit()
## }}}
