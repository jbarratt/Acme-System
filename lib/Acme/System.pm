use strict;
use warnings;
package Acme::System;

use IPC::Run;
use List::Util qw(sum);

#my @vzps = ( "vzps", "-E", $arg{'veid'}, "-o", "pid,comm" );
#my $vzps_output;
#my ( $stdin, $stderr ) = ( undef, undef );
#IPC::Run::run( \@vzps, \$stdin, \$vzps_output, \$stderr );

=method pidsum
    Return the sum of all the PID's on a system
=cut

sub pidsum {
    my @ps_cmd = ("ps", "-Ao", "pid,cmd");
    my ($stdin, $stderr) = (undef, undef);
    my $ps_output;
    IPC::Run::run(\@ps_cmd, \$stdin, \$ps_output, \$stderr); 
    return sum(
        map { /^\s*(\d+)/ ? $1 : 0 }
        split(/\n/, $ps_output)
    );
};

=method vmstat_col
    Given a column name (free, buff, cache, etc) return the value from vmstat
=cut

sub vmstat_col {
    my ($id) = @_;
    my @vmstat_cmd = ("vmstat", "-n", "1", "1");
    my ($stdin, $stderr) = (undef, undef);
    my $vmstat_output;
    IPC::Run::run(\@vmstat_cmd, \$stdin, \$vmstat_output, \$stderr);

    my @lines = map { [ split(/\s+/, $_) ]; } split(/\n/, $vmstat_output);
    for my $i (0 .. scalar(@{$lines[1]})) {
        if($lines[1][$i] eq $id) {
            return $lines[2][$i];
        }
    }
    return undef;
}

1;
