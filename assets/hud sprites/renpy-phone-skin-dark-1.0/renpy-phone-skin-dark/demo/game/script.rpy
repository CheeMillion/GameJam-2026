## Demo of the Midnight phone skin (Ren'Py Phone Skins).
## Every call used here is explained in README.md.

image bg demo = "images/bg_demo.png"

init python:
    phone_contact('Mia', status='online')
    phone_contact('Theo', status='last seen 22:41')
    phone_contact('Study Club', status='4 members', group=True)
    phone_contact('June', status='at work')
    phone_contact('Mom', status='online')
    phone_contact('Leo', status='new number')

label start:
    scene bg demo
    with dissolve
    "Late at night. My phone buzzes."
    $ phone_history('Study Club', [('Theo', 'did anyone finish the essay?', '21:02'), ('June', 'lol no', '21:05')])
    $ phone_history('June', [('June', 'movie on sunday?', '19:40')])
    $ phone_history('Mom', [('Mom', 'did you eat dinner?', '18:55')])
    call phone_chat("Mia", [
        'you up?',
        ('me', "can't sleep. you?"),
        ('Mia', 'someone is parked outside my place'),
        ('Mia', 'same car as yesterday'),
        ('me', 'call the police. now.'),
        'I think they saw me at the window',
    ], clock='23:12')
    "I read the last message three times."
    $ phone_notify('Theo', 'hey, did Mia text you too?', unread=True)
    "Another message. I open my chats."
    call phone_contacts
    if _return:
        call phone_chat(_return, close=False)
        "I put the phone down."
        $ phone_close()
    call phone_call("Theo")
    if _return:
        "Theo" "So she told you too."
        $ phone_hang_up()
    else:
        "I let it ring."
    "Before I sleep, I scroll through the feed."
    call phone_feed([
        ('Mia', 'City lights from the roof tonight.', 212, 18, '1h', 'images/pic_a.png'),
        ('Theo', 'Night shift again. Coffee number four.', 37, 5, '3h', None),
        ('June', 'Who else is awake at 2 am?', 56, 21, '6h', 'images/pic_b.png'),
    ])
    "End of the demo. README.md lists every call and setting."
    return
