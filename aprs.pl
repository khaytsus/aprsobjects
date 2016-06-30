#!/bin/perl

use strict;
use warnings;

our $VERSION = '0.9';

# APRS Schedule generator for Direwolf
# Based on http://www.aprs.org/info/netsked.txt
# This outputs objects that match the current day/time against the defined objects

# Suggested usage is to have a Direwolf config template with no emphermal objects in it and concatenate
# that template and this output and use that as the final configuration.  Repeat this every N minutes,
# checking to see if the configuration has changed and if so restart direwolf so it picks up the new info.

# This perl program is generic, so we use our module for station-specific settings
use aprsobjects;

# Get default settings
my ( $startinterval, $delayinterval, @outputs ) = get_defaults();

# Get our objects from our aprsobjects package
my (@objects) = get_objects();

my $delay = $startinterval;

foreach my $entry (@objects) {
    my ($DAY,    $ENABLED, $STARTTIME, $ENDTIME, $TIMEBEFORE, $OBJNAME,
        $MHZ,    $LAT,     $LON,       $FREQ,    $OFFSET,     $TONE,
        $HEIGHT, $POWER,   $SYMBOL,    $COMMENT
    ) = split( /\|/xsm, $entry );

    # Start advertising $TIMEBEFORE minutes before $STARTTIME
    my $start;

    # Only modify the start time if we're a timed object
    if ( $STARTTIME ne 0 && $ENDTIME ne 0 ) {
        my $timebefore = $TIMEBEFORE * -1;
        $start = update_delay( $STARTTIME, ${timebefore} );
    }
    else {
        $start = $STARTTIME;
    }

    # We handle start/end as simple numbers, so strip out the colon
    $start =~ s/://g;
    my $end = $ENDTIME;
    $end =~ s/://g;

    # Get the current time and build a numeric string to compare
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst )
        = localtime();
    my $time = sprintf( "%02d%02d", $hour, $min );
    if ( $ENABLED && ( $DAY == $wday || $DAY == -1 ) ) {
        if (   ( $STARTTIME eq 0 && $ENDTIME eq 0 )
            || ( ( $start <= $time ) && ( $time <= $end ) ) )
        {
            # Handle data which might be empty
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

            #Print the beacon info
            print "\n# "
                . $OBJNAME . " ("
                . $STARTTIME . " - "
                . $ENDTIME . ")\n";
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
                $delay = update_delay( $delay, $delayinterval );
            }
        }
    }
}

# Update time reference to reflect desired additional delay
# Used for HH:MM and MM:SS but the calculations are the same
sub update_delay {
    my ( $delaytmp, $delayintervaltmp ) = @_;
    my ( $sec_min, $sec_sec ) = split( /:/xsm, $delaytmp );
    my $sec_seconds = $sec_min * 60 + $sec_sec + $delayintervaltmp;
    my $min_decmin  = $sec_seconds % 60;
    my $min_min     = ( $sec_seconds - $min_decmin ) / 60;
    my $time        = sprintf( "%d:%02d", $min_min, $min_decmin );
    return $time;
}
