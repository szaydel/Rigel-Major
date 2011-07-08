#!/usr/perl5/bin/perl -w
#
## benr@cuddletech.com
## arc_summary.pl v0.3
#
# Simplified BSD License (http://www.opensource.org/licenses/bsd-license.php)
# Copyright (c) 2008, Ben Rockwood (benr@cuddletech.com)
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, 
# are permitted provided that the following conditions are met:
#    * Redistributions of source code must retain the above copyright notice, this 
#	list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright notice, 
#	this list of conditions and the following disclaimer in the documentation 
#	and/or other materials provided with the distribution.
#    * Neither the name of the Ben Rockwood nor the names of its contributors may be 
#	used to endorse or promote products derived from this software without specific 
#	prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS 
# OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY 
# AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER 
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT 
# OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

use strict;
use Sun::Solaris::Kstat;



my $Kstat = Sun::Solaris::Kstat->new();

### System Memory ###
my $phys_pages = ${Kstat}->{unix}->{0}->{system_pages}->{physmem};
my $free_pages = ${Kstat}->{unix}->{0}->{system_pages}->{freemem};
my $lotsfree_pages = ${Kstat}->{unix}->{0}->{system_pages}->{lotsfree};
my $pagesize = `pagesize`;

my $phys_memory = ($phys_pages * $pagesize);
my $free_memory = ($free_pages * $pagesize);
my $lotsfree_memory = ($lotsfree_pages * $pagesize);

print "System Memory:\n";
printf("\t Physical RAM: \t%d MB\n", $phys_memory / 1024 / 1024);
printf("\t Free Memory : \t%d MB\n", $free_memory / 1024 / 1024);
printf("\t LotsFree: \t%d MB\n", $lotsfree_memory / 1024 / 1024);
print "\n";
##########################


#### Tunables #####################
my @tunables = `grep zfs /etc/system`;
print "ZFS Tunables (/etc/system):\n";
foreach(@tunables){
        chomp($_);
        print "\t $_\n";
}
print "\n";

#### ARC Sizing ###############
my $mru_size = ${Kstat}->{zfs}->{0}->{arcstats}->{p};
my $target_size = ${Kstat}->{zfs}->{0}->{arcstats}->{c};
my $arc_min_size = ${Kstat}->{zfs}->{0}->{arcstats}->{c_min};
my $arc_max_size = ${Kstat}->{zfs}->{0}->{arcstats}->{c_max};

my $arc_size = ${Kstat}->{zfs}->{0}->{arcstats}->{size};
my $mfu_size = ${target_size} - $mru_size;
my $mru_perc = 100*($mru_size / $target_size);
my $mfu_perc = 100*($mfu_size / $target_size);


print "ARC Size:\n";
printf("\t Current Size:             %d MB (arcsize)\n", $arc_size / 1024 / 1024);
printf("\t Target Size (Adaptive):   %d MB (c)\n", $target_size / 1024 / 1024);
printf("\t Min Size (Hard Limit):    %d MB (zfs_arc_min)\n", $arc_min_size / 1024 / 1024);
printf("\t Max Size (Hard Limit):    %d MB (zfs_arc_max)\n", $arc_max_size / 1024 / 1024);

print "\nARC Size Breakdown:\n";

printf("\t Most Recently Used Cache Size: \t %2d%% \t%d MB (p)\n", $mru_perc, $mru_size / 1024 / 1024);
printf("\t Most Frequently Used Cache Size: \t %2d%% \t%d MB (c-p)\n", $mfu_perc, $mfu_size / 1024 / 1024);
print "\n";
##################################

#my $arc_size = ${Kstat}->{zfs}->{0}->{arcstats}->{size};

        

####### ARC Efficency #########################
my $arc_hits = ${Kstat}->{zfs}->{0}->{arcstats}->{hits};
my $arc_misses = ${Kstat}->{zfs}->{0}->{arcstats}->{misses};
my $arc_accesses_total = ($arc_hits + $arc_misses);

my $arc_hit_perc = 100*($arc_hits / $arc_accesses_total);
my $arc_miss_perc = 100*($arc_misses / $arc_accesses_total);


my $mfu_hits = ${Kstat}->{zfs}->{0}->{arcstats}->{mfu_hits};
my $mru_hits = ${Kstat}->{zfs}->{0}->{arcstats}->{mru_hits};
my $mfu_ghost_hits = ${Kstat}->{zfs}->{0}->{arcstats}->{mfu_ghost_hits};
my $mru_ghost_hits = ${Kstat}->{zfs}->{0}->{arcstats}->{mru_ghost_hits};
my $anon_hits = $arc_hits - ($mfu_hits + $mru_hits + $mfu_ghost_hits + $mru_ghost_hits);

my $real_hits = ($mfu_hits + $mru_hits);
my $real_hits_perc = 100*($real_hits / $arc_accesses_total);

### These should be based on TOTAL HITS ($arc_hits)
my $anon_hits_perc = 100*($anon_hits / $arc_hits);
my $mfu_hits_perc = 100*($mfu_hits / $arc_hits);
my $mru_hits_perc = 100*($mru_hits / $arc_hits);
my $mfu_ghost_hits_perc = 100*($mfu_ghost_hits / $arc_hits);
my $mru_ghost_hits_perc = 100*($mru_ghost_hits / $arc_hits);


my $demand_data_hits = ${Kstat}->{zfs}->{0}->{arcstats}->{demand_data_hits};
my $demand_metadata_hits = ${Kstat}->{zfs}->{0}->{arcstats}->{demand_metadata_hits};
my $prefetch_data_hits = ${Kstat}->{zfs}->{0}->{arcstats}->{prefetch_data_hits};
my $prefetch_metadata_hits = ${Kstat}->{zfs}->{0}->{arcstats}->{prefetch_metadata_hits};

my $demand_data_hits_perc = 100*($demand_data_hits / $arc_hits);
my $demand_metadata_hits_perc = 100*($demand_metadata_hits / $arc_hits);
my $prefetch_data_hits_perc = 100*($prefetch_data_hits / $arc_hits);
my $prefetch_metadata_hits_perc = 100*($prefetch_metadata_hits / $arc_hits);


my $demand_data_misses = ${Kstat}->{zfs}->{0}->{arcstats}->{demand_data_misses};
my $demand_metadata_misses = ${Kstat}->{zfs}->{0}->{arcstats}->{demand_metadata_misses};
my $prefetch_data_misses = ${Kstat}->{zfs}->{0}->{arcstats}->{prefetch_data_misses};
my $prefetch_metadata_misses = ${Kstat}->{zfs}->{0}->{arcstats}->{prefetch_metadata_misses};

my $demand_data_misses_perc = 100*($demand_data_misses / $arc_misses);
my $demand_metadata_misses_perc = 100*($demand_metadata_misses / $arc_misses);
my $prefetch_data_misses_perc = 100*($prefetch_data_misses / $arc_misses);
my $prefetch_metadata_misses_perc = 100*($prefetch_metadata_misses / $arc_misses);

my $prefetch_data_total = ($prefetch_data_hits + $prefetch_data_misses);
my $prefetch_data_perc = "00";
if ($prefetch_data_total > 0 ) {
        $prefetch_data_perc = 100*($prefetch_data_hits / $prefetch_data_total);
}

my $demand_data_total = ($demand_data_hits + $demand_data_misses);
my $demand_data_perc = 100*($demand_data_hits / $demand_data_total);


print "ARC Efficency:\n";
printf("\t Cache Access Total:        \t %d\n", $arc_accesses_total);
printf("\t Cache Hit Ratio:      %2d%%\t %d   \t[Defined State for buffer]\n", $arc_hit_perc, $arc_hits);
printf("\t Cache Miss Ratio:     %2d%%\t %d   \t[Undefined State for Buffer]\n", $arc_miss_perc, $arc_misses);
printf("\t REAL Hit Ratio:       %2d%%\t %d   \t[MRU/MFU Hits Only]\n", $real_hits_perc, $real_hits);
print "\n";
printf("\t Data Demand   Efficiency:    %2d%%\n", $demand_data_perc);
if ($prefetch_data_total == 0){ 
        printf("\t Data Prefetch Efficiency:    DISABLED (zfs_prefetch_disable)\n");
} else {
        printf("\t Data Prefetch Efficiency:    %2d%%\n", $prefetch_data_perc);
}
print "\n";


print "\tCACHE HITS BY CACHE LIST:\n";
if ( $anon_hits < 1 ){
        printf("\t  Anon:                       --%% \t Counter Rolled.\n");
} else {
        printf("\t  Anon:                       %2d%% \t %d            \t[ New Customer, First Cache Hit ]\n", $anon_hits_perc, $anon_hits);
}
printf("\t  Most Recently Used:         %2d%% \t %d (mru)      \t[ Return Customer ]\n", $mru_hits_perc, $mru_hits);
printf("\t  Most Frequently Used:       %2d%% \t %d (mfu)      \t[ Frequent Customer ]\n", $mfu_hits_perc, $mfu_hits);
printf("\t  Most Recently Used Ghost:   %2d%% \t %d (mru_ghost)\t[ Return Customer Evicted, Now Back ]\n", $mru_ghost_hits_perc, $mru_ghost_hits);
printf("\t  Most Frequently Used Ghost: %2d%% \t %d (mfu_ghost)\t[ Frequent Customer Evicted, Now Back ]\n", $mfu_ghost_hits_perc, $mfu_ghost_hits);

print "\tCACHE HITS BY DATA TYPE:\n";
printf("\t  Demand Data:                %2d%% \t %d \n", $demand_data_hits_perc, $demand_data_hits);
printf("\t  Prefetch Data:              %2d%% \t %d \n", $prefetch_data_hits_perc, $prefetch_data_hits);
printf("\t  Demand Metadata:            %2d%% \t %d \n", $demand_metadata_hits_perc, $demand_metadata_hits);
printf("\t  Prefetch Metadata:          %2d%% \t %d \n", $prefetch_metadata_hits_perc, $prefetch_metadata_hits);

print "\tCACHE MISSES BY DATA TYPE:\n";
printf("\t  Demand Data:                %2d%% \t %d \n", $demand_data_misses_perc, $demand_data_misses);
printf("\t  Prefetch Data:              %2d%% \t %d \n", $prefetch_data_misses_perc, $prefetch_data_misses);
printf("\t  Demand Metadata:            %2d%% \t %d \n", $demand_metadata_misses_perc, $demand_metadata_misses);
printf("\t  Prefetch Metadata:          %2d%% \t %d \n", $prefetch_metadata_misses_perc, $prefetch_metadata_misses);

print "---------------------------------------------\n"
###############################################
