package aprsobjects;

require Exporter;
@ISA = ("Exporter");
@EXPORT = ( "get_objects", "get_defaults" );

# Set default options
sub get_defaults {

    # Version control our module to make sure our field expections are correct
    my $moduleversion = '1.1';

    # How long to delay our initial beacon advertisement, in direwolf format (min:sec)
    my $startinterval = '0:30';

    # How many more seconds of delay to add between each additional beacon so advertisements are spaced out
    my $delayinterval = '15';

    # Define our output paths for every object
    my @outputs = ( 'sendto=IG', 'via="WIDE1-1,WIDE2-1"' );

    return ( $moduleversion, $startinterval, $delayinterval, @outputs );
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
# OBJNAME - Name of APRS Object, ax 9 characters
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
        '1|1||||19:00|20:00|15|NET-ARES|146.865|37^43.778N|84^19.012W|5:00|-0.600|192.8|200|50|/N|7pm Madison County ARES Net Mon',
        '2|1||||20:00|21:00|15|NET-SWAP|145.370|37^43.778N|84^19.012W|5:00|-0.600|192.8|200|50|/N|8pm Amateur Swap Net Tue',
        '3|1||||20:30|21:30|15|NET-EMERG|146.715|37^43.778N|84^19.012W|5:00|-0.600|100.0|200|50|/N|8:30pm Wilderness Trail Emergency Net Wed',
        '3|1||||21:00|22:00|15|NET-ARES|146.760|38^02.380N|84^24.170W|5:00|-0.600||750|50|/N|9pm Fayette County ARES Net Wed',
        '4|1||||19:00|21:00|60|MEET-TECH|146.760|38^05.152N|84^29.347W|5:00|-0.600||750|50|/E|7pm BARS Technical Group Thur Basement Red Cross Building',
        '4|1||||19:30|20:30|15|NET-JAWS|145.490|37^53.077N|84^34.430W|5:00|-0.600||150|50|/N|7:30pm JAWS Rag Chew Net Thur',
        '4|1||||20:00|21:00|15|NET-ARES|145.330|38^02.973N|84^45.157W|5:00|-0.600||200|50|/N|8pm Woodford County ARES Net Thurs',
        '4|1||||20:45|21:45|15|NET-PRC|145.430|38^00.389N|84^13.606W|5:00|-0.600|203.5|200|50|/N|8:45pm Pioneer Amateur Radio Club Net Thur',
        '4|1||||21:00|22:00|15|NET-IRLP|146.940|38^02.856N|84^29.943W|5:00|-0.600|88.5|500|50|/N|9pm IRLP Wide Area Net Thur 9pm',
        '6|1||||11:00|13:00|60|BARSSHACK|146.760|38^05.152N|84^29.347W|5:00|-0.600||750|50|/E|11am BARS Shack Open Sat 11-1pm Red Cross Building',
        '6|1||||13:00|15:00|60|WORKSHOP|146.760|38^05.152N|84^29.347W|5:00|-0.600||750|50|/E|1pm BARS Radio Theory and Construction Workshop Sat 1-3pm Basement Red Cross Building',
        '-1|1|8|14|2016|8:00|14:00|60|BARSHAMFS|146.760|38^01.382N|84^54.372W|5:00|-0.600||750|50|/N|8am to 2pm Today BARS Hamfest',
        '-1|1|9|24|2016|8:00|14:00|60|CK-HAMFST|146.865|37^43.778N|84^19.012W|5:00|-0.600|192.8|200|50|/N|8am to 2pm Today Central Kentucky Hamfest',
        '-1|1||||0|0|15|IRLP-4945|146.940|38^02.856N|84^29.943W|10:00|-0.600|88.5|500|50|I0|R45m KY4K IRLP node 4945 in Lexington, KY',
        '-1|1||||0|0|15|146.940/R|146.940|38^02.856N|84^29.943W|10:00|-0.600|88.5|500|50|/r|R45m KY4K IRLP node 4945 in Lexington, KY',
    );
    return (@objects);
}

1;
