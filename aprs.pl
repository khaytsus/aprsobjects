#!/bin/perl

use strict;
use warnings;

our $VERSION = '0.9';

# Use our module for station-specific settings
use aprsobjects;

# Get default settings
my ( $startinterval, $delayinterval, @outputs ) = get_defaults();

# Get our objects from our aprsobjects package
my (@objects) = get_objects();

my $delay = $startinterval;

foreach my $entry (@objects) {
    my ($DAY,    $ENABLED, $STARTTIME, $ENDTIME, $TIMEBEFORE, $OBJNAME,
        $MHZ,    $OFFSET,  $TONE,      $LAT,     $LON,        $FREQ,
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
    $ENDTIME =~ s/://g;

    # Get the current time and build a numeric string to compare
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst )
        = localtime();
    my $time = sprintf( "%01d%01d", $hour, $min );

    if ( $ENABLED && ( $DAY == $wday || $DAY == -1 ) ) {
        if (   ( $STARTTIME eq 0 && $ENDTIME eq 0 )
            || ( ( $start <= $time ) && ( $time <= $ENDTIME ) ) )
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
            print "\n# " . $OBJNAME . "\n";
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

# Update min:sec reference modified with a delay interval
sub update_delay {
    my ( $delaytmp, $delayintervaltmp ) = @_;
    my ( $sec_min, $sec_sec ) = split( /:/xsm, $delaytmp );
    my $sec_seconds = $sec_min * 60 + $sec_sec + $delayintervaltmp;
    my $min_decmin  = $sec_seconds % 60;
    my $min_min     = ( $sec_seconds - $min_decmin ) / 60;
    my $time        = sprintf( "%d:%02d", $min_min, $min_decmin );
    return $time;
}
