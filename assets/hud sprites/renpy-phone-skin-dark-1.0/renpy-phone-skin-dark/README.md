# Ren'Py Phone Skins: Midnight 1.0

A phone and social media interface for Ren'Py 8: chat with typing dots, time stamps and avatars, a chat list with unread badges, notification banners, a call screen and a social feed, in the Midnight style.

Store page: https://juliusschmidt.itch.io/renpy-phone-skin-dark  
All 8 skins of the series, plus every skin added later: https://juliusschmidt.itch.io/renpy-phone-skins-complete

Requires Ren'Py 8.1 or newer (tested with 8.5.3).

## Install

1. Copy the folder `phone_skins` into the `game` folder of your project, so that you have
   `game/phone_skins/phone_core.rpy` and `game/phone_skins/dark/skin.rpy`.
2. Register your contacts in any `init python` block (optional; unknown names still work):

```
init python:
    phone_contact("Mia", status="online")
    phone_contact("Theo", color="#e76f51", status="last seen 22:41")
    phone_contact("Study Club", group=True, status="4 members")
```

3. Use the phone in your script:

```
label start:
    call phone_chat("Mia", [
        "are you still awake?",
        ("me", "yeah, what's up?"),
        ("Mia", "come by tomorrow at 9"),
    ], clock="23:12")

    $ phone_notify("Theo", "did Mia text you too?", unread=True)

    call phone_contacts
    if _return == "Theo":
        call phone_chat("Theo", [("me", "she did. weird, right?")])

    call phone_call("Theo")
    if _return:
        theo "So she told you too."
        $ phone_hang_up()

    call phone_feed([
        ("Mia", "Found the best reading spot!", 128, 14, "2h", "images/library.png"),
        ("Theo", "Band practice moved to Thursday.", 41, 6, "5h"),
    ])
```

The folder `demo` is a complete Ren'Py project with the skin installed. Open it in the Ren'Py launcher
(Preferences > Projects Directory, or copy it next to your other projects) and launch it.

## Calls

| Call | What it does |
|---|---|
| `call phone_chat(who, messages, clock=None, typing=None, close=True)` | Shows the chat with `who` and plays the messages one by one: typing dots before every message of another person, then the message, then a click. A string is a message from `who`; a tuple is `(sender, text)` or `(sender, text, "21:30")`; the sender `"me"` is the player. In group chats the sender's name is shown above the bubble. `close=False` keeps the chat on screen afterwards. Earlier messages of the chat stay and are shown again. |
| `call phone_contacts` | The chat list: avatar, last message, time and unread badge per chat. `_return` is the picked name, or `None` when the player closes the list. `call phone_contacts(["Mia", "Theo"], "Friends")` shows only these chats under another title. |
| `call phone_call(who)` | Incoming call with a decline and an accept button. `_return` is `True` or `False`. A picked-up call stays on screen with a running timer until `$ phone_hang_up()`. `call phone_call(who, incoming=False)` is a call by the player that is picked up after `phone_config.ring_time` seconds. |
| `call phone_feed(posts)` | The social feed. A post is `(author, text, likes, comments, time, picture)`; everything after `text` is optional, `picture` is any image or displayable (shown 384x200, cropped to fill). The player can like posts and closes the feed. `call phone_feed` without posts shows the posts added with `phone_post()`. |
| `$ phone_notify(who, text, unread=False)` | A notification banner at the top of the phone, also when the phone is hidden; it goes away after `phone_config.notify_time` seconds. `unread=True` also puts the message into the chat of `who` with an unread badge. |

| Function | |
|---|---|
| `phone_contact(name, color=None, status="", initials=None, avatar=None, group=False)` | registers a contact; `avatar` is an image shown in the avatar shape instead of the initials |
| `phone_history(who, messages)` | puts messages into a chat without showing them |
| `phone_open(who)` / `phone_close()` | shows a chat without new messages / hides the phone |
| `phone_post(author, text, likes=0, comments=0, time="now", picture=None)` | adds a post at the top of the feed |
| `phone_set_clock("23:40")`, `phone_pass_minutes(15)` | clock in the status bar and on new messages |
| `phone_unread(who)`, `phone_mark_read(who)`, `phone_thread(who)`, `phone_clear(who)` | read and change chats |
| `phone_use("dark")` | switches the skin when several skins are installed (saved with the game) |
| `phone_avatar(name, size)` | the avatar as a displayable, for your own screens |

Everything is stored in `phone_data`, a normal saved variable: saving, loading and rollback work.

## Settings

Set them in an `init python` block:

| Setting | Default | |
|---|---|---|
| `phone_config.xalign`, `phone_config.yalign` | `0.5`, `0.5` | position of the phone |
| `phone_config.zoom` | `1.0` | size (1.0 = about 95 % of the screen height) |
| `phone_config.typing` | `True` | typing dots before messages |
| `phone_config.typing_min`, `typing_per_char`, `typing_max` | `0.7`, `0.03`, `2.2` | typing time in seconds |
| `phone_config.keep` | `8` | messages shown at once in a chat |
| `phone_config.clock` | `"21:04"` | clock at the start |
| `phone_config.notify_time` | `3.5` | seconds a notification stays |
| `phone_config.ring_time` | `2.5` | ring time of a call by the player |
| `phone_config.me` | `"me"` | sender name of the player's messages |
| `phone_config.me_name` | `"You"` | the player's name in chat previews |
| `phone_config.labels` | `{}` | your own texts, for example `{"chats": "Inbox", "typing": "is typing"}` |

The phone is laid out for 1080 pixel tall screens and scales itself, so it fits 1280x720, 1920x1080 and
larger projects without changes.

## Screens

You can also show the screens yourself: `phone_chat_screen(who)`, `phone_contacts_screen(names, title)`,
`phone_call_screen(who, incoming)`, `phone_incall_screen(who)`, `phone_feed_screen(title)`, `phone_notify_screen(who, text)`.
All phone screens use the tag `phone`, so only one of them is on screen at a time.

## Next to other phone systems

Every name starts with `phone_` and none of them is used by the Ren'Py Phone Kit of the same author, so both
can be in one project. Keep only one phone visible at a time.

## The Midnight skin

Drama / thriller / night scenes: A dark-mode messenger: violet bubbles on near-black, grey incoming bubbles, glowing unread badges and a graphite phone.

Folder `phone_skins/dark/`:

| File | Size | |
|---|---|---|
| `images/avatar.png` | 128x128 |  |
| `images/avatar_ring.png` | 128x128 |  |
| `images/badge.png` | 36x36 | 9-slice, borders (17, 17, 17, 17) |
| `images/btn_accept.png` | 112x112 |  |
| `images/btn_decline.png` | 112x112 |  |
| `images/bubble_me.png` | 100x76 | 9-slice, borders (30, 24, 34, 28) |
| `images/bubble_them.png` | 100x76 | 9-slice, borders (34, 24, 30, 28) |
| `images/call_bg.png` | 460x920 |  |
| `images/card.png` | 96x96 | 9-slice, borders (30, 30, 30, 30) |
| `images/device.png` | 520x1000 |  |
| `images/dot.png` | 14x14 |  |
| `images/header.png` | 460x84 |  |
| `images/icon_back.png` | 40x40 |  |
| `images/icon_close.png` | 40x40 |  |
| `images/icon_comment.png` | 40x40 |  |
| `images/icon_heart.png` | 40x40 |  |
| `images/icon_heart_on.png` | 40x40 |  |
| `images/input_bar.png` | 460x78 |  |
| `images/notify.png` | 120x96 | 9-slice, borders (40, 34, 40, 34) |
| `images/overlay.png` | 460x920 |  |
| `images/row_hover.png` | 64x64 | 9-slice, borders (20, 20, 20, 20) |
| `images/screen_bg.png` | 460x920 |  |
| `images/statusbar.png` | 460x36 |  |

Colours, fonts, text sizes and the texts of the skin (for example the title of the chat list) are set at the top of `skin.rpy`. White shapes (`avatar.png`) are tinted with the contact colour.

Fonts:

- Liberation Sans: SIL Open Font License, see fonts/OFL-Liberation.txt

## Changes

- 1.0.1: Demo fix. The demo project crashed in the main menu ("could not find image") because Ren'Py's
  standard GUI images (buttons, bars, sliders, scrollbars) were missing. They are added now. The skin files are unchanged.

## Licence

Use the skins in your own games and visual novels, free or commercial, in as many projects as you like.
Changing the art, the colours and the code is fine; credit is welcome but not required. Do not resell or share
the files as an asset pack, UI kit or template, also not in modified form. See LICENSE.txt.

## More packs like this

Midnight is one of 8 skins in the Ren'Py Phone Skins series.

All 8, plus every skin added later, are in the Complete pack (https://juliusschmidt.itch.io/renpy-phone-skins-complete) for 4.99 USD.
