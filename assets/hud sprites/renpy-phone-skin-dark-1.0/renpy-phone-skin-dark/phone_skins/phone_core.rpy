## Ren'Py Phone Skins - core, version 1 (game/phone_skins/phone_core.rpy)
##
## This file is the same in every pack of the series. Copying a second pack into game/ overwrites it with an
## identical copy, so any number of skins can be installed side by side; phone_use("id") switches between them.
##
## Use from your script:
##     call phone_chat("Mia", ["hey!", ("me", "hi :)"), ("Mia", "free tonight?")])
##     call phone_contacts            ## the player picks a chat; _return is the name or None
##     call phone_call("Mia")         ## incoming call; _return is True (picked up) or False
##     $ phone_hang_up()              ## ends the call screen of a picked-up call
##     call phone_feed([("Theo", "New song out!", 24)])
##     $ phone_notify("Theo", "you up?")
## Every function and setting is described in README.md.

init -20 python:

    PHONE_CORE_VERSION = 1
    PHONE_SW, PHONE_SH = 460, 920
    PHONE_STATUS_H, PHONE_HEADER_H, PHONE_INPUT_H = 36, 84, 78

    class PhoneConfig(object):
        """Settings. Change them in an init python block, for example: phone_config.xalign = 0.8"""
        def __init__(self):
            self.skin = None              ## skin id used when phone_use() was never called (None = first installed)
            self.zoom = 1.0               ## size of the phone; 1.0 = fills about 95 % of the screen height
            self.xalign = 0.5             ## position of the phone on the screen
            self.yalign = 0.5
            self.me = "me"                ## sender name that marks the player's own messages
            self.me_name = "You"          ## how the player is called in previews
            self.typing = True            ## typing dots before every message of another person
            self.typing_min = 0.7         ## typing time = min + per_char * length, at most max (seconds)
            self.typing_per_char = 0.03
            self.typing_max = 2.2
            self.keep = 8                 ## messages shown at once in a chat (older ones scroll away)
            self.clock = "21:04"          ## clock at the start of the game
            self.notify_time = 3.5        ## seconds a notification stays
            self.ring_time = 2.5          ## seconds an outgoing call rings before it is picked up
            self.labels = {}              ## your own texts, for example {"chats": "Inbox"}; overrides the skin's

    phone_config = PhoneConfig()
    PHONE_SKINS = {}
    PHONE_CONTACTS = {}
    PHONE_CONTACT_ORDER = []

    PHONE_DEFAULT_LABELS = dict(chats="Chats", feed="Feed", incoming="Incoming call", calling="Calling...",
                                in_call="Connected", typing="typing...", message="Message", now="now",
                                ended="Call ended", likes="likes", empty="No messages yet")

    class PhoneSkin(object):
        def __init__(self, id, **kw):
            self.id = id
            self.top = 0
            self.nearest = False
            self.glitch = False
            self.divider = None
            self.line_spacing = 2
            self.badge_dy = 0
            self.__dict__.update(kw)
            self.labels = dict(PHONE_DEFAULT_LABELS, **kw.get("labels", {}))

        def img(self, name):
            return "%s/images/%s.png" % (self.folder, name)

        def frame(self, name):
            return Frame(self.img(name), *self.nine[name])

        def label(self, key):
            return phone_config.labels.get(key, self.labels.get(key, key))

        @property
        def outlines(self):
            if self.glitch:
                return [(0, "#ff1a3c99", 2, 0), (0, "#3cf0ff77", -2, 0)]
            return []

    PHONE_ART = ("device", "screen_bg", "call_bg", "overlay", "header", "statusbar", "input_bar", "bubble_me",
                 "bubble_them", "dot", "avatar", "avatar_ring", "card", "row_hover", "notify", "badge", "btn_accept",
                 "btn_decline", "icon_back", "icon_heart", "icon_heart_on", "icon_comment", "icon_close")

    def phone_register_skin(id, **kw):
        """Called by every skin.rpy. Stops with a clear message when a file of the skin is missing."""
        S = PhoneSkin(id, **kw)
        missing = [S.img(n) for n in PHONE_ART if not renpy.loadable(S.img(n))]
        missing += [f for f in sorted({S.font, S.font_body, S.font_head}) if not renpy.loadable(f)]
        if missing:
            raise Exception("Phone skin %r is incomplete, missing: %s. Copy the whole folder phone_skins/%s/ again."
                            % (id, ", ".join(missing), id))
        PHONE_SKINS[id] = S

    def phone_use(id):
        """Switches the skin (it is saved with the game)."""
        if id not in PHONE_SKINS:
            raise Exception("Phone skin %r is not installed. Installed: %s" % (id, ", ".join(sorted(PHONE_SKINS)) or "none"))
        store.phone_skin_id = id
        renpy.restart_interaction()

    def phone_theme():
        if not PHONE_SKINS:
            raise Exception("No phone skin installed: copy a skin folder into game/phone_skins/.")
        sid = store.phone_skin_id or phone_config.skin
        if sid not in PHONE_SKINS:
            sid = sorted(PHONE_SKINS)[0]
        return PHONE_SKINS[sid]

    ## ------------------------------------------------------------------------------------------ contacts

    class PhoneContact(object):
        def __init__(self, name, color=None, status="", initials=None, avatar=None, group=False):
            self.name = name
            self.color = color
            self.status = status
            self.initials = initials
            self.avatar = avatar
            self.group = group

    def phone_contact(name, color=None, status="", initials=None, avatar=None, group=False):
        """Registers a contact (init time). avatar: an image for the round picture instead of initials."""
        if name not in PHONE_CONTACTS:
            PHONE_CONTACT_ORDER.append(name)
        PHONE_CONTACTS[name] = PhoneContact(name, color, status, initials, avatar, group)

    def phone_initials(name):
        c = PHONE_CONTACTS.get(name)
        if c is not None and c.initials:
            return c.initials
        parts = [p for p in name.replace("_", " ").split() if p]
        if not parts:
            return "?"
        if len(parts) == 1:
            return parts[0][:1].upper()
        return (parts[0][:1] + parts[1][:1]).upper()

    def phone_color(name):
        S = phone_theme()
        c = PHONE_CONTACTS.get(name)
        if c is not None and c.color:
            return c.color
        return S.avatars[sum(ord(ch) for ch in name) % len(S.avatars)]

    def phone_avatar(name, size=56):
        """The round contact picture: the skin's avatar shape in the contact colour with initials."""
        S = phone_theme()
        c = PHONE_CONTACTS.get(name)
        shape = Transform(S.img("avatar"), xysize=(size, size))
        if c is not None and c.avatar:
            face = AlphaMask(Transform(c.avatar, xysize=(size, size), fit="cover"), shape)
            return Fixed(face, Transform(S.img("avatar_ring"), xysize=(size, size)), xysize=(size, size))
        if S.nearest:
            ts = 32 if size >= 90 else 16
        else:
            ts = int(size * 0.4)
        return Fixed(Transform(shape, matrixcolor=TintMatrix(phone_color(name))),
                     Text(phone_initials(name), font=S.font, size=ts, color=S.c["avatar_fg"], xalign=0.5, yalign=0.5),
                     Transform(S.img("avatar_ring"), xysize=(size, size)),
                     xysize=(size, size))

    ## ------------------------------------------------------------------------------------------ data

    class PhoneData(object):
        def __init__(self):
            self.threads = {}
            self.unread = {}
            self.typing = None
            self.clock = None
            self.posts = []
            self.call = None
            self.chat = None

    def phone_clock():
        return store.phone_data.clock or phone_config.clock

    def phone_set_clock(hhmm):
        store.phone_data.clock = hhmm
        renpy.restart_interaction()

    def phone_pass_minutes(m):
        h, mi = [int(x) for x in phone_clock().split(":")]
        t = (h * 60 + mi + int(m)) % (24 * 60)
        phone_set_clock("%02d:%02d" % (t // 60, t % 60))

    def phone_entry(chat, m):
        """A message from a string, a (sender, text[, time]) tuple or a dict."""
        if isinstance(m, dict):
            who, text, t = m.get("who", chat), m.get("text", ""), m.get("time")
        elif isinstance(m, str):
            who, text, t = chat, m, None
        else:
            who, text = m[0], m[1]
            t = m[2] if len(m) > 2 else None
        return {"who": who, "text": text, "time": t or phone_clock(), "mine": who == phone_config.me}

    def phone_thread(chat):
        return store.phone_data.threads.get(chat, [])

    def phone_add(chat, m):
        d = store.phone_data
        if chat not in d.threads:
            d.threads[chat] = []
        e = phone_entry(chat, m)
        d.threads[chat].append(e)
        if d.chat != chat and not e["mine"]:
            d.unread[chat] = d.unread.get(chat, 0) + 1
        renpy.restart_interaction()
        return e

    def phone_history(chat, messages):
        """Puts messages into a chat without showing them (earlier conversation, unread messages)."""
        for m in messages:
            phone_add(chat, m)

    def phone_unread(chat=None):
        d = store.phone_data
        if chat is None:
            return sum(d.unread.values())
        return d.unread.get(chat, 0)

    def phone_mark_read(chat):
        store.phone_data.unread[chat] = 0

    def phone_clear(chat):
        store.phone_data.threads.pop(chat, None)
        store.phone_data.unread.pop(chat, None)

    def phone_typing_time(text):
        return min(phone_config.typing_max, phone_config.typing_min + phone_config.typing_per_char * len(text))

    def phone_open(chat):
        """Shows a chat without new messages (it stays until phone_close())."""
        store.phone_data.chat = chat
        phone_mark_read(chat)
        renpy.show_screen("phone_chat_screen", chat)

    def phone_close():
        store.phone_data.chat = None
        store.phone_data.typing = None
        renpy.hide_screen("phone")

    def phone_chats():
        """Chat names for the contact list: registered contacts first, then everybody with messages."""
        names = list(PHONE_CONTACT_ORDER)
        for n in store.phone_data.threads:
            if n not in names:
                names.append(n)
        return names

    def phone_short(text, n):
        text = text.replace("\n", " ")
        return text if len(text) <= n else text[:max(1, n - 3)].rstrip() + "..."

    def phone_preview(chat, n):
        t = phone_thread(chat)
        if not t:
            c = PHONE_CONTACTS.get(chat)
            return (c.status if c is not None else "") or phone_theme().label("empty")
        m = t[-1]
        txt = m["text"]
        if m["mine"]:
            txt = phone_config.me_name + ": " + txt
        elif PHONE_CONTACTS.get(chat) is not None and PHONE_CONTACTS[chat].group:
            txt = m["who"] + ": " + txt
        return phone_short(txt, n)

    def phone_chars(S, width, size=None):
        """Characters of body text that fit into width (for previews)."""
        return max(8, int(width / ((size or S.size) * (0.5 if S.nearest else 0.52))))

    ## ------------------------------------------------------------------------------------------ notifications

    def phone_notify(who, text, unread=False):
        """A banner at the top of the phone (also when the phone is hidden). unread=True also adds the message
        to who's chat as unread."""
        if unread:
            phone_add(who, (who, text))
        renpy.show_screen("phone_notify_screen", who, text)

    ## ------------------------------------------------------------------------------------------ feed

    def phone_post_entry(p):
        if isinstance(p, dict):
            d = dict(author=p.get("author", "?"), text=p.get("text", ""), likes=int(p.get("likes", 0)),
                     comments=int(p.get("comments", 0)), time=p.get("time", "1h"), picture=p.get("picture"),
                     liked=bool(p.get("liked", False)))
        else:
            d = dict(author=p[0], text=p[1], likes=int(p[2]) if len(p) > 2 else 0,
                     comments=int(p[3]) if len(p) > 3 else 0, time=p[4] if len(p) > 4 else "1h",
                     picture=p[5] if len(p) > 5 else None, liked=False)
        return d

    def phone_post(author, text, likes=0, comments=0, time="now", picture=None):
        """Adds a post at the top of the feed."""
        store.phone_data.posts.insert(0, phone_post_entry(dict(author=author, text=text, likes=likes,
                                                               comments=comments, time=time, picture=picture)))

    def phone_like(i):
        p = store.phone_data.posts[i]
        p["liked"] = not p["liked"]
        p["likes"] += 1 if p["liked"] else -1
        renpy.restart_interaction()

    ## ------------------------------------------------------------------------------------------ calls

    def phone_hang_up():
        store.phone_data.call = None
        renpy.hide_screen("phone")

    def phone_call_seconds(st, at):
        return Text("%02d:%02d" % (int(st) // 60, int(st) % 60), **phone_call_style()), 0.5

    def phone_call_style():
        S = phone_theme()
        return dict(font=S.font, size=S.size, color=S.c["call_fg"], xalign=0.5)

    ## ------------------------------------------------------------------------------------------ layout

    def phone_zoom(S):
        sh = float(config.screen_height)
        z = sh / 1080.0 * phone_config.zoom
        w, h = S.dev
        z = min(z, sh * 0.985 / h, config.screen_width * 0.985 / w)
        return z

    def phone_notify_pos(S):
        """Top-left of the notification banner (game pixels) and its zoom."""
        z = phone_zoom(S)
        w, h = S.dev
        x0 = (config.screen_width - w * z) * phone_config.xalign
        y0 = (config.screen_height - h * z) * phone_config.yalign
        return (int(x0 + (S.scr[0] + 14) * z), int(y0 + (S.scr[1] + S.top + PHONE_STATUS_H + 10) * z), z)


default phone_data = PhoneData()
default phone_skin_id = None

## ---------------------------------------------------------------------------------------------- transforms

transform phone_place(z, xa, ya, nearest=False):
    subpixel True
    nearest nearest
    xalign xa yalign ya zoom z
    on show:
        alpha 0.0 yoffset 50
        easein 0.28 alpha 1.0 yoffset 0
    on replace:
        alpha 1.0 yoffset 0
    on hide:
        easeout 0.2 alpha 0.0 yoffset 50

transform phone_clip(w, h):
    crop (0, 0, w, h)

transform phone_pop:
    alpha 0.0 yoffset 14
    easein 0.18 alpha 1.0 yoffset 0

transform phone_dot(d):
    alpha 0.35 yoffset 0
    pause d
    block:
        easein 0.22 alpha 1.0 yoffset -5
        easeout 0.22 alpha 0.35 yoffset 0
        pause 0.46
        repeat

transform phone_still:
    xoffset 0

transform phone_glitch:
    xoffset 0
    block:
        pause 2.2
        xoffset 3
        pause 0.05
        xoffset -2
        pause 0.04
        xoffset 0
        pause 1.1
        xoffset -3
        pause 0.03
        xoffset 0
        repeat

transform phone_ring_pulse(d):
    alpha 0.0 zoom 0.8
    pause d
    block:
        alpha 0.6 zoom 0.8
        easeout 1.6 alpha 0.0 zoom 1.45
        repeat

transform phone_press:
    on idle:
        easein 0.12 zoom 1.0
    on hover:
        easein 0.12 zoom 1.07

transform phone_notify_in(x, y, z, nearest=False):
    subpixel True
    nearest nearest
    pos (x, y) zoom z
    on show:
        alpha 0.0 yoffset -40
        easein 0.25 alpha 1.0 yoffset 0
    on hide:
        easeout 0.25 alpha 0.0 yoffset -40

## ---------------------------------------------------------------------------------------------- shell

## The phone body: screen background, transcluded app content, header, status bar, overlay and the device art.
screen phone_shell(S, title="", sub=None, chat=None, header=True, bg="screen_bg", close=None, big_title=False):
    $ top = S.top + PHONE_STATUS_H + (PHONE_HEADER_H if header else 0)
    fixed:
        xysize S.dev
        fixed:
            pos S.scr
            xysize (PHONE_SW, PHONE_SH)
            add S.img(bg)
            fixed:
                ypos top
                xysize (PHONE_SW, PHONE_SH - top)
                at phone_clip(PHONE_SW, PHONE_SH - top)
                transclude
            if header:
                fixed:
                    ypos S.top + PHONE_STATUS_H
                    xysize (PHONE_SW, PHONE_HEADER_H)
                    add S.img("header")
                    if chat is not None:
                        add S.img("icon_back") xpos 14 yalign 0.5
                        add phone_avatar(chat, 52) xpos 58 yalign 0.5
                        vbox:
                            xpos 122 yalign 0.5
                            spacing 0
                            text phone_short(title, phone_chars(S, 260, S.name_size)) at (phone_glitch if S.glitch else phone_still):
                                font S.font_head size S.name_size color S.c["head_fg"] outlines S.outlines
                            if sub:
                                text sub font S.font_body size S.small color S.c.get("head_sub", S.c["sub_fg"])
                    else:
                        text title at (phone_glitch if S.glitch else phone_still):
                            font S.font_head size S.name_size + 6 color S.c["head_fg"] outlines S.outlines
                            yalign 0.5
                            xalign (0.0 if big_title else 0.5) xoffset (28 if big_title else 0)
                    if close is not None:
                        imagebutton:
                            idle S.img("icon_close")
                            hover S.img("icon_close")
                            xalign 1.0 xoffset -18 yalign 0.5
                            at phone_press
                            action close
            fixed:
                ypos 0
                xysize (PHONE_SW, S.top + PHONE_STATUS_H)
                if S.top:
                    add Transform(S.img("statusbar"), crop=(0, 0, 30, PHONE_STATUS_H), xysize=(PHONE_SW, S.top))
                add S.img("statusbar") ypos S.top
                text phone_clock():
                    font S.font size (16 if S.nearest else S.small + 1) color S.c["head_fg"]
                    xpos 40 ypos S.top yoffset (10 if S.nearest else 8)
            add S.img("overlay")
        add S.img("device")

## ---------------------------------------------------------------------------------------------- chat

screen phone_bubble(S, m, group):
    $ mine = m["mine"]
    $ bw = 300 if mine else 270
    hbox:
        xalign (1.0 if mine else 0.0)
        spacing 8
        if not mine:
            add phone_avatar(m["who"], 40) yalign 1.0 yoffset -22
        vbox:
            spacing 3
            if group and not mine:
                text m["who"] font S.font size S.small color phone_color(m["who"]) xoffset 10
            frame:
                xalign (1.0 if mine else 0.0)
                background S.frame("bubble_me" if mine else "bubble_them")
                padding (S.pad_me if mine else S.pad_them)
                xmaximum bw
                text m["text"]:
                    font S.font_body size S.size line_spacing S.line_spacing
                    color (S.c["text_me"] if mine else S.c["text_them"])
            text m["time"] font S.font_body size (16 if S.nearest else S.small) color S.c["time"] xalign (1.0 if mine else 0.0) xoffset (-6 if mine else 6)

screen phone_typing(S, who):
    hbox:
        spacing 8
        add phone_avatar(who, 40) yalign 1.0
        frame:
            background S.frame("bubble_them")
            padding S.pad_them
            hbox:
                spacing 7
                ysize max(S.size, 22)
                for k in range(3):
                    add S.img("dot") yalign 0.5 at phone_dot(k * 0.16)

screen phone_chat_screen(chat):
    tag phone
    zorder 50
    $ S = phone_theme()
    $ c = PHONE_CONTACTS.get(chat)
    $ group = c is not None and c.group
    $ msgs = phone_thread(chat)[-phone_config.keep:]
    $ typing = phone_data.typing
    if typing and (typing == chat or group):
        $ sub = (typing + " " if group else "") + S.label("typing")
    else:
        $ sub = (c.status if c is not None else "")
    fixed at phone_place(phone_zoom(S), phone_config.xalign, phone_config.yalign, S.nearest):
        xysize S.dev
        use phone_shell(S, chat, sub=sub, chat=chat):
            vbox:
                xpos 14 xsize PHONE_SW - 28
                yalign 1.0
                yoffset -(PHONE_INPUT_H + 10)
                spacing 10
                for k, m in enumerate(msgs):
                    if k == len(msgs) - 1:
                        fixed at phone_pop:
                            fit_first True
                            use phone_bubble(S, m, group)
                    else:
                        use phone_bubble(S, m, group)
                if typing:
                    fixed at phone_pop:
                        fit_first True
                        use phone_typing(S, typing)
            fixed:
                yalign 1.0
                xysize (PHONE_SW, PHONE_INPUT_H)
                add S.img("input_bar")
                text S.label("message") font S.font_body size S.size color S.c["sub_fg"] xpos 40 yalign 0.5

## ---------------------------------------------------------------------------------------------- contact list

screen phone_contacts_screen(names=None, title=None):
    tag phone
    zorder 50
    modal True
    $ S = phone_theme()
    $ names = names or phone_chats()
    $ pw = PHONE_SW - 32 - 70 - 70
    key "game_menu" action Return(None)
    fixed at phone_place(phone_zoom(S), phone_config.xalign, phone_config.yalign, S.nearest):
        xysize S.dev
        use phone_shell(S, title or S.label("chats"), close=Return(None), big_title=True):
            viewport:
                xysize (PHONE_SW, PHONE_SH - S.top - PHONE_STATUS_H - PHONE_HEADER_H)
                mousewheel True
                draggable True
                vbox:
                    xpos 10 xsize PHONE_SW - 20
                    spacing 4
                    null height 8
                    for n in names:
                        $ last = phone_thread(n)[-1:] or [None]
                        button:
                            xfill True
                            ysize 92
                            background None
                            hover_background S.frame("row_hover")
                            padding (12, 0, 12, 0)
                            action Return(n)
                            add phone_avatar(n, 62) xpos 0 yalign 0.5
                            vbox:
                                xpos 78 yalign 0.5
                                spacing 2
                                text phone_short(n, phone_chars(S, pw, S.name_size)) font S.font size S.name_size - 2 color S.c["card_fg"]
                                text phone_preview(n, phone_chars(S, pw, (16 if S.nearest else S.small + 2))):
                                    font S.font_body size (16 if S.nearest else S.small + 2) color S.c["sub_fg"]
                            vbox:
                                xalign 1.0 yalign 0.5
                                spacing 6
                                if last[0] is not None:
                                    text last[0]["time"] font S.font_body size (16 if S.nearest else S.small) color S.c["time"] xalign 1.0
                                if phone_unread(n):
                                    fixed:
                                        xysize (36, 36)
                                        xalign 1.0
                                        add S.img("badge")
                                        text str(phone_unread(n)) font S.font size (16 if S.nearest else 17) color S.c["badge_fg"] xalign 0.5 yalign 0.5 yoffset S.badge_dy
                        if S.divider:
                            add Solid(S.divider) xsize PHONE_SW - 120 ysize 1 xpos 90

## ---------------------------------------------------------------------------------------------- notification

screen phone_notify_screen(who, text):
    zorder 200
    $ S = phone_theme()
    $ x, y, z = phone_notify_pos(S)
    timer phone_config.notify_time action Hide("phone_notify_screen")
    frame at phone_notify_in(x, y, z, S.nearest):
        xsize PHONE_SW - 28
        background S.frame("notify")
        padding (22, 20, 22, 20)
        hbox:
            spacing 14
            add phone_avatar(who, 54) yalign 0.0
            vbox:
                spacing 2
                hbox:
                    xsize PHONE_SW - 28 - 44 - 54 - 14
                    text phone_short(who, 16) font S.font size S.size color S.c["notify_fg"] outlines S.outlines
                    text S.label("now") font S.font_body size (16 if S.nearest else S.small) color S.c["notify_sub"] xalign 1.0 yalign 0.5
                text phone_short(text, phone_chars(S, 2 * (PHONE_SW - 160))):
                    font S.font_body size (16 if S.nearest else S.size - 2) color S.c["notify_sub"]

## ---------------------------------------------------------------------------------------------- calls

## The incoming / outgoing call (modal, returns True or False).
screen phone_call_screen(who, incoming=True):
    tag phone
    zorder 50
    modal True
    if not incoming:
        timer phone_config.ring_time action Return(True)
    key "game_menu" action Return(False)
    use phone_call_body(who, incoming, False)

## A picked-up call with a running timer; the game goes on under it until phone_hang_up().
screen phone_incall_screen(who):
    tag phone
    zorder 50
    use phone_call_body(who, True, True)

screen phone_call_body(who, incoming, connected):
    $ S = phone_theme()
    fixed at phone_place(phone_zoom(S), phone_config.xalign, phone_config.yalign, S.nearest):
        xysize S.dev
        use phone_shell(S, header=False, bg="call_bg"):
            vbox:
                xalign 0.5 ypos 70
                spacing 16
                if connected:
                    add DynamicDisplayable(phone_call_seconds) xalign 0.5
                else:
                    text S.label("incoming" if incoming else "calling") font S.font_body size S.size color S.c["call_fg"] xalign 0.5
                text phone_short(who, phone_chars(S, 400, S.name_size + 12)) at (phone_glitch if S.glitch else phone_still):
                    font S.font_head size S.name_size + 12 color S.c["call_fg"] outlines S.outlines xalign 0.5
            fixed:
                xysize (240, 240)
                xalign 0.5 ypos 250
                if not connected:
                    for k in range(3):
                        add Transform(S.img("avatar_ring"), xysize=(240, 240)) at phone_ring_pulse(k * 0.55)
                add phone_avatar(who, 170) align (0.5, 0.5)
            hbox:
                xalign 0.5 ypos PHONE_SH - S.top - 36 - 220
                spacing 110
                imagebutton:
                    idle S.img("btn_decline")
                    hover S.img("btn_decline")
                    at phone_press
                    action (Function(phone_hang_up) if connected else Return(False))
                if incoming and not connected:
                    imagebutton:
                        idle S.img("btn_accept")
                        hover S.img("btn_accept")
                        at phone_press
                        action Return(True)

## ---------------------------------------------------------------------------------------------- feed

screen phone_post_card(S, i, p):
    $ cw = PHONE_SW - 32
    frame:
        xsize cw
        background S.frame("card")
        padding (20, 18, 20, 16)
        vbox:
            spacing 12
            hbox:
                spacing 12
                add phone_avatar(p["author"], 48)
                vbox:
                    yalign 0.5
                    text phone_short(p["author"], phone_chars(S, cw - 120, S.size)) font S.font size S.size color S.c["card_fg"]
                    text p["time"] font S.font_body size (16 if S.nearest else S.small) color S.c["time"]
            text p["text"] font S.font_body size S.size - (0 if S.nearest else 1) color S.c["card_fg"] line_spacing S.line_spacing
            if p["picture"] is not None:
                fixed:
                    xysize (cw - 40, 200)
                    viewport:
                        xysize (cw - 40, 200)
                        add Transform(p["picture"], fit="cover", xysize=(cw - 40, 200)) align (0.5, 0.5)
            hbox:
                spacing 8
                imagebutton:
                    idle S.img("icon_heart_on" if p["liked"] else "icon_heart")
                    hover S.img("icon_heart_on")
                    at phone_press
                    action Function(phone_like, i)
                text str(p["likes"]) font S.font_body size (16 if S.nearest else S.small + 2) color S.c["time"] yalign 0.5
                null width 18
                add S.img("icon_comment") yalign 0.5
                text str(p["comments"]) font S.font_body size (16 if S.nearest else S.small + 2) color S.c["time"] yalign 0.5

screen phone_feed_screen(title=None):
    tag phone
    zorder 50
    modal True
    $ S = phone_theme()
    key "game_menu" action Return(None)
    fixed at phone_place(phone_zoom(S), phone_config.xalign, phone_config.yalign, S.nearest):
        xysize S.dev
        use phone_shell(S, title or S.label("feed"), close=Return(None), big_title=True):
            viewport:
                xysize (PHONE_SW, PHONE_SH - S.top - PHONE_STATUS_H - PHONE_HEADER_H)
                mousewheel True
                draggable True
                vbox:
                    xpos 16
                    spacing 16
                    null height 2
                    for i, p in enumerate(phone_data.posts):
                        use phone_post_card(S, i, p)
                    null height 20

## ---------------------------------------------------------------------------------------------- labels

## call phone_chat("Mia", ["hey", ("me", "hi!")]) - shows the chat and plays the messages one by one:
## typing dots before every message of another person, then the message, then a click.
## Strings come from `who`; tuples are (sender, text) or (sender, text, "21:30"); sender "me" is the player.
## close=False keeps the chat on screen afterwards (hide it with $ phone_close()).
label phone_chat(who, messages=(), clock=None, typing=None, close=True):
    $ renpy.dynamic("_phone_i", "_phone_m")
    if clock:
        $ phone_set_clock(clock)
    $ phone_data.chat = who
    $ phone_mark_read(who)
    show screen phone_chat_screen(who)
    $ _phone_i = 0
    while _phone_i < len(messages):
        $ _phone_m = phone_entry(who, messages[_phone_i])
        if (phone_config.typing if typing is None else typing) and not _phone_m["mine"]:
            $ phone_data.typing = _phone_m["who"]
            $ renpy.pause(phone_typing_time(_phone_m["text"]))
            $ phone_data.typing = None
        $ phone_add(who, messages[_phone_i])
        $ renpy.pause()
        $ _phone_i += 1
    if close:
        $ phone_close()
    return

## call phone_contacts - the chat list; _return is the picked name, or None when the player closes it.
label phone_contacts(names=None, title=None):
    $ phone_data.chat = None
    call screen phone_contacts_screen(names, title)
    return _return

## call phone_call("Mia") - incoming call (accept / decline); call phone_call("Mia", incoming=False) - the player
## calls and it is picked up after phone_config.ring_time seconds (or hung up). _return: True or False.
## When the call is picked up, the call screen stays with a running timer until $ phone_hang_up().
label phone_call(who, incoming=True):
    $ phone_data.chat = None
    hide screen phone_notify_screen
    call screen phone_call_screen(who, incoming)
    if _return:
        $ phone_data.call = who
        show screen phone_incall_screen(who)
        return True
    return False

## call phone_feed([("Theo", "New song out!", 24, 3, "2h")]) - the social feed; without posts it shows the posts
## added with phone_post(). The player can like posts and closes the feed.
label phone_feed(posts=None, title=None):
    if posts is not None:
        $ phone_data.posts = [phone_post_entry(p) for p in posts]
    $ phone_data.chat = None
    call screen phone_feed_screen(title)
    return
