use strict;
use warnings;

use constant PAGEOFFSET => 1;

print "\@MIPS_nanomips32_ISA_TRM_01_01_MD01247.pdf[MIPS® Architecture Base: nanoMIPS32™ Instruction Set Technical Reference Manual, Revision 01.01]\n\n";

my $last;

while (<>) {
    if (/^# (\S+) .*?pg\. (\d+)/) {
        my ($o, $p) = (lc $1, $2+PAGEOFFSET);
        print "$o, $p\n";
        $last = $o;
    }

    if (/^:(\S+)/ && $last && $last ne $1) {
        warn "Constructor for opcode $1 is preceded by comment for $last";
    }
}
