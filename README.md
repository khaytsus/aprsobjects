APRS Objects Generator for Direwolf
================

This script makes it possible to schedule objects to be advertised with Direwolf.  The output of this script is the currently active objects for use in a Direwolf configuration file.  Suggested setup is to create a Direwolf config file with no emphermeral objects in it.  Then have a cron job which runs every N minutes (5 is a good starting point) which copies the current Direwolf configuration file to another filename, then concatenate the output of your template Direwolf config and the output of this script to a new Direwolf config.  Compare the two files; if they are different restart Direwolf so it picks up the new settings.

A very simple example script to execute Direwolf on a cron job is included which you can update and include in your setup.

Objects can be defined using the @objects array in the aprsobjects.pm module or they can be pulled from an iCal source.  These two data sources are exclusve from one another, so you may only use one or the other.

This script is based on the ideas from Bob Bruninga (WB4APR) in http://www.aprs.org/info/netsked.txt

### aprsobjects.pm

You will need to update aprsobjects.pm with the settings and method you wish to use to define objects.  If you want to use iCal you must set up an iCal calendar and set the public URL for it, or you can define the objects using the @objects array.  To set up iCal see the section below specific to that topic.

#### Default options

There are several defaults to set in the get_defaults function

* $debug = 0;
 * If set to 1, enable extra debugging which will output the steps being executed and objects evaluated.  All debug lines are commented out so they should not affect Direwolf processing

* $moduleversion = 'x.x';
 * To ensure our module fields matches our program fields, this must match the version in the main program.  This just indicates the need to ensure any fields you have defined still meet the fields the program needs.

* $ical = "https://calendar.google.com/calendar/ical/....../basic.ics";
 * iCal url when using iCal as a data source for objects.  Disables the use of using the @objects array in aprsobjects.pm  If you do not want to use iCal as a source, set this to an empty string or to undef

* $startinterval = '0:30';
 * How long to delay our initial beacon advertisement, in direwolf format (min:sec).  In this example, it means Direwolf will wait 30 seconds before it advertises the first object.

* $delayinterval = '15';
 * How many more seconds of delay to add between each additional beacon so advertisements are spaced out.  In this example it means the second object will be avertised 45 seconds after Direolf starts.  The third object 60 seconds, etc.  This is so we're advertising objects at a reasonable speed without congesting the APRS network.  If your local APRS is highly congested I would suggest increasing this delay.

*  @outputs = ( 'sendto=IG', 'via="WIDE1-1,WIDE2-1"' );
 *  Define our output paths for every object that we advertise.  In this example we'll advertise to the internet (igate) and then with the WIDE1-1,WIDE2-1 path.  Adjust for your local configuration and APRS topology, such as only igate, or a more narrow digipeater path.  Be careful with the quotes around the digipeater path.

#### Objects array

The @objects array is how you define the APRS objects you want to advertise.  If you're using iCal there is no need to populate anything in this object.

* Objects array is a pipe (|) separated list of fields
 * Leave empty for unused field, ie:  |data|data||data|data
 * General Formatting is whatever Direwolf requires for the given field, see examples, Direwolf docs, etc
 * Suggestion:  All day or every day events at the end so emphemeral events are advertised sooner

* Object data description and order
 * DOW - Sun = 0, Mon = 1, Tue = 2, Wed = 3, Thur = 4, Fri = 5, Sat = 6, Every Day = -1
 * ENABLED - 0 entry is disabled, 1 enabled
 * MONTH - Month for a dated event (1-12)
 * DAY - Day of the month for a dated event (1-31)
 * YEAR - Year for a dated event (2016)
 * STARTTIME/ENDTIME - Start/End = 0 implies broadcast all day, HH:MM format
 * TIMEBEFORE - Number of minutes to start advertising object before STARTTIME
 * OBJNAME - Name of APRS Object, max 9 characters
 * MHZ - Frequency associated with this object
 * LAT/LON - Latitude/Longitude of object
 * FREQ - How often to beacon object
 * OFFSET (OPTIONAL) - Frequency offset if split, repeater input, etc
 * TONE (OPTIONAL) - PL Tone
 * HEIGHT (OPTIONAL) - Height of associated station (repeater, etc)
 * POWER (OPTIONAL) - Power output of associated station
 * SYMBOL - APRS Symbol to use for object
 * COMMENT (OPTIONAL) - Description of object

### iCal data

Setting up APRS objects in the @object array can be a bit tedious and requires someone editing the file.  Using an iCal URL as a data source is potentially an easier way to define objects, and this also allows you to delegate the adding and maintaining of objects to other people as you can share your calendar with other users.  I have tested this with Google Calendar but it should work with other calendars as well.  Be aware that this data is pulled down every run, and can take several seconds to download and parse.  If you need your data to not require an internet connection it is better to use the @objects array.

I have found that a dozen APRS object events with recurring settings can take a long time to parse, so the script limits the days evaluated to today and tomorrow (as events are dated as UTC, events in the evening may be dated tomorrow in the raw iCal data that is parsed).  This speeds up the parsing considerably and since we're only generally advertising for events in the immediate future this is fine.  When limited to this timeframe I generally see the script take about 11s to run on a busy Raspberry Pi 2 on a day with 7 APRS objects defined but takes less than 1s on a modern desktop machine.

#### Calendar Setup

Nothing really special to do for the Google Calendar setup, you can name it anything you want.  But to get the URL, you'll need to go to your APRS calendar's settings and either use the Public address if you have made this calendar public, or use the Private address.  Copy the URL and put it into the $ical variable in the get_defaults function in aprsobjects.pm    Just click the appropriate ICAL button in Google Calendar settings and copy the link it gives you.  You can see an example URL that I have set up in the file to sanity check that your URL looks right.

#### APRS Object calendar entries

When you create calendar entries for your APRS objects you can set the event title to anything you want, this value is not used by this script.  If the event repeats or is an all day event (ie:  a repeater, etc) select those options.  The Description is where the required fields are defined and must be set up correctly or the object won't be properly parsed.  The order of the options does not matter but they must be in the format of FIELD:DATA and separated by a new line.  These are the same fields used in the objects array, so for more details on exactly what the fields mean please see that section.  Example:

TIMEBEFORE:15  
OBJNAME:IRLP-4945  
MHZ:146.940  
LAT:38^02.856N  
LON:84^29.347W  
FREQ:5:00  
OFFSET:-0.600  
TONE:88.5  
HEIGHT:500  
POWER:50  
SYMBOL:I0  
COMMENT:R45m KY4K IRLP node 4945 in Lexington, KY  

If you want to disable an object temporarily you can set it as "Available" under the "Show me as" setting near the bottom of the event entry.  Available implies that the object is disabled (not active), Busy implies it is enabled (active).  I use this to adjust recurring events, such as club meetings.  You can also delete the event if that is more appropriate.

### aprs.pl

The script which does the logic and prints the output of the matching objects.  Unless there is a need to tweak some of the logic there is likely no reason to update this file.

### Todo

#### Send packets directly, not using direwolf

Being able to send packets directly to a TNC would be good, such as a KISS interface.  I need to investigate the best way to do this, but I have a few ideas

 * beacon -d "APZ101 WIDE2-1" -t 60 0 '!DDMM.mmN/DDDMM.mmW$Comment'
 * aprx maybe?
 * Or directly in Perl using KISS
  * http://search.cpan.org/~rbdavison/Device-TNC-0.03/lib/Device/TNC/KISS.pm
  * http://search.cpan.org/dist/Ham-APRS-FAP/IS.pm

#### Clean up ugly event date check nested if statement