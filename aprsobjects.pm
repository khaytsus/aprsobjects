package aprsobjects;

require Exporter;
@ISA = ("Exporter");
@EXPORT = ( "get_objects", "get_defaults" );

# Set default options
sub get_defaults {

    # How long to delay our initial beacon advertisement, in direwolf format (min:sec)
    my $startinterval = '1:00';

    # How many more seconds of delay between advertising additional beacons
    my $delayinterval = '15';

    # Define our output paths for every object
    my @outputs = ( 'sendto=IG', 'via="WIDE1-1,WIDE2-1"' );

    return ( $startinterval, $delayinterval, @outputs );
}

# Objects array is a pipe (|) separated list of fields
# $DAY,$ENABLED,$STARTTIME,$ENDTIME,$TIMEBEFORE, $OBJNAME,$MHZ,$OFFSET,$TONE,$LAT,$LON,$FREQ,$HEIGHT,$POWER,$SYMBOL,$COMMENT

# Required Fields
## DAY, ENABLED, STARTTIME, ENDTIME, TIMEBEFORE, OBJNAME, MHZ, LAT, LON, FREQ, SYMBOL
## Leave empty for unused field, ie:  |data|data||data|data

# DAY
## Sun = 0, Mon = 1, Tue = 2, Wed = 3, Thur = 4, Fri = 5, Sat = 6, Every Day = -1

# ENABLED
## 0 entry is disabled, 1 enabled

# STARTTIME/ENDTIME
## Start/End = 0 implies broadcast all day, HH:MM format

# TIMEBEFORE
## Number of minutes to start advertising object before STARTTIME

# Name
## Max 9 characters

# General Formatting
## Whatever Direwolf requires for the given field, see examples, Direwolf docs, etc

sub get_objects {
    my @objects = (
        '-1|1|0|0|15|IRLP-4945|146.940|-0.600|88.5|38^02.856N|84^29.943W|10:00|500|50|I0|R45m KY4K IRLP node 4945 in Lexington, KY',
        '-1|1|0|0|15|146.940/R|146.940|-0.600|88.5|38^02.856N|84^29.943W|10:00|500|50|/r|R45m KY4K IRLP node 4945 in Lexington, KY',
        '0|1|21:00|22:00|15|ATVCOMNET|146.760|-0.600||38^02.380N|84^24.170W|10:00|750|50|/N|AVT and Specialized Communications Net Sun 9pm',
        '1|1|19:00|20:00|15|ARES-NET|146.865|-0.600|192.8|37^43.778N|84^19.012W|10:00|200|50|/N|Madison County ARES Net Mon 7pm',
        '2|1|20:00|21:00|15|SWAP-NET|145.370|-0.600|192.8|37^43.778N|84^19.012W|10:00|200|50|/N|Amateur Swap Net Tue 8pm',
        '3|1|20:30|21:30|15|EMERG-NET|146.715|-0.600|100.0|37^43.778N|84^19.012W|10:00|200|50|/N|Wilderness Trail Emergency Net Wed 8:30pm',
        '3|1|21:00|22:00|15|ARES-NET|146.760|-0.600||38^02.380N|84^24.170W|10:00|750|50|/N|Fayette County ARES Net Wed 9pm',
        '4|1|19:00|20:00|60|TECH-MEET|146.760|-0.600||38^05.152N|84^29.347W|10:00|750|50|/E|BARS Technical Group Thur 7pm Basement Red Cross Building',
        '4|1|19:30|20:00|15|JAWS-NET|145.490|-0.600||37^53.077N|84^34.430W|10:00|150|50|/N|JAWS Rag Chew Net Thur 7:30pm',
        '4|1|20:00|21:00|15|ARES-NET|145.330|-0.600||38^02.973N|84^45.157W|10:00|200|50|/N|Woodford County ARES Net Thurs 8pm',
        '4|1|20:45|21:45|15|PRC-NET|145.430|-0.600|203.5|38^00.389N|84^13.606W|10:00|200|50|/N|Pioneer Amateur Radio Club Net Thur 8:45pm',
        '4|1|21:00|22:00|15|IRLP-NET|146.940|-0.600|88.5|38^02.856N|84^29.943W|10:00|500|50|/N|IRLP Wide Area Net Thur 9pm',
    );
    return (@objects);
}

1;
