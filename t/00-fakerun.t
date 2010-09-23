#!perl
package Test::Acme::System;
use Test::More;
use Acme::System;
use Test::MockModule;
use Data::Section -setup;

# magic; Data::Section wants this to be a module, not a test file.
# trick into thinking this hashref is a member of Test::Acme::System
my $data = {}; bless $data;

# override the real run object with one that will use the __DATA__ block
my $module = new Test::MockModule('IPC::Run');
$module->mock('run', \&mock_ipc_run);

# Actually "run the tests", using the canned results from the __DATA__ block
cmp_ok(Acme::System::pidsum(), "==", 8278);

cmp_ok(Acme::System::vmstat_col("buff"), "==", 194240);
cmp_ok(Acme::System::vmstat_col("si"), "==", 0);
cmp_ok(Acme::System::vmstat_col("cs"), "==", 51);
cmp_ok(Acme::System::vmstat_col("swpd"), "==", 648);


done_testing;

sub mock_ipc_run {
    my($cmd, $stdin, $stdout, $stderr) = @_;
    $$stdout = ${$data->section_data(join(" ", @$cmd))};
}

__DATA__
__[ ps -Ao pid,cmd ]__
  PID CMD
    1 init [2]  
    3 [migration/0]
    7 [khelper]
  171 [pdflush]
  173 [aio/0]
  725 [ata/0]
  851 [kjournald]
  927 udevd --daemon
 1657 /sbin/portmap
 1876 /usr/sbin/rsyslogd -c3
 1887 /usr/sbin/acpid
__[ vmstat -n 1 1 ]__
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 0  0    648  85932 194240 119124    0    0     0     5    2   51  0  0 100  0
__END__
