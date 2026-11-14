## Ren'Py Phone Skins: Midnight (game/phone_skins/dark/skin.rpy)
## Ren'Py Phone Skins - https://juliusschmidt.itch.io/renpy-phone-skin-dark
## Needs phone_core.rpy (version 1 or newer) in game/phone_skins/. Do not rename this folder:
## the image paths below start with "phone_skins/dark".
##
## Change colours, fonts and sizes here. Image sizes and 9-slice borders are listed in README.md.

init -10 python:
    phone_register_skin('dark',
        name='Midnight',
        folder='phone_skins/dark',
        dev=(520, 1000),          ## outer size of images/device.png
        scr=(30, 40),          ## top-left of the phone screen inside device.png
        top=0,               ## extra space above the status bar (shaped screens)
        font="phone_skins/dark/fonts/LiberationSans-Bold.ttf",
        font_body="phone_skins/dark/fonts/LiberationSans-Regular.ttf",
        font_head="phone_skins/dark/fonts/LiberationSans-Bold.ttf",
        size=22, name_size=25, small=15,     ## text sizes (phone pixels at 1080p)
        line_spacing=2,
        nearest=False,        ## pixel-art scaling
        glitch=False,         ## chromatic glitch on names and titles
        divider='#22252d',
        badge_dy=0,          ## moves the unread number up or down on the badge
        pad_me=(20, 14, 32, 18), pad_them=(32, 14, 20, 18),  ## text padding inside the bubbles (left, top, right, bottom)
        nine={'bubble_me': (30, 24, 34, 28), 'bubble_them': (34, 24, 30, 28), 'card': (30, 30, 30, 30), 'row_hover': (20, 20, 20, 20), 'notify': (40, 34, 40, 34), 'badge': (17, 17, 17, 17)},
        c=dict(
            bg='#0f1115',
            text_me='#ffffff',
            text_them='#e6e8ee',
            head_fg='#f3f4f6',
            sub_fg='#9aa1ad',
            time='#7d8594',
            accent='#8b6cff',
            badge_fg='#ffffff',
            card_fg='#e6e8ee',
            avatar_fg='#0f1115',
            call_fg='#ffffff',
            notify_fg='#f3f4f6',
            notify_sub='#b4bac5',
        ),
        avatars=['#f4a261', '#2ec4b6', '#e76f51', '#a3b18a', '#ffb4c8', '#8ecae6'],   ## avatar colours of contacts without a colour of their own
        labels={},
    )
