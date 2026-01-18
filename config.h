/* See LICENSE file for copyright and license details. */
/* NOTE: the runtime log file is at "$XDG_RUNTIME_DIR/dwm/dwm.log" */

/* Constants */
#define TERMINAL      "st"
#define EDITOR        "vim"
#define TERMCLASS     "St"
#define EMU_ROMS      "~/Downloads/emu-roms"
#define LAUNCH_BROWSER       {.v = (const char*[]){"mullvad-browser",NULL}}
#define LAUNCH_OTHER_BROWSER {.v = (const char*[]){"qutebrowser",NULL}}
#define LAUNCH_TOR_BROWSER   SHCMD("m-apps launch start-tor-browser")
#define MUS_PATH "~/Personal/Mus"
#define MUS_PLAYER "mpv"

#define BIN_PREFIX    "~/.local/bin/"

/* appearance */
static unsigned int default_corner_diameter = 18; //18; /* rounded border of windows */
static unsigned int seltag_corner_diameter  = 16; //12;  /* rounded border of selected tag in bar */
static unsigned int tags_corner_diameter    = 20; //6;    /* rounded border of non-selected tags in bar */
static unsigned int blocks_corner_diameter  = 6; //1;  /* rounded border of in bar */

										  
static unsigned int borderpx  = 2;        /* border pixel of windows */
static unsigned int snap      = 32;       /* snap pixel */
static unsigned int gappih    = 15;       /* horiz inner gap between windows */
static unsigned int gappiv    = 5;       /* vert inner gap between windows */
static unsigned int gappoh    = 10;       /* horiz outer gap between windows and screen edge */
static unsigned int gappov    = 15;       /* vert outer gap between windows and screen edge */
static int swallowfloating    = 0;        /* 1 means swallow floating windows by default */
static int smartgaps          = 1;        /* 1 means no outer gap when there is only one window */
static int showbar            = 1;        /* 0 means no bar */
static int topbar             = 0;        /* 0 means bottom bar */
static char *fonts[]          = { "Iosevka Nerd Font Mono,Iosevka NFM:size=17:antialias=true"  };

static char normbgcolor[]           = "#1a1b26"; // "#282d42";
static char normfgcolor[]           = "#666666";
#ifdef DEBUG_MODE
static char normbordercolor[]       = "#ff0000";
#else
static char normbordercolor[]       = "#333333";
#endif // DEBUG_MODE

static char selfgcolor[]            = "#a9b1d6";
#ifdef DEBUG_MODE
static char selbgcolor[]            = "#121212";
static char selbordercolor[]        = "#00ff00"; /*set to black to disable windows borders*/
#else
static char selbgcolor[]            = "#000000";
static char selbordercolor[]        = "#aaaaaa"; /*set to black to disable windows borders*/
#endif

static char memfgcolor[]            = "#89b4fa";
static char membgcolor[]            = "#1e1e2e";
static char membordercolor[]        = "#eeeeee";

static char okfgcolor[]            = "#00ff00";
static char okbgcolor[]            = "#1e1e2e";
static char okbordercolor[]        = "#eeeeee";

static char errfgcolor[]            = "#ff0000";
static char errbgcolor[]            = "#1e1e2e";
static char errbordercolor[]        = "#eeeeee";

static char datefgcolor[]            = "#a6adc8";
static char datebgcolor[]            = "#1e1e2e";
static char datebordercolor[]        = "#eeeeee";

static char hddfgcolor[]            = "#f9e2af";
static char hddbgcolor[]            = "#1e1e2e";
static char hddbordercolor[]        = "#eeeeee";

static char *colors[][3] = {
       /*               fg           bg           border   */
       [SchemeNorm] = { normfgcolor, normbgcolor, normbordercolor },
       [SchemeSel]  = { selfgcolor,  selbgcolor,  selbordercolor  },
       [SchemeMem]  = { memfgcolor,  membgcolor,  membordercolor  },
       [SchemeOk]   = { okfgcolor,   okbgcolor,   okbordercolor  },
       [SchemeErr]  = { errfgcolor,  errbgcolor,  errbordercolor  },
       [SchemeDate] = { datefgcolor, datebgcolor, datebordercolor },
       [SchemeHDD]  =  { hddfgcolor, hddbgcolor,  hddbordercolor  },
};

typedef struct {
	const char *name;
	const void *cmd;
} Sp;


const char *spcmd1[] = {TERMINAL, "-n", "spterm", "-g", "120x34", NULL };
static Sp scratchpads[] = {
	/* name          cmd  */
	{"spterm",      spcmd1},
};

/* tagging */
static const char *tags[] = { "term", "browse1", "browse2", "monitor", "5", "6", "7", "8", "9" };
#ifndef NULL
#define NULL 0
#endif

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	*/
	/* class    instance      title       	 tags mask    isfloating   isterminal  noswallow  monitor */
       { "st-256color",  NULL,"Simple terminal",      1 << 0 /*Tag 1*/,            0,      0,          0,          -1 },
       { "qutebrowser",  NULL,         NULL,          1 << 1 /*Tag 2*/,            0,      0,          0,          -1 },
       { "torbrowser",   NULL,         NULL,          1 << 1 /*Tag 2*/,            0,      0,          0,          -1 },
       { "Tor Browser",  NULL,         NULL,          1 << 1 /*Tag 2*/,            0,      0,          0,          -1 },
       { "obs",          NULL,         NULL,          1 << 3 /*Tag 4*/,            0,      0,          0,          -1 },
       { "Gimp",         NULL,         NULL,          1 << 5 /*Tag 6*/,            0,      0,          0,          -1 }
};

/* layout(s) */
static float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static int nmaster     = 1;    /* number of clients in master area */
static int resizehints = 0;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */
#define FORCE_VSPLIT 1  /* nrowgrid layout: force two clients to always split vertically */
#include "vanitygaps.c"
static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",	tile },	                /* Default: Master on left, slaves on right */
	{ "TTT",	bstack },               /* Master on top, slaves on bottom */

	// { "[\\]",	dwindle },              /* Decreasing in size right and leftward */
	{ "[D]",	deck },	                /* Master on left, slaves in monocle-like mode on right */

	{ "[M]",	monocle },              /* All windows on top of eachother */
	{ "|M|",	centeredmaster },               /* Master in middle, slaves on sides */
	{ ">M>",	quadlayout },       /* Same but master floats */

	{ "><>",	NULL },	                /* no layout function means floating behavior */
	{ NULL,		NULL },
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask|ControlMask,           KEY,      toggletag,      {.ui = 1 << TAG} },
#define STACKKEYS(MOD,ACTION) \
	{ MOD,	XK_j,	ACTION##stack,	{.i = INC(+1) } }, \
	{ MOD,	XK_k,	ACTION##stack,	{.i = INC(-1) } }, \
	{ MOD,  XK_v,   ACTION##stack,  {.i = 0 } }, \
	/* { MOD, XK_grave, ACTION##stack, {.i = PREVSEL } }, \ */
	/* { MOD, XK_a,     ACTION##stack, {.i = 1 } }, \ */
	/* { MOD, XK_z,     ACTION##stack, {.i = 2 } }, \ */
	/* { MOD, XK_x,     ACTION##stack, {.i = -1 } }, */

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }
#define str(c) #c

/* commands */
static const char* termcmd[]  = { "sh", "-c", BIN_PREFIX TERMINAL, NULL };
static const char* editorcmd[]  = { "sh", "-c", BIN_PREFIX TERMINAL, "-e", EDITOR, NULL };
static Arg* exec_once[] = {
	// (Arg[]){ SHCMD("killall -q dwmblocks picom") },
	(Arg[]){ { .v = (const char*[]){ "picom",
		"--corner-radius", str(default_corner_diameter/2), 
		"--backend", "glx", 
		"-f",
		"--fade-in-step", "0.08",
		"-e", "1.0",
		0}
	} },
	NULL
};

// this is not in the original, but I thought it might be useful.
// also, I think part of this doesn't work, I have to debug this.,

/*
 * Xresources preferences to load at startup
 */

ResourcePref resources[] = {
		{ "color0",		STRING,	&normbordercolor },
		{ "color8",		STRING,	&selbordercolor },
		{ "color0",		STRING,	&normbgcolor },
		{ "color4",		STRING,	&normfgcolor },
		{ "color0",		STRING,	&selfgcolor },
		{ "color4",		STRING,	&selbgcolor },
		{ "borderpx",		INTEGER, &borderpx },
		{ "snap",		INTEGER, &snap },
		{ "showbar",		INTEGER, &showbar },
		{ "topbar",		INTEGER, &topbar },
		{ "nmaster",		INTEGER, &nmaster },
		{ "resizehints",	INTEGER, &resizehints },
		{ "mfact",		FLOAT,	&mfact },
		{ "gappih",		INTEGER, &gappih },
		{ "gappiv",		INTEGER, &gappiv },
		{ "gappoh",		INTEGER, &gappoh },
		{ "gappov",		INTEGER, &gappov },
		{ "swallowfloating",	INTEGER, &swallowfloating },
		{ "smartgaps",		INTEGER, &smartgaps },
};

#include <X11/XF86keysym.h>
#include "shiftview.c"
#define DMENU_RUN_PATH "~/.local/apps/terminal:~/.local/apps/gui"
#define DMENU_FLAGS "-z","500","-x","300","-y","400","-l", "12", "-fn", "Iosevka Nerd Font:size=25" // "-m", "$(expr `hyprctl monitors | grep focused | cut -d \":\" -f2 | grep -n yes | cut -d \":\" -f1` - 1)"
#define SH_DMENU_FLAGS "-z 500 -x 300 -y 500 -l 12 -fn 'Iosevka Nerd Font:size=25'"                  // -m $(expr `hyprctl monitors | grep focused | cut -d \":\" -f2 | grep -n yes | cut -d \":\" -f1` - 1)"
// dmenu flags are actually equal, but I haven't changed it.
//-m $(expr `hyprctl monitors | grep focused | cut -d \":\" -f2 | grep -n yes | cut -d \":\" -f1` - 1)"

static const Key keys[] = {
	/* modifier                     key            function                argument */
	STACKKEYS(MODKEY,                              focus)
	STACKKEYS(MODKEY|ShiftMask,                    push)
	TAGKEYS(			    XK_1,          0)
	TAGKEYS(			    XK_2,          1)
	TAGKEYS(			    XK_3,          2)
	TAGKEYS(			    XK_4,          3)
	TAGKEYS(			    XK_5,          4)
	TAGKEYS(			    XK_6,          5)
	TAGKEYS(			    XK_7,          6)
	TAGKEYS(			    XK_8,          7)
	TAGKEYS(			    XK_9,          8)
	{ MODKEY,			    XK_u,          spawn,	               	   SHCMD("cat ~/.emojis.txt | dmenu | cut -d '|' -f1 | xclip") },
	{ MODKEY,			    XK_apostrophe, spawn,                  SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-; kill -44 $(pidof dwmblocks)") },
	{ MODKEY|ShiftMask,		XK_apostrophe, spawn,                  SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 15%-; kill -44 $(pidof dwmblocks)") },
	{ MODKEY,			    XK_minus,      spawn,                  SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+; kill -44 $(pidof dwmblocks)") },
	{ MODKEY|ShiftMask,		XK_minus,      spawn,                  SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 15%+; kill -44 $(pidof dwmblocks)") },
	{ MODKEY,			    XK_BackSpace,  spawn,                  {.v = (const char*[]){ "sysact", NULL } } },
	{ MODKEY|ShiftMask,		XK_BackSpace,  spawn,                  {.v = (const char*[]){ "sysact", NULL } } },

    // { MODKEY,			    XK_Tab,        view,                   {0} },
	{ MODKEY,			    XK_q,          killclient,             {0} },
    { MODKEY,               XK_o,          spawn,                  SHCMD(BIN_PREFIX "timer -c \"$(echo | dmenu -p \"comment\" " SH_DMENU_FLAGS ")\" \"$(cat ~/.timers | dmenu "SH_DMENU_FLAGS" | cut -d \"#\" -f1 | xargs)") } ,
	{ MODKEY|ShiftMask,	    XK_w,          spawn,                  SHCMD(BIN_PREFIX "ws $(dmenu " SH_DMENU_FLAGS " < ~/.websites)") },

	{ MODKEY|ShiftMask,		XK_q,          quit,                   {.i = 0} },
	{ MODKEY|ShiftMask,	    XK_r,          quit,                   {.i = 1} },

	{ MODKEY,			    XK_w,          spawn,                  LAUNCH_BROWSER },
	{ MODKEY,	            XK_p,          spawn,                  LAUNCH_OTHER_BROWSER },
	{ MODKEY,			    XK_t,          spawn,                  LAUNCH_TOR_BROWSER },

	{ MODKEY|ShiftMask,		XK_e,          spawn,                  SHCMD(TERMINAL " -e abook -C ~/.config/abook/abookrc --datafile ~/.config/abook/addressbook") },
	{ MODKEY,			    XK_r,          spawn,                  {.v = (const char*[]){ TERMINAL, "-e", "sudo", "termshark", NULL } } },

	{ MODKEY,	    XK_r,          setlayout,                      {.v = &layouts[0]} }, /* tile */
	{ MODKEY|ShiftMask,	    XK_t,          setlayout,              {.v = &layouts[1]} }, /* bstack */
	{ MODKEY|ShiftMask,		XK_u,          setlayout,              {.v = &layouts[2]} }, /* monocle */
	{ MODKEY,			    XK_i,          setlayout,              {.v = &layouts[3]} }, /* centeredmaster */
	{ MODKEY|ShiftMask,		XK_i,          setlayout,              {.v = &layouts[4]} }, /* layout 4 */
	{ MODKEY,		        XK_e,          setlayout,              {.v = &layouts[5]} },

	{ MODKEY|ShiftMask,		XK_p,          spawn,                  SHCMD("mpc pause; pauseallmpv") },
	{ MODKEY,			    XK_bracketleft, spawn,                 {.v = (const char*[]){ "mpc", "seek", "-10", NULL } } },
	{ MODKEY|ShiftMask,		XK_bracketleft, spawn,                 {.v = (const char*[]){ "mpc", "seek", "-60", NULL } } },
	{ MODKEY,			    XK_bracketright, spawn,                {.v = (const char*[]){ "mpc", "seek", "+10", NULL } } },
	{ MODKEY|ShiftMask,		XK_bracketright, spawn,                {.v = (const char*[]){ "mpc", "seek", "+60", NULL } } },
	{ MODKEY,			    XK_backslash,  view,                   {0} },
	/* { MODKEY|ShiftMask,		XK_backslash,  spawn,                  SHCMD("") }, */

	{ MODKEY,			    XK_a,          togglegaps,             {0} },
	{ MODKEY|ShiftMask,		XK_a,          defaultgaps,            {0} },
	{ MODKEY,			    XK_s,          togglesticky,           {0} },
	{ MODKEY,			    XK_d,          spawn,                  SHCMD(BIN_PREFIX "m-apps launch $(cat ~/.local/share/apps/apps.ttext | dmenu  -z 500 -x 300 -y 500 -l 12 -fn 'MathJax_Typewriter:size=25' | cut -d '/' -f2)") },
	{ MODKEY|ShiftMask,		XK_d,          spawn,                  {.v = (const char*[]){ "keepassxc", DMENU_FLAGS, NULL } } },
	{ MODKEY,			    XK_f,          togglefullscr,          {0} },
	{ MODKEY|ShiftMask,		XK_f,          setlayout,              {.v = &layouts[8]} },
	{ MODKEY,			    XK_g,          shiftview,              { .i = -1 } },
	{ MODKEY|ShiftMask,		XK_g,          shifttag,               { .i = -1 } },
	{ MODKEY,			    XK_h,          setmfact,               {.f = -0.05} },
	/* J and K are automatically bound above in STACKEYS */
	 { MODKEY,			    XK_l,          setmfact,               {.f = +0.05} },
        // { MODKEY,			XK_semicolon,  shiftview,              { .i = 1 } },
	// { MODKEY|ShiftMask,		XK_semicolon,  shifttag,               { .i = 1 } },
	// { MODKEY,			XK_apostrophe, togglescratch,          {.ui = 1} },
	/* { MODKEY|ShiftMask,		XK_apostrophe, spawn,                  SHCMD("") }, */
	{ MODKEY|ShiftMask,		XK_apostrophe, togglesmartgaps,        {0} },
	{ MODKEY,			    XK_Return,     spawn,                  {.v = termcmd } },
	{ MODKEY|ShiftMask,		XK_Return,     togglescratch,          {.ui = 0} },

	{ MODKEY,			XK_q,          incrgaps,               {.i = +3 } },
	{ MODKEY,			XK_z,          incrgaps,               {.i = +3 } },
	{ MODKEY,			XK_x,          incrgaps,               {.i = -3 } },
	{ MODKEY,			XK_b,          spawn,                  SHCMD("kill -9 $(ps ax -o comm x -u $USER | tail -n +2 | dmenu | xargs pidof)")},
	{ MODKEY|ShiftMask, XK_b,          togglebar,              {0} },
	{ MODKEY|ShiftMask,	XK_z,          spawn,                  SHCMD(BIN_PREFIX "boomer") },
	{ MODKEY,			XK_n,          spawn,                  SHCMD(BIN_PREFIX "drawop") },
	{ MODKEY,			XK_m,          spawn,                  SHCMD(BIN_PREFIX "sv") },
	{ MODKEY|ShiftMask,	XK_m,          spawn,                  SHCMD(MUS_PLAYER " " MUS_PATH "/\"$(ls " MUS_PATH " | dmenu " SH_DMENU_FLAGS ")\"") },
	{ MODKEY,	        XK_v,          spawn,                  {.v = editorcmd } },
	{ MODKEY|ShiftMask,	XK_v,          spawn,                  SHCMD("fceux "EMU_ROMS"/$(ls -1 -f " EMU_ROMS "| dmenu " SH_DMENU_FLAGS ")") },
	{ MODKEY,			XK_comma,      spawn,                  {.v = (const char*[]){ "mpc", "prev", NULL } } },
	{ MODKEY|ShiftMask,	XK_comma,      spawn,                  {.v = (const char*[]){ "mpc", "seek", "0%", NULL } } },
	{ MODKEY,			XK_period,     spawn,                  {.v = (const char*[]){ "mpc", "next", NULL } } },
	{ MODKEY|ShiftMask,	XK_period,     spawn,                  {.v = (const char*[]){ "mpc", "repeat", NULL } } },

	{ MODKEY,			XK_Left,       focusprev,               {.i = 0 } },
	{ MODKEY,			XK_Right,      focusnext,               {.i = 0 } },

	{ MODKEY,			XK_Page_Up,    shiftview,              { .i = -1 } },
	{ MODKEY|ShiftMask,	XK_Page_Up,    shifttag,               { .i = -1 } },
	{ MODKEY,			XK_Page_Down,  shiftview,              { .i = +1 } },
	{ MODKEY|ShiftMask,	XK_Page_Down,  shifttag,               { .i = +1 } },
	{ MODKEY,			XK_Insert,     spawn,                  SHCMD("xdotool type $(grep -v '^#' ~/.local/share/larbs/snippets | dmenu -i -l 50 | cut -d' ' -f1)") },

	{ MODKEY,			XK_F3,         spawn,                  {.v = (const char*[]){ "scrot", "-s", NULL } } },
	{ MODKEY,			XK_F4,         spawn,                  SHCMD(TERMINAL " -e alsamixer; kill -44 $(pidof dwmblocks)") },
	{ MODKEY,			XK_F5,         xrdb,                   {.v = NULL } },
	{ MODKEY,			XK_F11,        spawn,                  SHCMD("mpv --untimed --no-cache --no-osc --no-input-default-bindings --profile=low-latency --input-conf=/dev/null --title=webcam $(ls /dev/video[0,2,4,6,8] | tail -n 1)") },
	{ MODKEY,			XK_space,      zoom,                   {0} },
	{ MODKEY|ShiftMask,	XK_space,      togglefloating,         {0} },

	{ 0,				XK_Print,      spawn,                  SHCMD("maim pic-full-$(date '+%y%m%d-%H%M-%S').png") },
	{ ShiftMask,	    XK_Print,      spawn,                  {.v = (const char*[]){ "maimpick", NULL } } },
	{ MODKEY,			XK_Print,      spawn,		       {.v = (const char*[]){ "dmenurecord", NULL } } },
	{ MODKEY|ShiftMask,	XK_Print,      spawn,                  {.v = (const char*[]){ "dmenurecord", "kill", NULL } } },
	{ MODKEY,			XK_Delete,     spawn,                  {.v = (const char*[]){ "dmenurecord", "kill", NULL } } },

	{ 0, XF86XK_AudioMute,                         spawn,                  SHCMD("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle; kill -44 $(pidof dwmblocks)") },
	{ 0, XF86XK_AudioRaiseVolume,                  spawn,                  SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%- && wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%+; kill -44 $(pidof dwmblocks)") },
	{ 0, XF86XK_AudioLowerVolume,                  spawn,                  SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%+ && wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%-; kill -44 $(pidof dwmblocks)") },
	{ 0, XF86XK_AudioPrev,                         spawn,                  {.v = (const char*[]){ "mpc", "prev", NULL } } },
	{ 0, XF86XK_AudioNext,                         spawn,                  {.v = (const char*[]){ "mpc",  "next", NULL } } },
	{ 0, XF86XK_AudioPause,                        spawn,                  {.v = (const char*[]){ "mpc", "pause", NULL } } },
	{ 0, XF86XK_AudioPlay,                         spawn,                  {.v = (const char*[]){ "mpc", "play", NULL } } },
	{ 0, XF86XK_AudioStop,                         spawn,                  {.v = (const char*[]){ "mpc", "stop", NULL } } },
	{ 0, XF86XK_AudioRewind,                       spawn,                  {.v = (const char*[]){ "mpc", "seek", "-10", NULL } } },
	{ 0, XF86XK_AudioForward,                      spawn,                  {.v = (const char*[]){ "mpc", "seek", "+10", NULL } } },
	{ 0, XF86XK_AudioMicMute,                      spawn,                  SHCMD("pactl set-source-mute @DEFAULT_SOURCE@ toggle") },
	/* { MODKEY,                    XK_y,          incrihgaps,             {.i = +1 } }, */
	/* { MODKEY,                    XK_o,          incrihgaps,             {.i = -1 } }, */
	/* { MODKEY|ControlMask,        XK_y,          incrivgaps,             {.i = +1 } }, */
	/* { MODKEY|ControlMask,        XK_o,          incrivgaps,             {.i = -1 } }, */
	/* { MODKEY|Mod4Mask,           XK_y,          incrohgaps,             {.i = +1 } }, */
	/* { MODKEY|Mod4Mask,           XK_o,          incrohgaps,             {.i = -1 } }, */
	/* { MODKEY|ShiftMask,          XK_y,          incrovgaps,             {.i = +1 } }, */
	/* { MODKEY|ShiftMask,          XK_o,          incrovgaps,             {.i = -1 } }, */

};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
	/* click                event mask           button          function        argument */
#ifndef __OpenBSD__
       { ClkWinTitle,           0,                  Button2,        zoom,           {0} },
       { ClkStatusText,         0,                  Button1,        sigdwmblocks,   {.i = 1} },
       { ClkStatusText,         0,                  Button2,        sigdwmblocks,   {.i = 2} },
       { ClkStatusText,         0,                  Button3,        sigdwmblocks,   {.i = 3} },
       { ClkStatusText,         0,                  Button4,        sigdwmblocks,   {.i = 4} },
       { ClkStatusText,         0,                  Button5,        sigdwmblocks,   {.i = 5} },
       { ClkStatusText,         ShiftMask,          Button1,        sigdwmblocks,   {.i = 6} },
#endif
       { ClkStatusText,         ShiftMask,          Button3,        spawn,          SHCMD(TERMINAL " -e vim ~/.local/src/dwmblocks/config.h") },
       { ClkClientWin,          MODKEY,             Button1,        movemouse,      {0} },
       { ClkClientWin,          MODKEY,             Button2,        defaultgaps,    {0} },
       { ClkClientWin,          MODKEY,             Button3,        resizemouse,    {0} },
       { ClkClientWin,		    MODKEY,		        Button4,	     incrgaps,       {.i = +1} },
       { ClkClientWin,		    MODKEY,		        Button5,	     incrgaps,       {.i = -1} },
       { ClkTagBar,             0,                  Button1,        view,           {0} },
       { ClkTagBar,             0,                  Button3,        toggleview,     {0} },
       { ClkTagBar,             MODKEY,             Button1,        tag,            {0} },
       { ClkTagBar,             MODKEY,             Button3,        toggletag,      {0} },
       { ClkTagBar,		        0,		            Button4,	     shiftview,      {.i = -1} },
       { ClkTagBar,		        0,		            Button5,	     shiftview,      {.i = 1} },
       { ClkRootWin,		    0,		            Button2,	     togglebar,      {0} },
};

