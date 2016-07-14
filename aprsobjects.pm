package aprsobjects;

require Exporter;
@ISA = ("Exporter");
@EXPORT = ( "get_objects", "get_defaults" );

# Set default options
sub get_defaults {

    # Debug mode
    my $debug = 0;

    # Version control our module to make sure our field expections are correct
    my $moduleversion = '1.2';

    # If using iCal for our source, put the URL here
    my $ical = "https://calendar.google.com/calendar/ical/vmk180ahs4stmati3go5dek4c8%40group.calendar.google.com/private-dbfa0949d58f94bf76f763f75bc8b107/basic.ics";

    # How long to delay our initial beacon advertisement, in direwolf format (min:sec)
    my $startinterval = '0:30';

    # How many more seconds of delay to add between each additional beacon so advertisements are spaced out
    my $delayinterval = '15';

    # Define our output paths for every object
    my @outputs = ( 'sendto=IG', 'via="WIDE1-1,WIDE2-1"' );

    return ( $debug, $moduleversion, $ical, $startinterval, $delayinterval, @outputs );
}

# Objects array is a pipe (|) separated list of fields
## Leave empty for unused field, ie:  |data|data||data|data
## General Formatting is whatever Direwolf requires for the given field, see examples, Direwolf docs, etc
## Suggestion:  All day or every day events at the end so emphemeral events are advertised sooner

# DOW - Sun = 0, Mon = 1, Tue = 2, Wed = 3, Thur = 4, Fri = 5, Sat = 6, Every Day = -1
# ENABLED - 0 entry is disabled, 1 enabled
# MONTH - Month for a dated event (1-12)
# DAY - Day of the month for a dated event (1-31)
# YEAR - Year for a dated event (2016)
# STARTTIME/ENDTIME - Start/End = 0 implies broadcast all day, HH:MM format
# TIMEBEFORE - Number of minutes to start advertising object before STARTTIME
# OBJNAME - Name of APRS Object, max 9 characters
# MHZ - Frequency associated with this object
# LAT/LON - Latitude/Longitude of object
# FREQ - How often to beacon object
# OFFSET (OPTIONAL) - Frequency offset if split, repeater input, etc
# TONE (OPTIONAL) - PL Tone
# HEIGHT (OPTIONAL) - Height of associated station (repeater, etc)
# POWER (OPTIONAL) - Power output of associated station
# SYMBOL - APRS Symbol to use for object
# COMMENT (OPTIONAL) - Description of object

sub get_objects {
    my @objects = (
        # DOW ENABLED MONTH DAY YEAR STARTTIME ENDTIME TIMEBEFORE OBJNAME MHZ LAT LON FREQ OFFSET TONE  HEIGHT POWER SYMBOL COMMENT
        '0|1||||21:00|22:00|15|NETATVCOM|146.760|38^02.380N|84^24.170W|5:00|-0.600||750|50|/N|9pm R30m AVT and Specialized Communications Net Sun',
        '-1|1|9|24|2016|8:00|14:00|60|CK-HAMFST|146.865|37^43.778N|84^19.012W|5:00|-0.600|192.8|200|50|/E|8am to 2pm Today Central Kentucky Hamfest',
        '-1|1||||0|0|15|146.940/R|146.940|38^02.856N|84^29.943W|10:00|-0.600|88.5|500|50|/r|R45m KY4K IRLP node 4945 in Lexington, KY',
    );
    return (@objects);
}

1;
