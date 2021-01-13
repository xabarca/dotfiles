//Modify this file to change what commands output to your statusbar, and recompile using the make command.
static const Block blocks[] = {

	/*Icon*/	/*Command*/		        /*Update Interval*/	 /*Update Signal*/

	/*{"  ", "free -h | awk '/^Mem/ { print $3\"/\"$2 }' | sed s/i//g",	30,		0},  */

	{"",  "~/bin/dwm/dwm-bar-functions -v",	         0,		12 },
	{"",  "~/bin/dwm/dwm-bar-functions -a",	         0,		11 },
	{"",  "~/bin/dwm/dwm-bar-functions -m",	        30,		 0 },
	{"",  "~/bin/dwm/dwm-bar-functions -d",			30,		 0 },
};

//sets delimeter between status commands. NULL character ('\0') means no delimeter.
static char delim[] = "   ";
static unsigned int delimLen = 5;
