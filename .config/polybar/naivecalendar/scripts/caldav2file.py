#!/usr/bin/env python3

"""
Still in dev. Put me in $HOME/.config/naivecalendar/scripts/

This script get caldav events from an online account (1) and
save it into files so it can shown up in naivecalendar

(1) : launch this script to create a config file at::

    "$HOME/.naivecalendar/caldav_user.json"

and fill it with your account infos::


    {
        "url": "url,
        "user": "user",
        "password": "password",
        "calendar_name": "calendar_name"   <-- optional (keep empty)
    }


Launch it again tu download your events.
"""

import os
import sys
import json

import caldav


class default:
    def __init__(self):
        self.value = ""
DEFAULT = [default()]

def err_msg(txt):
    print(len(txt)*'*', f'\n{txt}\n', len(txt)*'*', file=sys.stderr)

def tab(s):
    """indent multiline text"""
    s = s.split("\n")
    s = [f" {l}" for l in s]
    s = "\n".join(s)
    return s

#######################
### Get caldav conf ###
#######################

HOME = os.getenv("HOME")
CONF_PATH = f"{HOME}/.config/naivecalendar/caldav_user.json"
EVENT_PATH = f"{HOME}/.naivecalendar_events/CalDav"

if os.path.exists(CONF_PATH):
    with open(CONF_PATH, "r") as f:
        conf = json.load(f)
else:
    default_conf = {"url": "", "user": "", "password": "", "calendar_name": ""}
    with open(CONF_PATH, "w") as f:
        conf = f.write(json.dumps(default_conf, indent=4))

    err_msg(f"please fill {CONF_PATH} to connect your caldav account")
    exit(0)


########################################
### Ask caldav server and get events ###
########################################

try:
    client = caldav.DAVClient(
        url=conf["url"], username=conf["user"], password=conf["password"]
    )
    principal = client.principal()
    cal = principal.calendar(name=conf['calendar_name'])
    events = cal.events()

except Exception as e:
    err_msg(f"Please check your caldav account informations at:\n{CONF_PATH}")
    raise e


#####################
### Format events ###
#####################

events_by_day = dict()

for event in events:
    vobj = event.vobject_instance
    contents = vobj.contents["vevent"][0].contents

    day_event = dict()

    day_event["summary"] = contents.setdefault("summary", DEFAULT)[0].value
    day_event["description"] = contents.setdefault("description", DEFAULT)[0].value
    day_event["location"] = contents.setdefault("location", DEFAULT)[0].value

    dtstart = contents["dtstart"][0].value
    day = dtstart.strftime("%y-%m-%d")
    day_event["time_start"] = dtstart.strftime("%Hh%M")

    # dtend = contents['dtend'][0].value
    # day_event['day_end'] = dtend.strftime('%y-%m-%d')
    # day_event['time_end'] = dtend.strftime('%Hh%M')

    events_by_day[day] = events_by_day.setdefault(day, []) + [day_event]

######################
### write to files ###
######################


for day, day_events in events_by_day.items():

    day_events_sorted = sorted(day_events, key=lambda k: k["time_start"])

    text = ""
    for event in day_events_sorted:
        text += f"[{event['time_start']}] {event['summary']}\n"
        if event["location"]:
            text += f"location :\n{tab(event['location'])}\n"
        if event["description"]:
            text += f"description :\n{tab(event['description'])}\n"
        text += "\n"

    with open(f"{EVENT_PATH}/{day}.txt", "w") as f:
        f.write(text)
