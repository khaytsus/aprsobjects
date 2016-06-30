APRS Objects Generator for Direwolf
================

This script makes it possible to schedule objects to be advertised with Direwolf.  The output of this script is the currently active objects for use in a Direwolf configuration file.  Suggested setup is to create a Direwolf config file with no emphermeral objects in it.  Then have a cron job which runs every N minutes (5 is a good starting point) which copies the current Direwolf configuration file to another filename, then concatenate the output of your template Direwolf config and the output of this script to a new Direwolf config.  Compare the two files; if they are different restart Direwolf so it picks up the new settings.

A very simple example script to do this is included which you can update and include in your setup.

This script is based on the ideas from Bob Bruninga (WB4APR) in http://www.aprs.org/info/netsked.txt

### aprsobjects.pm

You will need to update the objects in aprsobjects.pm with the objects in your area which you wish to advertise.

#### Default options

There are several defaults to set in the get_defaults function

* $startinterval = '0:30';
 * How long to delay our initial beacon advertisement, in direwolf format (min:sec).  In this example, it means Direwolf will wait 30 seconds before it advertises the first object.

* $delayinterval = '15';
 * How many more seconds of delay to add between each additional beacon so advertisements are spaced out.  In this example it means the second object will be avertised 45 seconds after Direolf starts.  The third object 60 seconds, etc.  This is so we're advertising objects at a reasonable speed without congesting the APRS network.  If your local APRS is highly congested I would suggest increasing this delay.

*  @outputs = ( 'sendto=IG', 'via="WIDE1-1,WIDE2-1"' );
 *  Define our output paths for every object that we advertise.  In this example we'll advertise to the internet (igate) and then with the WIDE1-1,WIDE2-1 path.  Adjust for your local configuration and APRS topology, such as only igate, or a more narrow digipeater path.  Be careful with the quotes around the digipeater path.

#### Objects array

* Objects array is a pipe (|) separated list of fields
 * Leave empty for unused field, ie:  |data|data||data|data
 * General Formatting is whatever Direwolf requires for the given field, see examples, Direwolf docs, etc
 * Suggestion:  All day or every day events at the end so emphemeral events are advertised sooner

* Object data description and order
 *  DAY - Sun = 0, Mon = 1, Tue = 2, Wed = 3, Thur = 4, Fri = 5, Sat = 6, Every Day = -1
 * ENABLED - 0 entry is disabled, 1 enabled
 * STARTTIME/ENDTIME - Start/End = 0 implies broadcast all day, HH:MM format
 * TIMEBEFORE - Number of minutes to start advertising object before STARTTIME
 * OBJNAME - Max 9 characters
 * MHZ - Frequency associated with this object
 * LAT/LON - Latitude/Longitude of object
 * FREQ - How often to beacon object
 * OFFSET (OPTIONAL) - Frequency offset if split, repeater input, etc
 * TONE (OPTIONAL) - PL Tone
 * HEIGHT (OPTIONAL) - Height of associated station (repeater, etc)
 * POWER (OPTIONAL) - Power output of associated station
 * SYMBOL - APRS Symbol to use for object
 * COMMENT (OPTIONAL) - Description of object

### aprs.pl

The script which does the logic and prints the output of the matching objects.  Unless there is a need to tweak some of the logic there is likely no reason to update this file.