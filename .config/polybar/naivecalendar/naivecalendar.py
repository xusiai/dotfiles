#!/usr/bin/env python3
"""
A simple calendar made with rofi and python3.

Cycle through month and create linked event to days.
"""

__author__ = "Daguhh"
__license__ = "MIT-0"
__status__ = "Released"
__version__ = "2.0.1"

import glob, os, sys, subprocess, shutil
from pathlib import Path
import re, argparse, configparser
import datetime, calendar, locale
from itertools import chain
from functools import wraps
import time

#START = time.time()

def get_arguments():
    """Parse command line arguments

    Returns
    -------
    args : argparse.Namespace
        command line arguments
    unknown : str
        rofi output
    """

    parser = argparse.ArgumentParser(
        prog="naivecalendar",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description='''A simple popup calendar

subcommands:
    update-themes   Update a calendar parameter for all user themes at once
    add-event       Add, modify, delete event in all user themes config at once
    configure       Clone or open configuration files'''
    )

    parser.add_argument(
        '-V',
        '--version',
        action='version',
        version="%(prog)s " + __version__
    )

    parser.add_argument(
        '-v',
        '--verbose',
        help="direct rofi error to stdout",
        action="store_true",
    )
    parser.add_argument(
        "-p",
        "--print",
        help="print date to stdout instead of opening a event",
        action="store_true",
    )

    parser.add_argument(
        "-x",
        "--clipboard",
        help="copy date to clipboard",
        action="store_true",
    )

    parser.add_argument(
        "-f",
        "--format",
        help="""option '-p' or '-x' output format (datetime.strftime format, defaut='%%Y-%%m-%%d')""",
        dest="format",
        default="%Y-%m-%d",
    )

    parser.add_argument(
        "-e",
        "--editor",
        help="""editor command to open events""",
        dest="editor",
        default="xdg-open",
    )

    parser.add_argument(
        "-l",
        "--locale",
        help="""force system locale, for example '-l es_ES.utf8'""",
        dest="locale",
        default="",
    )

    parser.add_argument(
        "-c",
        "--read-cache",
        dest="is_force_read_cache",
        action="store_true",
        help="""force calendar to read old date from cache"""
    )

    parser.add_argument(
        "-t",
        "--theme",
        help="""set calendar theme, default=classic_dark_extended (theme file name without extention)""",
        dest="theme",
        default=False
    )

    parser.add_argument(
        "-d",
        "--date",
        help="""display calendar at the given month, format='%%m-%%Y'""",
        dest="date",
        default=False
    )

    args, unknown = parser.parse_known_args()
    unknown = unknown if len(unknown) == 0 else "".join(unknown).strip(' ')

    return args, unknown


# get command line arguments and if exist : rofi output
ARGS, ROFI_OUTPUT = get_arguments()

# Global var :
EMPTY = -1
ROFI_RELOAD_TEMPO = 0.2

######################
### Path constants ###
######################
HOME = Path.home()
DIRNAME = Path(__file__).parent.absolute()

# cache files
CACHE_PATH = HOME / ".cache/naivecalendar"
DATE_CACHE = CACHE_PATH / "date_cache.ini"
PP_CACHE = CACHE_PATH / "pretty_print_cache.txt"
THEME_CACHE = CACHE_PATH / "theme_cache.txt"
EVENT_CACHE = CACHE_PATH / "event_cache.txt"

# config files
CONFIG_PATH = HOME / ".config/naivecalendar"

THEME_PATHS = {
    'user' : CONFIG_PATH / "themes",
    'rel' : DIRNAME / "themes"
}
SCRIPT_PATHS = {
    'user' : CONFIG_PATH / "scripts",
    'rel' : DIRNAME / "scripts"
}
EVENT_FILES = {
    'user' : CONFIG_PATH / "global/events.cfg",
    'rel' : DIRNAME / "global/events.cfg"
}
CUSTOM_ACTION_FILES = {
    'user' : CONFIG_PATH / "global/custom_actions.cfg",
    'rel' : DIRNAME / "global/custom_actions.cfg"
}


#######################################
### load a theme configuration file ###
#######################################

# get wanted theme
theme = "classic_dark_extended"
if ARGS.theme:
    theme = ARGS.theme
else:
    if THEME_CACHE.exists():
        with open(THEME_CACHE, 'r') as theme_cache:
            theme = theme_cache.read()

# look for theme in config paths
if (THEME_PATHS['user'] / f"{theme}.cfg").exists():
    theme_path = THEME_PATHS['user']
else:
    theme_path = THEME_PATHS['rel']

THEME_CONFIG_FILE = theme_path / f"{theme}.cfg"
THEME_RASI_FILE = theme_path / f"{theme}.rasi"


########################
### Load config file ###
########################
# -T-heme config
cfg_t = configparser.ConfigParser(interpolation=None)
cfg_t.read(THEME_CONFIG_FILE)

# -E-vent config
cfg_e = configparser.ConfigParser(interpolation=None)
if EVENT_FILES['user'].exists():
    cfg_e.read(EVENT_FILES['user'])
elif EVENT_FILES['rel'].exists():
    cfg_e.read(EVENT_FILES['rel'])
else:
    cfg_e['EVENTS'] = {'Notes' : '.naivecalendar_events/MyNotes/note_%Y-%m-%d.txt'}

# custom -A-ction config
cfg_a = configparser.ConfigParser(interpolation=None)
if CUSTOM_ACTION_FILES['user'].exists():
    cfg_a.read(CUSTOM_ACTION_FILES['user'])
else:
    cfg_a.read(CUSTOM_ACTION_FILES['rel'])


###########################
### Get last event type ###
###########################
try:
    with open(EVENT_CACHE, 'r') as event_cache:
        EVENTS_DEFAULT = event_cache.read()
    try :
        cfg_e['EVENTS'][EVENTS_DEFAULT]
    except KeyError:
        #print(f'no event "{EVENTS_DEFAULT}" found', file=sys.stderr)
        EVENTS_DEFAULT = ''
except FileNotFoundError:
    #print(f'no event file "{EVENT_CACHE}" found', file=sys.stderr)
    EVENTS_DEFAULT = ''

############################
### Load user parameters ###
############################

# Some Functions
################
# Functions to parse list and int from configparser
def strip_list(lst):
    """strip all element in a list"""
    return [x.strip() for x in lst]

def to_list(cfg_list):
    """convert string with comma separated elements into python list"""
    # align all elements to right
    return [DAY_FORMAT.format(word) for word in cfg_list.split(',')]

def set_list(default, section, key, row):
    """set, set default or desactivate given user config """
    vals = section[key]
    if row == EMPTY: # don't display row
        return []
    elif vals == '': # use default vals
        return [DAY_FORMAT.format(s) for s in default]
    elif key == 'SYMS_DAYS_NUM':
        return to_list(vals)
    else: # parse config values
        return [CONTROL_MENU_ID[x.strip()] if x.strip() in CONTROL_MENU_ID.keys() else x for x in to_list(vals)]

# def old_conf_file_compat(key):
#     dct = {
#         'ROW_CONTROL_MENU' : 'ROW_BAR_1',
#         'ROW_SHORTCUTS' : 'ROW_BAR_2',
#         'SYMS_CONTROL_MENU' : 'SYMS_BAR_1',
#         'SYMS_SHORTCUTS' : 'SYMS_BAR_2'
#     }
#
#     return dct.setdefault(key, key)

def to_int(section, key):
    """Convert a configparser entry into an int"""
    val = section[key]
    if val == '':
        val = EMPTY
    else:
        try:
            val = int(val)
        except ValueError as e:
            print(40*'*'+f"\nwarning : wrong value '{val}' for '{key}'.\nShould be an interger or an empty value.\n"+40*'*', file=sys.stderr)
            raise e
    return val

def to_path(path_str, parent=HOME):
    """make path relative to home or absolute"""

    path = Path(path_str)

    if path.is_absolute():
        return path
    else:
        return parent / path

# week days symbols : can be changed by locale
def set_locale_n_week_day_names(arg_locale, user_locale, day_format, first_day_week, day_abbr_lenght):
    """ Set SYMS_WEEK_DAYS constante given command line argument """

    if arg_locale: # locale overwrited by user
        locale.setlocale(locale.LC_ALL, arg_locale)
    else: # system locale
        locale.setlocale(locale.LC_ALL, user_locale)

    def get_loc_day(day_num, lenght):
        """return locale day names truncated at lenght and titlized"""
        return locale.nl_langinfo(locale.DAY_1 + day_num)[:lenght].title()

    days_order = chain(range(first_day_week, 7), range(0, first_day_week))

    sym_week_days = [day_format.format(
        get_loc_day(day_num, day_abbr_lenght)
    ) for day_num in days_order]

    return sym_week_days

# cfg_ture  locate
###################
USER_LOCALE = cfg_t['LOCALE']["USER_LOCALE"] # use 'locale -a' on your system to list locales

# Day names abbreviations
#########################
DAY_ABBR_LENGHT = int(cfg_t['DAY NAMES']["DAY_ABBR_LENGHT"]) # ex : 3 => Mon
DAY_FORMAT = '{:>' + str(max(DAY_ABBR_LENGHT,2)) + '}' # align symbols right
FIRST_DAY_WEEK = int(cfg_t['DAY NAMES']["FIRST_DAY_WEEK"]) # 0 = sunday, 1 = monday...

# Day events configuration
##########################
EVENTS_PATHS = {n:to_path(cfg_e['EVENTS'][n]) for n in cfg_e['EVENTS']}
# default date events folder to display
EVENTS_DEFAULT = EVENTS_DEFAULT if EVENTS_DEFAULT != '' else next(EVENTS_PATHS.keys().__iter__()) #cfg['DEFAULT'].lower()

# Rofi/Calendar shape
#####################
NB_COL = 7
NB_WEEK = 6 # nb row of calendar "days number" part
#NB_ROW = int(cfg_t['SHAPE']['NB_ROW'])

# Calendar symbols and shortcuts
################################
SYM_NEXT_MONTH = to_list(cfg_t['CONTROL']['SYM_NEXT_MONTH'])
SYM_NEXT_YEAR = to_list(cfg_t['CONTROL']['SYM_NEXT_YEAR'])
SYM_PREV_MONTH = to_list(cfg_t['CONTROL']['SYM_PREV_MONTH'])
SYM_PREV_YEAR = to_list(cfg_t['CONTROL']['SYM_PREV_YEAR'])

# Shortcuts for popup windows
#############################
SYM_SHOW_EVENTS = to_list(cfg_t['SHORTCUTS']['SYM_SHOW_EVENTS'])
SYM_SHOW_HELP = to_list(cfg_t['SHORTCUTS']['SYM_SHOW_HELP'])
SYM_SWITCH_THEME = to_list(cfg_t['SHORTCUTS']['SYM_SWITCH_THEME'])
SYM_SWITCH_EVENT = to_list(cfg_t['SHORTCUTS']['SYM_SWITCH_EVENT'])
SYM_SHOW_MENU = to_list(cfg_t['SHORTCUTS']['SYM_SHOW_MENU'])
SYM_GO_TODAY = to_list(cfg_t['SHORTCUTS']['SYM_GO_TODAY'])

# Custom Functions
##################
CUSTOM_ACTIONS = {s:{'sym':to_list(cfg_a[s]['sym']), 'cmd':to_list(cfg_a[s]['cmd'])} for s in cfg_a.sections()}

# Today header display
######################
PROMT_DATE_FORMAT = cfg_t['HEADER']['PROMT_DATE_FORMAT']
IS_TODAY_HEAD_MSG = cfg_t.getboolean('HEADER', 'IS_TODAY_HEAD_MSG')
IS_LOOP_TODAY_HEAD_MSG = cfg_t.getboolean('HEADER', 'IS_LOOP_TODAY_HEAD_MSG')

# pango markup props
TODAY_HEAD_MSG_TXT = cfg_t['HEADER']['TODAY_HEAD_MSG_TXT']

# Calendar content and organisation
###################################
# row number where to display day symbols
ROW_DAY_NAMES = to_int(cfg_t['CONTENT'], 'ROW_DAY_NAMES')
# symbols for week day names
#_syms_week_days = to_list(cfg_t['CONTENT']["SYMS_WEEK_DAYS"]) if not ROW_DAY_NAMES == EMPTY else []
SYMS_WEEK_DAYS = set_locale_n_week_day_names(ARGS.locale, USER_LOCALE, DAY_FORMAT, FIRST_DAY_WEEK, DAY_ABBR_LENGHT)

# row number where to display calendar first line
ROW_CAL_START = to_int(cfg_t['CONTENT'], 'ROW_CAL_START')
# symbols for day numbers
#default = (str(x) for x in range(1,32))
#SYMS_DAYS_NUM= set_list(default, cfg_t['CONTENT'], 'SYMS_DAYS_NUM', ROW_CAL_START)
SYMS_DAYS_NUM = [str(x) for x in range(1,32)]


CONTROL_MENU_ID = {
    'p' : SYM_PREV_MONTH[0],
    'pp': SYM_PREV_YEAR[0],
    'n' : SYM_NEXT_MONTH[0],
    'nn': SYM_NEXT_YEAR[0],
    'h' : SYM_SHOW_HELP[0],
    't' : SYM_SWITCH_THEME[0],
    'e' : SYM_SHOW_EVENTS[0],
    's' : SYM_SWITCH_EVENT[0],
    'm' : SYM_SHOW_MENU[0],
    'bb': SYM_GO_TODAY[0],
    **{s:v['sym'][0] for s,v in CUSTOM_ACTIONS.items()}
}

# row number where to display buttons
ROW_BAR_1 = to_int(cfg_t['CONTENT'], 'ROW_BAR_1')
# symbols for control menu row
default = (s[0] for s in (SYM_PREV_YEAR, SYM_PREV_MONTH, ' ', SYM_SHOW_MENU, ' ', SYM_NEXT_MONTH, SYM_NEXT_YEAR))
SYMS_BAR_1 = set_list(default, cfg_t['CONTENT'], 'SYMS_BAR_1', ROW_BAR_1)

# row number where to display shortcuts buttons
ROW_BAR_2 = to_int(cfg_t['CONTENT'], 'ROW_BAR_2')
# symbols to display in shortcuts row
default = (s[0] for s in (SYM_SHOW_HELP, SYM_SWITCH_THEME, SYM_SHOW_EVENTS, SYM_SWITCH_EVENT, ' ', ' ', SYM_SHOW_MENU))
SYMS_BAR_2 = set_list(default, cfg_t['CONTENT'], 'SYMS_BAR_2', ROW_BAR_2)

NB_ROW = int(bool(SYMS_BAR_2)) + int(bool(SYMS_BAR_1)) + int(bool(SYMS_WEEK_DAYS)) + 6

##############
### Script ###
##############

def main(args, rofi_output):
    """Print calendar to stdout and react to rofi output"""

    # create event path n test rofi intall
    first_time_init()

    is_first_loop = not bool(rofi_output)
    if isinstance(rofi_output, str):
        out = DAY_FORMAT.format(rofi_output) # rofi strip blank character so reformat
    else:
        out = 'Nothing'

    cdate = CacheDate() # manage operation and writing to cache
    cdate = set_date(cdate, is_first_loop, args.is_force_read_cache, args.date)
    cdate, is_match = process_event_date(cdate, out, args)

    update_rofi(cdate.date, is_first_loop)
    cdate.write_cache()
    if not is_match: # don't test if out already match one condition in process_event_date
        process_event_popup(out, cdate)


def set_date(cdate, is_first_loop, is_force_read_cache, arg_date):
    """set date given context

    (read cache, get today date or set date argument)

    Parameters
    ----------
    is_first_loop : bool
        true on first calendar call
    is_force_read_cache : bool
        force date from cache
    arg_date : str
        date in '%m%Y' format

    Returns
    -------
    CacheDate
       CacheDate object that contain the date to display
    """

    if not is_first_loop or is_force_read_cache:
        cdate.read_cache() # read previous date
    elif is_first_loop and arg_date:
        cdate.set_month(arg_date) # command line force date
    else: # at first loop if no force option
        cdate.now()

    return cdate


def process_event_date(cdate, out, args):
    """React to rofi output for "date" events

    Parameters
    ----------
    cdate : CacheDate
        current month
    out : str
        rofi output
    args : argparse.Namespace
        print, clipboard, format, editor arguments

    Returns
    -------
    CacheDate
        new month to display
    """

    is_match = True
    out = out.strip()
    if out in strip_list(SYM_PREV_YEAR):
        cdate.year -= 1
    elif out in strip_list(SYM_PREV_MONTH):
        cdate.month -= 1
    elif out in strip_list(SYM_NEXT_MONTH):
        cdate.month += 1
    elif out in strip_list(SYM_NEXT_YEAR):
        cdate.year += 1
    elif out in strip_list(SYMS_DAYS_NUM):
        set_pp_date(out, cdate.date, args.format)
        if args.print or args.clipboard:
            sys.exit(0)
        else:
            open_event(out, cdate.date, args.editor)
    elif out in strip_list(SYM_GO_TODAY):
        cdate.now()
    else:
        is_match = False

    return cdate, is_match


def process_event_popup(out, cdate):
    """React to rofi event hat open a popup window

    Parameters
    ----------
    out : str
        rofi output
    cdate : CacheDate
        current month
    """

    out = out.strip()
    if out in strip_list(SYM_SHOW_EVENTS):
        show_events(cdate.date)
    elif out in strip_list(SYM_SHOW_HELP):
        display_help()
    elif out in strip_list(SYM_SWITCH_THEME):
        ask_theme()
    elif out in strip_list(SYM_SWITCH_EVENT):
        ask_event_to_display()
    elif out in strip_list(SYM_SHOW_MENU):
        show_menu(cdate)
    elif out in strip_list(SYM_GO_TODAY):
        cdate.now()
        cdate.write_cache()
    else:
        for sym_act, cmd_act in ((act['sym'], act['cmd']) for act in CUSTOM_ACTIONS.values()):
            if out in strip_list(sym_act):
                execute_external_cmd(cmd_act)
                break


def update_rofi(date, is_first_loop):
    """generate and send calendar data to stdout/rofi

    It use the rofi `custom script mode <https://github.com/davatorium/rofi/wiki/mode-Specs>`_ to communicate with rofi
    and `pango markup <https://developer.gnome.org/pygtk/stable/pango-markup-language.html>`_ for theming

    Parameters
    ----------
    date : datetime.date
        A day of the month to display
    is_first_loop : bool
        True on first loop, if true, update today highlights
    """

    date_prompt = date.strftime(PROMT_DATE_FORMAT).title()
    print(f"\0prompt\x1f{date_prompt}\n")

    events_inds = get_month_events_ind(date)
    print(f"\0urgent\x1f{events_inds}\n")

    if is_first_loop or IS_LOOP_TODAY_HEAD_MSG:
        today_ind = cal2rofi_ind(date.day, date.month, date.year)
        print(f"\0active\x1f{today_ind}\n")
        if IS_TODAY_HEAD_MSG:
            msg = date.strftime(TODAY_HEAD_MSG_TXT)
            print(f"\0message\x1f{msg}\n")

    if not ROW_DAY_NAMES == EMPTY:
        week_sym_row = get_row_rofi_inds(ROW_DAY_NAMES)
        print(f"\0active\x1f{week_sym_row}\n")

    if not ROW_BAR_1 == EMPTY:
        control_sym_row =get_row_rofi_inds(ROW_BAR_1)
        print(f"\0active\x1f{control_sym_row}\n")

    if not ROW_BAR_2 == EMPTY:
        shortcut_sym_row = get_row_rofi_inds(ROW_BAR_2)
        print(f"\0active\x1f{shortcut_sym_row}\n")

    cal = get_calendar_from_date(date)
    print(cal)


def get_calendar_from_date(date):
    r"""Return a montly calendar given date

    Calendar is a string formated to be shown by rofi (i.e. column bu column)::

                 L  M  M  J  V  S  D
                                   1
                 2  3  4  5  6  7  8
      date  ->   9 10 11 12 13 14 15   ->   'L\n \n2\n9\n16\n23\n30\n<\nM\n \n3\n10\n17\n24\n...'
                16 17 18 19 20 21 22
                23 24 25 26 27 28 29
                30

    Parameters
    ----------
    date : datetime.date
        Any day of the month to display

    Returns
    -------
    str
        A str that contain chained columns of a calendar in a rofi format

    """

    start_day, month_length = calendar.monthrange(date.year, date.month)

    # init calendar with NB_WEEK blank week
    cal = [" "] * NB_WEEK * NB_COL

    # fill with day numbers
    ind_first_day = (start_day - (FIRST_DAY_WEEK - 1)) % 7
    ind_last_day = ind_first_day + month_length
    cal[ind_first_day : ind_last_day] = SYMS_DAYS_NUM[:month_length]

    # join calendar parts given user order
    index = (ROW_DAY_NAMES, ROW_CAL_START, ROW_BAR_1, ROW_BAR_2)
    content = [SYMS_WEEK_DAYS, cal, SYMS_BAR_1, SYMS_BAR_2]
    index, content = (list(x) for x in zip(*sorted(zip(index, content))))

    # transform
    cal = list(chain(*content)) # row-by-row list
    cal = list_transpose(cal) # col-by-col list
    cal = list2rofi(cal) # rofi formated

    return cal


def list_transpose(lst, col_nb=NB_COL):
    """
    Transpose (math) a row by row list into column by column list
    given column number

    Parameters
    ----------
    lst : list
        row by row elements
    col_nb : int
        number of column to display

    Returns
    -------
    list
        A list that represent column by column elements

    Examples
    --------
    >>> my_list = [1,2,3,4,5,6]
    >>> list_transpose(my_list, col_nb=3)
    [1,4,2,5,3,6]

    """

    # split into row
    iter_col = range(len(lst) // col_nb)
    row_list = [lst[i * col_nb : (i + 1) * col_nb] for i in iter_col]

    # transpose : take 1st element for each row, then 2nd...
    iter_row = range(len(row_list[0]))
    col_list = [[row[i] for row in row_list] for i in iter_row]

    # chain columns
    lst = list(chain(*col_list))

    return lst


def list2rofi(datas):
    """
    Convert python list into a list formatted for rofi

    Parameters
    ----------
    datas : list
        elements stored in a list

    Returns
    -------
    str
        elements separated by line-breaks

    Examples
    --------

    >>> my_list = [1,2,3,4,5,6]
    >>> list2rofi(my_list]
    "1\\n2\\n3\\n4\\n5\\n6"
    """

    return "\n".join(datas)


def rofi2list(datas):
    """
    Convert list formatted for rofi into python list object

    Parameters
    ----------
    datas : str
        a string with element separeted by line-breaks

    Returns
    -------
    list
        elements of datas in a list

    Examples
    --------

    >>> rofi_list = "1\\n2\\n3\\n4\\n5\\n6"
    >>> rofi2list
    [1,2,3,4,5,6]
    """

    return datas.split("\n")


def parse_month_events_files(date):
    """
    Return a list of file's first line of a specific month

    Parameters
    ----------
    date : datetime.date
        Any day of the month to display

    Returns
    -------
    str
        A rofi formatted list of month's events first line
    str
        Rows to highlight (date header)
    """

    # paths
    events_paths = get_month_events(date)

    if not events_paths:
        return "No events this month", 0
    else:
        # first line
        heads = [parse_event_file(n) for n in events_paths]
        # file name
        prompts = [Path(n).stem for n in events_paths]
        # sort by file name (usually by date)
        prompts, heads = (list(x) for x in zip(*sorted(zip(prompts, heads))))

        prompts_pos = [0]
        for head in heads[:-1]:
            prompts_pos += [prompts_pos[-1] + len(head.split('\n'))]
        prompts_pos = ','.join(str(x) for x in prompts_pos)

        # return : <file_name> : <first line> for each event
        text = "\n".join([f"{p} : {h}" for p, h in sorted(zip(prompts, heads))])

        return text, prompts_pos


def parse_event_file(event_path):
    """Parse event file for compact display

    **Event format:**

    - Section ::

        [9H30] rdv with truc <---- will be displayed
        Some text
        Some text again
        [14H30] rdv with muche <----- will be displayed
        Some text again again

    - header ::

        # Note Title  <---- only first line is displayed
        Some text
        Some text again...

    Parameters
    ----------
    event_path : str
        A text file path

    Returns
    -------
    str
        Parsed lines
    """

    with open(event_path, "r") as f:
        note_txt = f.read()

    # get lines with [section]
    head = list(re.findall('\[.*\].*', note_txt))

    if head: # if sections
        return '\n' + '\n'.join(head) # join them into multilines
    else: # otherwise
        return '\n' + note_txt.split("\n")[0] # get first line


def get_row_rofi_inds(row):
    """Get all rofi index of a row

    Parameters
    ----------
    row : int
        row number (start at 0)

    Returns
    -------
    str
        a ',' separate list of rofi indexes
    """

    return ",".join(str(i * NB_ROW + row) for i in range(NB_COL))



def cal2rofi_ind(day, month, year):
    """
    Convert calendar date into coordinates for rofi

    Parameters
    ----------
    day : int
        A day number (1-31)
    month : int
        A month number (1-12)
    year : int
        A year number

    Returns
    -------
    int
        A rofi index
    """

    # day number area offset in calendar
    cal_offset = NB_COL * ROW_CAL_START

    # offset due to first month day
    start_day, _ = calendar.monthrange(year, month)
    # and correct by day starting the week
    ind_start_day = (start_day - (FIRST_DAY_WEEK - 1)) % 7

    # make month start at 0
    day = int(day) - 1

    # row-by-row index
    ind_r = cal_offset + day + ind_start_day
    # calendar coordinate
    row, col = ind_r // NB_COL, ind_r % NB_COL
    # rofi coordinate (column-by-column index)
    ind_c = col * NB_ROW + row

    return ind_c


def get_month_events(date):
    """
    Return events files paths that are attached to date's month

    Parameters
    ----------
    date : datetime.date
        Any day of the month displayed

    Returns
    -------
    list
        list of files that belong to date.month
    """

    # folder of the actual watched events
    path = EVENTS_PATHS[EVENTS_DEFAULT]

    # transform all directive  '< montth'  into regex
    # "%a-%d-%b-%m-%Y" --> "[a-zA-Z.]*-[0-9]*-%b-%m-%Y"
    file_pattern = re.sub('%-{0,1}[dwjhHIMSfzZ]', '[0-9]*', str(path))
    file_pattern = re.sub('%[aAp]', '[a-zA-Z.]*', file_pattern)

    # format all others directives (>= month) with date
    # "[a-zA-Z.]*-[0-9]*-%b-%m-%Y" --> "[a-zA-Z.]*-[0-9]*-Jan.-01-2021"
    file_pattern = date.strftime(file_pattern) #f"{date.year}-{date.month}-"

    # return all elements that belong to current month (match previous regex)
    path = Path(file_pattern)
    events_paths = list(Path(path.parent).glob(path.name))

    return events_paths


def get_month_events_ind(date):
    """
    Return rofi-formatted index of days with attached event

    Parameters
    ----------
    date : datetime.date
        Any day of the month displayed

    Returns
    -------
    str
        Column index list formatted for rofi
    """

    # get file list
    events_paths = get_month_events(date)
    # event name
    date_format = EVENTS_PATHS[EVENTS_DEFAULT].name
    # make capture group for day number (%d)
    pattern = re.sub('%d',r'([0-9]*)', date_format)
    # create pattern for directives < month
    pattern = re.sub('%-{0,1}[dwjhHIMSfzZ]',r'[0-9]*', pattern)
    pattern = re.sub('%[aAp]',r'[a-zA-Z.]*', pattern)
    # replace other (>= month) with real date
    pattern = date.strftime(pattern)
    # match the day (%d) capture group for each event in events_paths
    days = [re.match(pattern, f.name).group(1) for f in events_paths]
    # transform into rofi index
    inds = [cal2rofi_ind(int(d), date.month, date.year) for d in days]
    # format into rofi command
    inds = ",".join([str(i) for i in inds])

    return inds

# Count recursive call from open_n_reload_rofi
# and prevent relaunching rofi if it's already planned
ROFI_RELAUNCH_COUNT = 0

def open_n_reload_rofi(func):
    """ decorator to open and reload the rofi script at the same date"""

    script_path = DIRNAME# os.path.abspath(os.path.dirname(sys.argv[0]))

    @wraps(func)
    def wrapper(*args, **kwargs):

        global ROFI_RELAUNCH_COUNT

        ROFI_RELAUNCH_COUNT += 1
        subprocess.Popen(["pkill", "-9", "rofi"])
        time.sleep(ROFI_RELOAD_TEMPO)

        out = func(*args)

        ROFI_RELAUNCH_COUNT -= 1
        if ROFI_RELAUNCH_COUNT == 0:
            time.sleep(ROFI_RELOAD_TEMPO)
            #cmd_args = ' '.join(sys.argv[1:-1])
            cmd_args = sys.argv[1:-1] # 1 = command name, -1 = rofi outpub
            cmd = (str(DIRNAME / "naivecalendar.sh"), '-c', *cmd_args)
            #os.system(cmd)
            subprocess.Popen(cmd)

        return out

    return wrapper


@open_n_reload_rofi
def show_events(date):
    """open rofi popup with events list of selected month

    Parameters
    ----------
    date : datetime.date
        current month
    """

    # Show month events
    parsed_events, prompts_pos = parse_month_events_files(date)
    output = rofi_popup(EVENTS_DEFAULT, parsed_events, highlights=prompts_pos, nb_lines=10)

    # open event file of selected day
    event= EVENTS_PATHS[EVENTS_DEFAULT]

    event_folder = date.strftime(str(event.parent))
    event_name = output.split(':')[0].strip()
    event_ext = event.suffix

    event_path = f'{event_folder}/{event_name}{event_ext}'

    if os.path.isfile(event_path):
        edit_event_file(event_path)


@open_n_reload_rofi
def show_menu(cdate):
    """open popup menu

    (list <theme>.cfg SHORTCUTS section entries)"""

    menu = '\n'.join([to_list(cfg_t['SHORTCUTS'][s])[-1] for s in cfg_t['SHORTCUTS']])
    menu += '\n' + '\n'.join([act['sym'][-1] for act in CUSTOM_ACTIONS.values()])
    output = rofi_popup("menu", menu, nb_lines=7, width='20em')
    process_event_popup(output, cdate)


#@open_n_reload_rofi
def open_event(day_sym, date, editor):
    """open event with editor for the selected date"""

    day_ind = strip_list(SYMS_DAYS_NUM).index(day_sym) +1

    date_format = str(EVENTS_PATHS[EVENTS_DEFAULT])
    event_path = datetime.date(date.year, date.month, day_ind).strftime(date_format)

    edit_event_file(event_path, editor)


@open_n_reload_rofi
def edit_event_file(event_path, editor=ARGS.editor):
    """open event file with text editor"""

    event_folder = Path(event_path).parent
    if not os.path.isdir(event_folder):
        os.makedirs(event_folder)
    Path(event_path).touch()
    cmd = (*editor.split(' '), event_path)
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    sdtout, sdterr = p.communicate()


@open_n_reload_rofi
def ask_event_to_display():
    """Popup that show all events type"""

    events = list(EVENTS_PATHS.keys())
    events = list2rofi(events)

    event = rofi_popup(f"select what to display (actual = {EVENTS_DEFAULT})", events, nb_lines=6)

    set_event_cache(event)


@open_n_reload_rofi
def ask_theme():
    """Search themes in paths and open a popup"""

    themes = list(chain(*[glob.glob(f'{path}/*.rasi') for path in THEME_PATHS.values()]))
    themes = (t.split('/')[-1].split('.')[0]for t in themes)
    themes = list2rofi(sorted(set(themes)))
    #themes = '\n'.join((t.split('/')[-1] for t in themes))

    theme = rofi_popup("select theme", themes, nb_col=3, nb_lines=9, width='45em')
    if theme in themes:
        set_theme_cache(theme)
    else :
        print("this is not a valid theme", file=sys.stderr)

@open_n_reload_rofi
def execute_external_cmd(cmd):
    """Execute an external system command
    try to find command in different directories:

    - in $HOME/.config/naivecalendar/scripts/, then in
    - in ./scripts/, then
    - in system path
    """
    cmd_path = Path(cmd[0])

    if (SCRIPT_PATHS['user'] / cmd_path).exists():
        cmd = [str(SCRIPT_PATHS['user'] / cmd_path)] + cmd[1:]
    elif (SCRIPT_PATHS['rel'] / cmd_path).exists():
        cmd = [str(SCRIPT_PATHS['rel'] / cmd_path)] + cmd[1:]

    subprocess.Popen(cmd)

def set_pp_date(day, date, f):
    """write date to cache with command line specified format"""

    d = int(day)
    m = date.month
    y = date.year

    pretty_date = datetime.date(y, m, d).strftime(f)
    with open(PP_CACHE, "w") as f:
        f.write(pretty_date + "\n")


@open_n_reload_rofi
def send2clipboard(day, date, f):
    """return select date to stdout given cmd line parameter '--format'"""

    if shutil.which("xclip") == None:
        print("\nplease install xclip to use 'copy-to-clipboard' option (-x/--clipboard)\n", file=sys.stderr)
        sys.exit(0)

    d = int(day)
    m = date.month
    y = date.year

    pretty_date = datetime.date(y, m, d).strftime(f)
    p = subprocess.Popen(('echo', pretty_date), stdout=subprocess.PIPE)
    subprocess.check_output(('xclip', '-selection', 'clipboard'), stdin=p.stdout)

    sys.exit(0)


def first_time_init():
    """Create config files and paths given script head variables"""

    if shutil.which("rofi") == None:
        print("please install rofi")
        sys.exit()

    if not os.path.exists(THEME_PATHS['user']):
        os.makedirs(THEME_PATHS['user'])

    if not os.path.exists(SCRIPT_PATHS['user']):
        os.makedirs(SCRIPT_PATHS['user'])

    for events_path in EVENTS_PATHS.values():
        if not os.path.exists(events_path.parent):
            os.makedirs(events_path.parent)

    if not os.path.exists(CACHE_PATH):
        os.mkdir(CACHE_PATH)
        date = datetime.date.today()
        date_buff = configparser.ConfigParser()
        date_buff["buffer"] = {"year": date.year, "month": date.month}
        with open(DATE_CACHE, 'w') as date_cache:
            date_buff.write(date_cache)
        display_help(head_txt="Welcome to naivecalendar")


class CacheDate:
    """Class to store date
    Make easier reading and writing to date cache file
    Make easier operation on date

    Attributes
    ----------

    year : Year
    month: Month

    """

    def __init__(self):

        self.now()
        self._cache = configparser.ConfigParser()
        self.year = Year(self)
        self.month = Month(self)

    def now(self):
        """Set and return today date"""
        self.date = datetime.datetime.now()
        return self.date

    def set_month(self, month):
        """Set and return date of the given Month

        Parameters
        ----------
        month : str
            month to set in '%m-%Y' format

        Returns
        -------
        datetime.date
            a day of the month
        """

        m, y = [int(x) for x in month.split('-')]
        self.date = datetime.date(y,m,1)

        return self.date

    def read_cache(self):
        """load cache ini file"""

        self._cache.read(DATE_CACHE)
        day = 1
        month = int(self._cache["buffer"]["month"])
        year = int(self._cache["buffer"]["year"])

        self.date = datetime.date(year, month, day)

    def write_cache(self):
        """write date to ini cache file"""

        date = self.date
        self._cache["buffer"] = {"year": date.year, "month": date.month}
        with open(DATE_CACHE, "w") as buff:
            self._cache.write(buff)


class Year:
    """Make computation on date years"""
    def __init__(self, outer):
        self.outer = outer

    def __repr__(self):
        return f"Year({self.outer.date.year})"

    def __add__(self, years):
        """
        Increment or decrement date by a number of years

        Parameters
        ----------
        sourcedate : datetime.date
            CacheDate to Increment
        months : int
            number of years to add

        Returns
        -------
        datetime.date
            Incremented date
        """

        year = self.outer.date.year + years
        month = self.outer.date.month
        day = min(self.outer.date.day, calendar.monthrange(year, month)[1])
        self.outer.date = datetime.date(year, month, day)

    def __sub__(self, years):
        self.__add__(-years)


class Month:
    """Make computation on date months"""
    def __init__(self, outer):
        self.outer = outer

    def __repr__(self):
        return f"Month({self.outer.date.month})"

    def __add__(self, months):
        """
        Increment or decrement date by a number of month

        Parameters
        ----------
        sourcedate : datetime.date
            CacheDate to Increment
        months : int
            number of month to add

        Returns
        -------
        datetime.date
            Incremented date
        """

        month = self.outer.date.month - 1 + months
        year = self.outer.date.year + month // 12
        month = month % 12 + 1
        day = min(self.outer.date.day, calendar.monthrange(year, month)[1])

        self.outer.date = datetime.date(year, month, day)
        # return datetime.date(year, month, day)

    def __sub__(self, months):
        self.__add__(-months)


def joke(sym):
    """Just display stupid jokes in french"""

    if sym == DAY_FORMAT.format(""):
        print(
            "Vous glissez entre les mois, vous perdez la notion du temps.",
            file=sys.stderr,
        )
    elif sym in SYMS_WEEK_DAYS:
        print("Ceci n'est pas un jour! R.Magritte.", file=sys.stderr)


def set_theme_cache(selected):
    """Write theme name to cache file"""

    with open(THEME_CACHE, 'w') as f:
        f.write(selected)


def set_event_cache(selected):
    """Write theme name to cache file"""

    with open(EVENT_CACHE, 'w') as f:
        f.write(selected)


def rofi_popup(txt_head, txt_body, nb_lines=15, nb_col=1, width='40%', highlights=1000):
    """Launch a rofi window

    Parameters
    ----------
    txt_body : str
        Text to display in rofi window
    txt_head : str
        Text to display in rofi prompt

    Returns
    -------
    str
        Rofi selected cell content
    """

    cmd = subprocess.Popen(('echo', txt_body), stdout=subprocess.PIPE)

    theme_str = f'''
        @import "{THEME_RASI_FILE}"
        #window {{
            location:               center;
            width:                  {width};
        }}
        #listview {{
            columns:      {nb_col};
            lines:        {nb_lines};
            witdh:        {width};
        }}
    '''

    #rofi_cmd = f'''rofi -dmenu -theme-str '{theme_str}' -p "{txt_head}" -u {highlights}'''
    rofi_cmd = ('rofi', '-dmenu', '-theme-str',  theme_str, '-p', txt_head, '-u', str(highlights))
    selection = (
        subprocess.check_output(rofi_cmd, stdin=cmd.stdout)
        .decode("utf-8")
        .replace("\n", "")
    )

    return selection


@open_n_reload_rofi
def display_help(head_txt="help:"):
    """Show a rofi popup with help message"""


    txt = f"""NaïveCalendar {__version__}

Usage:
 - Use mouse or keyboard to interact with the calendar.
 - Hit bottom arrows to cycle through months.
 - Hit a day to create a linked event.
(A day with attached event will appear yellow.)
 - Create multiple event type and with between them

Shortcuts (type it in rofi prompt) :"""

    txt += '\n{:>20} : display this help'.format(','.join(SYM_SHOW_HELP[:-1]))
    txt += '\n{:>20} : go to previous year'.format(','.join(SYM_PREV_YEAR))
    txt += '\n{:>20} : go to previous month'.format(','.join(SYM_PREV_MONTH))
    txt += '\n{:>20} : go to next month'.format(','.join(SYM_NEXT_MONTH))
    txt += '\n{:>20} : go to next year'.format(','.join(SYM_NEXT_YEAR))
    txt += '\n{:>20} : display events of the month (first line)'.format(','.join(SYM_SHOW_EVENTS[:-1]))
    txt += '\n{:>20} : switch events folder to display'.format(','.join(SYM_SWITCH_EVENT[:-1]))
    txt += '\n{:>20} : show theme selector'.format(','.join(SYM_SWITCH_THEME[:-1]))
    txt += '\n{:>20} : display a selection menu (skip shortcuts)'.format(','.join(SYM_SHOW_MENU[:-1]))

    txt += f"""\n
Command line option:

subcommands:
    update-themes  Update a calendar parameter for all user themes at once
    add-event      Add, modify, delete event in all user themes config at once
    configure      Clone or open configuration files

optional arguments:
      -h, --help
      -V, --version
      -v, --verbose
      -p, --print
      -x, --clipboard
      -f FORMAT, --format FORMAT
      -e EDITOR, --editor EDITOR
      -l LOCALE, --locale LOCALE
      -c, --read-cache
      -t THEME, --theme THEME
      -d DATE, --date DATE

That's all : press enter to continue...
"""

    rofi_popup("Help", txt, nb_lines=20, width='45em')


if __name__ == "__main__":
    main(ARGS, ROFI_OUTPUT)

    #print("loop time =", "{:.2f}".format(1000*(time.time() - START)), 'ms', file=sys.stderr)

