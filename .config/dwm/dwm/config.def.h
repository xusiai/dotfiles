#include <X11/XF86keysym.h>

/* APPEARANCE */
static const unsigned int borderpx  = 0;        /* border pixel of windows */
static const unsigned int default_border = 0;   /* to switch back to default border after dynamic border resizing via keybinds */
static const unsigned int snap      = 32;       /* snap pixel */
static const unsigned int gappih    = 10;       /* horiz inner gap between windows */
static const unsigned int gappiv    = 10;       /* vert inner gap between windows */
static const unsigned int gappoh    = 10;       /* horiz outer gap between windows and screen edge */
static const unsigned int gappov    = 10;       /* vert outer gap between windows and screen edge */
static const int smartgaps          = 0;        /* 1 means no outer gap when there is only one window */
static const unsigned int systraypinning = 0;   /* 0: sloppy systray follows selected monitor, >0: pin systray to monitor X */
static const unsigned int systrayspacing = 2;   /* systray spacing */
static const int systraypinningfailfirst = 1;   /* 1: if pinning fails,display systray on the 1st monitor,False: display systray on last monitor*/
static const int showsystray        = 0;        /* 0 means no systray */
static const int showbar            = 1;        /* 0 means no bar */
static const int showtab            = showtab_auto;
static const int toptab             = 1;        /* 0 means bottom tab */
static const int topbar             = 0;        /* 0 means bottom bar */
static const int horizpadbar        = 5;
static const int vertpadbar         = 14;
static const int vertpadtab         = 33;
static const int horizpadtabi       = 15;
static const int horizpadtabo       = 15;
static const int scalepreview       = 4;
static const int tag_preview        = 0;        /* 1 means enable, 0 is off */
static const int colorfultag        = 1;        /* 0 means use SchemeSel for selected non vacant tag */

static const char *fonts[]          = { "SAGA Heavy:size=12",
                                        "Material Design Icons Desktop:size=13" };

#include "themes/SAGA.h"

static const char *colors[][3]      = {
    /*                     fg       bg      border */
    [SchemeNorm]       = { gray3,   black,  gray2 },
    [SchemeSel]        = { gray4,   blue,   black  },
    [TabSel]           = { blue,    gray2,  black },
    [TabNorm]          = { gray3,   black,  black },
    [SchemeTag]        = { gray3,   black,  black },
    [SchemeTag1]       = { blue,    black,  black },
    [SchemeTag2]       = { red,     black,  black },
    [SchemeTag3]       = { orange,  black,  black },
    [SchemeTag4]       = { green,   black,  black },
    [SchemeTag5]       = { pink,    black,  black },
    [SchemeLayout]     = { red,   black,  black },
    [SchemeBtnPrev]    = { green,   black,  black },
    [SchemeBtnNext]    = { yellow,  black,  black },
    [SchemeBtnClose]   = { red,     black,  black },
};

/* TAGS */
static char *tags[] = {"󰄯", "󰄯", "󰄯", "󰄯", "󰄯"};

static const char* eww[] = { "eww", "open" , "eww", NULL };

static const Launcher launchers[] = {
    /* command     name to display */
    { eww,         "" },
};

static const int tagschemes[] = {
    SchemeTag1, SchemeTag2, SchemeTag3, SchemeTag4, SchemeTag5
};

static const unsigned int ulinepad      = 5; /* horizontal padding between the underline and tag */
static const unsigned int ulinestroke   = 0; /* thickness / height of the underline */
static const unsigned int ulinevoffset  = 3; /* how far above the bottom of the bar the line should appear */
static const int ulineall               = 0; /* 1 to show underline on all tags, 0 for just the active ones */

static const Rule rules[] = {
    /* xprop(1):
     *	WM_CLASS(STRING) = instance, class
     *	WM_NAME(STRING) = title */

    /* class                             instance    title       tags mask     iscentered   isfloating   monitor */
    { "St",              	                  NULL,       NULL,       0,            -1,           1,           -1 },
    { "Org.gnome.Nautilus",      NULL,       NULL,       0,            -1,           1,           -1 },
    { "feh",                                 NULL,       NULL,       0,            -1,           1,           -1 },
    { "league of legends.exe",   NULL,       NULL,       2,            0,           1,           -1 },
    { "leagueclientux.exe",        NULL,       NULL,       2,            0,           1,           -1 },
    { "leagueclient.exe",            NULL,       NULL,       2,            -1,           1,           -1 },
    { "riotclientux.exe",             NULL,       NULL,       2,            -1,           1,           -1 },
    { "riotclientux.exe",             NULL,       NULL,       2,            -1,           1,           -1 },
    { "music",                             NULL,       NULL,       3,            -1,           1,           -1 },
    { "Zenity",         		         NULL,       NULL,       2,            -1,           1,           -1 },
    { "explorer.exe",       	         NULL,       NULL,       2,            -1,           1,           -1 },
    
};

/* LAYOUTS */
static const float mfact     = 0.50; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 0;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */

#define FORCE_VSPLIT 1  /* nrowgrid layout: force two clients to always split vertically */
#include "functions.h"


static const Layout layouts[] = {
    /* symbol     arrange function */
    { ":::",      gaplessgrid }, /* first entry is default */
    { "[M]",      monocle },
    { "[@]",      spiral },
    { "[\\]",     dwindle },
    { "H[]",      deck },
    { "TTT",      bstack },
    { "===",      bstackhoriz },
    { "HHH",      grid },
    { "###",      nrowgrid },
    { "---",      horizgrid },
    { "[]=",      tile },    
    { "|M|",      centeredmaster },
    { ">M>",      centeredfloatingmaster },
    { "><>",      NULL },    /* no layout function means floating behavior */
    { NULL,       NULL },
};

/* KEYS */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
    { MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
    { MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
    { MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
    { MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

static Key keys[] = {
    /* modifier                         key         function        argument */ 
    { 0,                    XK_F7,                  spawn,          SHCMD("playerctl next")},
    { 0,                    XK_F8,                  spawn,          SHCMD("playerctl play-pause")},
    { 0,                    XK_F9,                  spawn,          SHCMD("playerctl previous")},
    { MODKEY,               XK_F7,                  spawn,          SHCMD("volume up")},
    { MODKEY,               XK_F9,                  spawn,          SHCMD("volume down")},
    { MODKEY,               XK_r,                   spawn,          SHCMD("redshift -O 4000K")},
    { MODKEY|ShiftMask,     XK_r,                   spawn,          SHCMD("redshift -x")},
    { MODKEY|ShiftMask,     XK_x,                   spawn,          SHCMD("shot full")},
    { MODKEY,               XK_x,                   spawn,          SHCMD("shot crop")},
    { MODKEY,               XK_p,                   spawn,          SHCMD("colorpicker") },
    { MODKEY,               XK_F1,                  spawn,          SHCMD("$HOME/.config/rofi/launcher/launcher.sh") },
    { MODKEY,               XK_Escape,                  spawn,          SHCMD("$HOME/.config/rofi/powermenu/powermenu.sh") },
    { MODKEY,               XK_Return,              spawn,          SHCMD("st")},
    { MODKEY|ShiftMask,     XK_s,                   spawn,          SHCMD("st")},
    { MODKEY|ShiftMask,     XK_w,                   spawn,          SHCMD("firefox") },
    { MODKEY,               XK_BackSpace,           spawn,          SHCMD("firefox") },
    { MODKEY,               XK_j,                   spawn,          SHCMD("jellyfinmediaplayer") },
    { MODKEY,               XK_l,                   spawn,          SHCMD("leagueoflegends start") },
    { MODKEY|ShiftMask,     XK_l,                   spawn,          SHCMD("leagueoflegends kill") },
    { MODKEY|ShiftMask,     XK_f,                   spawn,          SHCMD("nautilus") },
    { MODKEY,               XK_y,                   spawn,          SHCMD("yt") },
    { MODKEY,               XK_v,                   spawn,          SHCMD("st -e v") },
    { MODKEY,               XK_g,                   spawn,          SHCMD("code-oss") },
    { Mod1Mask|ControlMask, XK_w,                   spawn,          SHCMD("feh --bg-scale --randomize --recursive $HOME/.local/share/wallpapers") },
    
    { MODKEY,               XK_b,                   togglebar,      {0} },
    { MODKEY,               XK_space,               togglefloating, {0} },
    { MODKEY,               XK_f,                   togglefullscr,  {0} },

    /* LAYOUT */
    { Mod1Mask|ControlMask,               XK_1,       setlayout,      {.v = &layouts[0]} },
    { Mod1Mask|ControlMask,               XK_2,       setlayout,      {.v = &layouts[1]} },
    { Mod1Mask|ControlMask,               XK_3,       setlayout,      {.v = &layouts[2]} },
    { Mod1Mask|ControlMask,               XK_4,       setlayout,      {.v = &layouts[10]} },
    { Mod1Mask|ControlMask,               XK_5,       setlayout,      {.v = &layouts[13]} },
    { Mod1Mask|ControlMask,               XK_6,       setlayout,      {0} },
    { ControlMask,                        XK_space,   cyclelayout,    {.i = -1 } },
    { Mod1Mask|ControlMask,               XK_space,   cyclelayout,    {.i = +1 } },
    { MODKEY,                             XK_0,       view,           {.ui = ~0 } },
    { MODKEY|ShiftMask,                   XK_0,       tag,            {.ui = ~0 } },
    { MODKEY,                             XK_comma,   focusmon,       {.i = -1 } },
    { MODKEY,                             XK_period,  focusmon,       {.i = +1 } },
    { MODKEY|ShiftMask,                   XK_comma,   tagmon,         {.i = -1 } },
    { MODKEY|ShiftMask,                   XK_period,  tagmon,         {.i = +1 } },

    /* KILL */
    { Mod1Mask|ControlMask|ShiftMask,             XK_q,       spawn,          SHCMD("killall bar.sh dwm") }, // dwm
    { MODKEY,                           XK_c,       killclient,     {0} },                        // window

    /* RESTART */
    { Mod1Mask|ControlMask,             XK_r,       restart,        {0} },

    /* SCRATCHPAD */
    { MODKEY,                           XK_z,       hidewin,        {0} },
    { MODKEY|ShiftMask,                 XK_z,       restorewin,     {0} },

    TAGKEYS(                            XK_1,                       0)
    TAGKEYS(                            XK_2,                       1)
    TAGKEYS(                            XK_3,                       2)
    TAGKEYS(                            XK_4,                       3)
    TAGKEYS(                            XK_5,                       4)
    TAGKEYS(                            XK_6,                       5)
    TAGKEYS(                            XK_7,                       6)
    TAGKEYS(                            XK_8,                       7)
    TAGKEYS(                            XK_9,                       8)
};

    /* MOUSE BUTTONS */
    /* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static Button buttons[] = {
    /* click                event mask      button          function        argument */
    { ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
    { ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },


    /* placemouse options, choose which feels more natural:
    *    0 - tiled position is relative to mouse cursor
    *    1 - tiled postiion is relative to window center
    *    2 - mouse pointer warps to window center
    *
    * The moveorplace uses movemouse or placemouse depending on the floating state
    * of the selected client. Set up individual keybindings for the two if you want
    * to control these separately (i.e. to retain the feature to move a tiled window
    * into a floating position).
    */
    { ClkClientWin,         MODKEY,                   Button1,        moveorplace,    {.i = 0} },
    { ClkClientWin,         MODKEY,                   Button2,        togglefloating, {0} },
    { ClkClientWin,         MODKEY,                   Button3,        resizemouse,    {0} },
    { ClkClientWin,         ControlMask|ShiftMask,    Button1,        dragmfact,      {0} },
    { ClkClientWin,         ControlMask|ShiftMask,    Button3,        dragcfact,      {0} },
    { ClkTagBar,            0,                        Button1,        view,           {0} },
    { ClkTagBar,            0,                        Button3,        toggleview,     {0} },
    { ClkTagBar,            MODKEY,                   Button1,        tag,            {0} },
    { ClkTagBar,            MODKEY,                   Button3,        toggletag,      {0} },
    { ClkTabBar,            0,                        Button1,        focuswin,       {0} },
    { ClkTabBar,            0,                        Button1,        focuswin,       {0} },
    { ClkTabPrev,           0,                        Button1,        movestack,      { .i = -1 } },
    { ClkTabNext,           0,                        Button1,        movestack,      { .i = +1 } },
    { ClkTabClose,          0,                        Button1,        killclient,     {0} },
};

