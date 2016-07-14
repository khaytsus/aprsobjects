#!/bin/perl

use strict;
use warnings;
use Data::Dumper;

our $VERSION = '1.2';

# APRS Schedule generator for Direwolf
# Based on http://www.aprs.org/info/netsked.txt
# This outputs objects that match the current day/time against the defined objects

# Suggested usage is to have a Direwolf config template with no emphermal objects in it and concatenate
# that template and this output and use that as the final configuration.  Repeat this every N minutes,
# checking to see if the configuration has changed and if so restart direwolf so it picks up the new info.

# This perl program is generic, so we use our module for station-specific settings
use aprsobjects;

# Get default settings from our aprsobjects module
my ( $debug, $moduleversion, $icalurl, $startinterval, $delayinterval,
    @outputs )
    = get_defaults();

# Test to make sure our versions match so we know our fields are going to be correct
if ( $VERSION ne $moduleversion ) {
    die 'Our program version number '
        . $VERSION
        . ' does not match our module version '
        . $moduleversion . "\n";
}

# Get our initial delay for advertisements which will be incremented for each additional object
my $delay = $startinterval;

# Create our empty objects variable to populate from our module or ical
my @objects;

# See if we're using iCal and if so, make sure iCal::Parser and LWP::Simple are available
my $ical;

if ($icalurl) {
    $ical = eval {
        require iCal::Parser;
        iCal::Parser->import;

        require LWP::Simple;
        LWP::Simple->import(qw($ua get));
        1;
    };
}

# Get the current time and set up variables to use later
my ($lt_sec,  $lt_min,  $lt_hour, $lt_mday, $lt_mon,
    $lt_year, $lt_wday, $lt_yday, $lt_isdst
) = localtime();
$lt_year += 1900;
$lt_mon  += 1;

if ($ical) {

    # Get our objects from our iCal URL
    print "\n### Objects generated from iCal data\n";
    (@objects) = ical_parse($icalurl);
}
else {
    # Get our objects from our aprsobjects module
    print "\n### Objects generated using module data\n";
    (@objects) = get_objects();
}

# Iterate through each entry in the @objects array
foreach my $entry (@objects) {
    my ($DOW,       $ENABLED, $MONTH,      $DAY,     $YEAR,
        $STARTTIME, $ENDTIME, $TIMEBEFORE, $OBJNAME, $MHZ,
        $LAT,       $LON,     $FREQ,       $OFFSET,  $TONE,
        $HEIGHT,    $POWER,   $SYMBOL,     $COMMENT
    ) = split( /\|/xsm, $entry );

    if ($debug) { print "### Object: $entry\n"; }

# Determine the time at which we start advertising the object before the official start time
    my $start;

    # Only modify the start time if we're a timed object
    if ( $STARTTIME ne 0 && $ENDTIME ne 0 ) {

# Set our time before to a negative value so we subtract time from our official start time
        my $timebefore = $TIMEBEFORE * -1;

        # Update the start value to the new time
        $start = update_delay( $STARTTIME, ${timebefore} );
    }
    else {
        $start = $STARTTIME;
    }

    my $time = sprintf( "%02d%02d", $lt_hour, $lt_min );

    # We compare start/end as simple numbers, so strip out the colon
    $start =~ s/://g;
    my $end = $ENDTIME;
    $end =~ s/://g;

# Determine if this object matches the day, is an every-day object, or is dated with todays date
# If the object is enabled make sure that dated events are only matched on their proper date regardless
# of DOW settings, so make sure daily vs single day vs dated events are tested separately.
    if ($ENABLED

        # This object matches a single-day event, not a dated event
        && ((   ( $DOW eq $lt_wday && $DAY !~ /\d+/ )

                # This object matches a daily event, not a dated event
                || ( $DOW eq -1 && $DAY !~ /\d+/ )
            )

# If it's not a single or daily event, test to see if this object matches todays date
            || ( $MONTH eq $lt_mon && $DAY eq $lt_mday && $YEAR eq $lt_year )
        )
        )
    {

# Determine if the object should be advertised based on comparing our adjusted start time or always if start/end are 0
        if (   ( $STARTTIME eq 0 && $ENDTIME eq 0 )
            || ( ( $start <= $time ) && ( $time <= $end ) ) )
        {
            # Handle fields which are optional and may be empty
            my $tone_string = '';
            if ($TONE) {
                $tone_string = ' TONE=' . $TONE;
            }

            my $offset_string = '';
            if ($OFFSET) {
                $offset_string = ' OFFSET=' . $OFFSET;
            }

            my $height_string = '';
            if ($HEIGHT) {
                $height_string = ' HEIGHT=' . $HEIGHT;
            }

            my $power_string = '';
            if ($POWER) {
                $power_string = ' POWER=' . $POWER;
            }

            my $comment_string = '';
            if ($COMMENT) {
                $comment_string = ' COMMENT="' . $COMMENT . '"';
            }

            # Print the beacon info
            # Create a reasonable date string
            my $datestring = '';

            # If we have a start/end time, and we're not a dated event
            if ( $STARTTIME && $DAY !~ /\d+/ ) {
                $datestring = ' (' . $STARTTIME . ' -' . $ENDTIME . ')';
            }

            # If we're a dated event
            if ( $DAY =~ /\d+/ ) {
                $datestring
                    = ' ('
                    . $MONTH . '/'
                    . $DAY . '/'
                    . $YEAR . ') ('
                    . $STARTTIME . ' - '
                    . $ENDTIME . ') ';

            }

            print "\n# " . $OBJNAME . $datestring . "\n";

            foreach my $output (@outputs) {
                print 'OBEACON '
                    . $output
                    . ' DELAY='
                    . $delay
                    . ' EVERY='
                    . $FREQ
                    . ' OBJNAME='
                    . $OBJNAME . ' LAT='
                    . $LAT
                    . ' LONG='
                    . $LON
                    . ' SYMBOL='
                    . $SYMBOL
                    . ' FREQ='
                    . $MHZ
                    . $offset_string
                    . $tone_string
                    . $height_string
                    . $power_string
                    . $comment_string . "\n";

# Update the delay value so each object advertises $delayinterval seconds after the previous one
                $delay = update_delay( $delay, $delayinterval );
            }
        }
    }
}

# Parse our iCal URL and return the same array we use in the module
sub ical_parse {
    my ($url) = @_;

    if ($debug) { print "### ical_parse\n"; }

    # Set our LWP defaults, maybe
    #$ua->timeout(15);

    my $file = get($url);
    if (!defined($file))
    {
        print "\n## iCal download failed (check URL?)\n";
        return;
    }
    my @returnobj;

# Restrict our iCal event parsing to today and tomorrow, as the iCal data is in UTC
# We restrict the results because it takes forever to process lots of events and we only care about today anyway
    my $start_time = sprintf( "%d%02d%02d", $lt_year, $lt_mon, $lt_mday );
    my $end_time   = sprintf( "%d%02d%02d", $lt_year, $lt_mon, $lt_mday + 1 );
    my %defaults = ( start => $start_time, end => $end_time );
    my $parser   = iCal::Parser->new(%defaults);
    my $hash     = $parser->parse_strings($file);

   # Get the events for today (specifically; ignore the rest of the iCal data)
    my $todayhash  = $hash->{events}->{$lt_year}->{$lt_mon}->{$lt_mday};
    my @todayarray = $todayhash;

    # Iterate through each calendar UID (event)
    foreach my $uid (@todayarray) {
        my @uidkeys = keys %$uid;

        # Iterate through each calendar object in this UID
        foreach my $object (@uidkeys) {
            my $DTSTART     = $todayhash->{$object}->{DTSTART};
            my $DTEND       = $todayhash->{$object}->{DTEND};
            my $allday      = $todayhash->{$object}->{allday};
            my $DESCRIPTION = $todayhash->{$object}->{DESCRIPTION};
            my $TRANSP      = $todayhash->{$object}->{TRANSP};
            # Make sure our hours and minutes are padded to two digits
            my $start       = sprintf( "%02d:%02d",
                $DTSTART->{local_c}->{hour},
                $DTSTART->{local_c}->{minute} );
            my $end = sprintf( "%02d:%02d",
                $DTEND->{local_c}->{hour},
                $DTEND->{local_c}->{minute} );
            my $month = $DTSTART->{local_c}->{month};
            my $day   = $DTSTART->{local_c}->{day};
            my $year  = $DTSTART->{local_c}->{year};
            my $dow   = $DTSTART->{local_c}->{day_of_week};

            # If allday isn't defined, set it to 0
            unless ( defined($allday) ) {
                $allday = 0;
            }

            # Clean up values the way we expect them to be for all-day events
            #if ( $start eq "0:0" ) {
            if ($allday) {
                $dow   = "-1";
                $start = "0";
                $end   = "0";
                $day   = '';
                $month = '';
                $year  = '';
            }

# Create a string like we'd use in the aprsobjects module so we can parse it the same
            my $object = build_object(
                $start, $end,  $allday, $dow, $month,
                $day,   $year, $TRANSP, $DESCRIPTION
            );
            push( @returnobj, $object );
        }
    }
    return @returnobj;
}

# Build a string of this objects fields
sub build_object {
    my ($start, $end,  $allday, $dow, $month,
        $day,   $year, $TRANSP, $DESCRIPTION
    ) = @_;

    if ($debug) { print "### build_object\n"; }

    # Split up DESCRIPTION into the fields we expect
    my $objectparts = split_description($DESCRIPTION);

# Use the "TRANSP" attribute to determine if this object is active or not based on Available/Busy in GCal
    my $active = 1;
    if ( $TRANSP eq "TRANSPARENT" ) {
        $active = 0;
    }

    my $object = join( "|",
        $dow, $active, $month, $day, $year, $start, $end, $objectparts );
    return $object;
}

# Split up the description line and return a joined string
sub split_description {
    my ($description) = @_;

# For now, disable uninitialized warnings here so we don't get noise from optional fields
    no warnings 'uninitialized';

    if ($debug) { print "### split_description\n"; }

    # We literally get the string \n for carriage returns here.  Yuck?
    my (@description) = split( /\\n/s, $description );

    my ($timebefore, $objname, $mhz,    $lat,   $lon,    $freq,
        $offset,     $tone,    $height, $power, $symbol, $comment
    );

    foreach my $desc (@description) {
        my ( $key, $value ) = split( /:/, $desc, 2 );
        if ( $key eq "TIMEBEFORE" ) { $timebefore = $value; }
        if ( $key eq "OBJNAME" )    { $objname    = $value; }
        if ( $key eq "MHZ" )        { $mhz        = $value; }
        if ( $key eq "LAT" )        { $lat        = $value; }
        if ( $key eq "LON" )        { $lon        = $value; }
        if ( $key eq "FREQ" )       { $freq       = $value; }
        if ( $key eq "OFFSET" )     { $offset     = $value; }
        if ( $key eq "TONE" )       { $tone       = $value; }
        if ( $key eq "HEIGHT" )     { $height     = $value; }
        if ( $key eq "POWER" )      { $power      = $value; }
        if ( $key eq "SYMBOL" )     { $symbol     = $value; }

# We sometimes get backslashes back from iCal, so we need to strip them back out of the comment
        if ( $key eq "COMMENT" ) {
            $comment = $value;
            $comment =~ s/\\//g;
        }
    }

    my $objectparts = join( "|",
        $timebefore, $objname, $mhz,    $lat,   $lon,    $freq,
        $offset,     $tone,    $height, $power, $symbol, $comment );
    return $objectparts;
}

# Update time reference to reflect desired additional delay
# Used for HH:MM and MM:SS but the calculations are the same.  Pass in negative numbers to get an earlier time.
sub update_delay {
    if ($debug) { print "### update_delay\n"; }
    my ( $delaytmp, $delayintervaltmp ) = @_;
    my ( $sec_min, $sec_sec ) = split( /:/xsm, $delaytmp );
    my $sec_seconds = $sec_min * 60 + $sec_sec + $delayintervaltmp;
    my $min_decmin  = $sec_seconds % 60;
    my $min_min     = ( $sec_seconds - $min_decmin ) / 60;
    my $time        = sprintf( "%d:%02d", $min_min, $min_decmin );
    return $time;
}
