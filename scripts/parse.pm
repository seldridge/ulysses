#!/usr/bin/perl

# I need to reset variables between file processing steps

sub usage_event_format() {
    my $usage_event_string = <<'END';
Event format should look exactly like the following (no leading space):

[Level] [Gender] [Event] [Championship]? [Flight]?

  Level may be one of:
    Pre-Preliminary    Preliminary    Pre-Juvenile    Juvenile
    Intermediate       Novice         Junior          Senior
    High               Low
  Gender may be one of and is not used for team events:
    Men                Women          Girls           Boys
  Event may be one of:
    Short              Free           Dance           Team
  Championship is an optional identifier
  Flight is an optional, single uppercase letter from A-Z

The following are examples of valid events:

Preliminary Dance B
Junior Ladies Free Championship
High Team

END
    print $usage_event_string;
};

sub usage_skater_format() {
    my $usage_skater_string = <<'END';
Skater format should look exactly like the following (two leading
spaces and separated by commas):

  [Numerical Placement], [Skater Name], [School]

  Numerical Placement is a number or a W. Ties are indicated by giving
  two skaters the same placement.

  Skater Name can be any number of letters and can include "'" and
  "-".

  School can be any number of letters and contain spaces (no special
  characters). School name must be the same for all results.

END
    print $usage_skater_string;
};

$results_dir = "./results";

%level_hash = (
    'Pre-Preliminary' => 1, 'Preliminary'   => 2, 'Pre-Juvenile' => 3, 'Juvenile' => 4,
    'Intermediate'    => 5, 'Novice'        => 6, 'Junior'       => 7, 'Senior'   => 8,
    'Low'             => 1, 'High'          => 8
    );
%level_abbrv = (
    'Preliminary'  => 'Pre.', 'Juvenile'      => 'Juv.',
    'Intermediate' => 'Int.', 'Novice'        => 'Nov.',
    'Junior'       => 'Jun.', 'Senior'        => 'Sen.',
    'Championship' => 'Ch.',  'International' => 'Intern.',
    'Men'          => 'M.',   'Ladies'        => 'L.'
    );
%school_abbrv = (
    'California Berkeley' => 'Cal',
    'California Los Angeles' => 'UCLA',
    'University' => '',
    'of ' => '',
    'College' => ''
    );
%level_hash_dance = (
    'Preliminary'     => 1, 'Juvenile' => 2, 'Intermediate' => 3, 'Novice' => 4,
    'Junior'          => 5, 'Senior'   => 6, 'Gold'         => 7, 'International' => 8
    );
$levels = "Pre-Preliminary|Preliminary|Pre-Juvenile|Juvenile|Intermediate|".
    "Novice|Junior|Senior|Gold|International|Low|High";


if ($#ARGV+1 == 2) {
    print $ARGV[0],"\n";
}
else {
    die "Expected 2 inputs to parse.pm, found ",$#ARGV+1;
}

$file_results = $ARGV[0];
print "Processing $file_results\n";

$file_out = $ARGV[1];
# $file_dat = $file_results;
# $file_dat =~ s/results$/dat/;
$file_tex = $file_results;
$file_tex = s/^results/latex/;
$file_tex = s/results$/tex/;

open FILE_RESULTS, "<", $file_results or
    die "[ERROR] Unable to open <$file_results";
# open FILE_DAT, ">", $file_dat or die "Unable to open >$file_dat";

while (<FILE_RESULTS>) {
    $_ =~ s///;
    # Ignore line
    if ($_ =~ m/[#]+/){
    }
    # Line is a group
    elsif ($_ =~ m/^([a-zA-Z].+)$/){
        $event_name = $1;
    }
    # Line is a skater
    else{
        push @{$event_hash{$event_name}}, $_;
    }
}

foreach $event (sort keys %event_hash){
    undef $level;
    undef $gender;
    undef $event_type;
    undef $championship;
    undef $flight;
    $championship = 0;
    if ($event =~ m/^($levels) (Ladies|Men|Girls|Boys)? ?(Dance|Free|Short|Team) ?(Championship)? ?([A-Z])?$/) {
        $level = $1;
        $gender = $2;
        $event_type = $3;
        $flight = $5;
        if ($4 =~ m/Championship/ | $event =~ m/International/) {
            $championship = 1;
        }
    }
    else {
        print "\n[ERROR] Unexpected event format:\n\"$event\"\n\n";
        usage_event_format and
            die "Event processing failed to match known template\n  ";
    }
    $num_skaters = 0;
    # compute number of skaters
    foreach (@{$event_hash{$event}}){
# If the number of points awarded decreases as a result of a
# withdrawl, the commented out section below should be used.
        if ($_ !~ m/^[ ]+W,/){
            $num_skaters++;
        }
        elsif ($num_skaters<5){
            $num_skaters++;
        }
#                $num_skaters++;
    }
    # compute starting point value
    if ($num_skaters >= 5){
        $points = 5 + $championship * 2;
    }
    elsif ($num_skaters >= 4){
        $points = 4 + $championship * 2;
    }
    elsif ($num_skaters >= 2){
        $points = 3 + $championship * 2;
    }
    else {
        $points = 1 + $championship * 2;
    }
    # compute tie array
    $old_placement = 0;
    $skater_count = 0;
    $tie_count = 1;
    foreach (@{$event_hash{$event}}){
        if ($_ =~ m/($old_placement)/){
            $tie_count++;
        }
        else {
            $old_placement++;
            if ($skater_count > 0){ # if this is not the first skater
                $points_total = 0;
                for ($i = $skater_count - $tie_count; $i < $skater_count; $i++){
                    chomp(@{$event_hash{$event}}[$i]);
                    $points_total += $points;
                    if (($points > 0 + $championship * 3) & !()){
                        $points --;
                    }
                    else {
                        $points = 0;
                    }
                }
                $points_total /= $tie_count;
                for ($i = $skater_count - $tie_count; $i < $skater_count; $i++){
                    @{$event_hash{$event}}[$i] .= ",$points_total";
                    if (@{$event_hash{$event}}[$i] =~
                        m/^[ ]+([0-9W]+),([a-zA-Z'\- ]+),([a-zA-Z ]+),([.0-9]+)$/) {
                        $skater = $2;
                        $school = $3;
                    }
                    else {
                        print "\n[ERROR] Unexpected skater format:\n";
                        print "\"@{$event_hash{$event}}[$i]\"\n\n";
                        usage_skater_format and
                            die "Skater placement failed to match template\n  ";
                    }
                    $skater_start_hash{$skater} += 1;
                    $skater_school_hash{$skater} = $school;
                    # compute a numerical analog for the level
                    # using the level hash declared up top. If
                    # this event is a dance, subtract 2 levels
                    # as these have a built in offset of 2.
                    if ($event_type =~ m/Dance/) {
                        $level_num = $level_hash_dance{$level};
                    }
                    else {
                        $level_num = $level_hash{$level};
                    }
                    @{$level_starts{$school}}[$level_num] += 1;
                    if (@{$event_hash{$event}}[$i] !~ m/^[ ]+W/){
                        $skater_point_hash{$skater} += $points_total;
                        $skater_withdrawl_hash{$skater} += 0;
                        $team_withdrawls{$school} += 0;
                        @{$level_points{$school}}[$level_num] += $points_total;
                        if ($event =~ m/Dance/){
                            $dance_points{$school} += $points_total;
                        }
                        if ($event =~ m/Short/){
                            $short_points{$school} += $points_total;
                        }
                        if ($event =~ m/Free/){
                            if ($event =~ m/Championship/){
                                $championship_points{$school} += $points_total;
                            }
                            else {
                                $free_points{$school} += $points_total;
                            }
                        }
                        if ($event =~ m/Team/){
                            $team_points{$school} += $points_total;
                        }
                    }
                    else{
                        $skater_point_hash{$skater} += 0;
                        $skater_withdrawl_hash{$skater} += 1;
                        $team_withdrawls{$school} += 1;
                        @{$level_points{$school}}[$level_num] += 0;
                    }
                    if ($event =~ m/Dance/){
                        $dance_starts{$school} += 1;
                    }
                    if ($event =~ m/Short/){
                        $short_starts{$school} += 1;
                    }
                    if ($event =~ m/Free/){
                        if ($event =~ m/Championship/){
                            $championship_starts{$school} += 1;
                        }
                        else {
                            $free_starts{$school} += 1;
                        }
                    }
                    if ($event =~ m/Team/){
                        $team_starts{$school} += 1;
                    }
                }
                $tie_count = 1;
            }
        }
        $skater_count++;
    }
    # last place skater handling
    $points_total = 0;
    for ($i = $skater_count - $tie_count; $i < $skater_count; $i++){
        chomp(@{$event_hash{$event}}[$i]);
        $points_total += $points;
        if ($points > 0 + $championship * 3){
            $points --;
        }
        else {
            $points = 0;
        }
    }
    $points_total /= $tie_count;
    for ($i = $skater_count - $tie_count; $i < $skater_count; $i++){
        if (@{$event_hash{$event}}[$i] =~ m/^[ ]+([0-9W]+),([-a-zA-Z' ]+),([a-zA-Z ]+)$/) {
            $skater = $2;
            $school = $3;
        }
        else {
            print "\n[ERROR] Unexpected skater format:\n";
            print "\"@{$event_hash{$event}}[$i]\"\n\n";
            usage_skater_format and
                die "Skater placement failed to match template\n  ";
        }
        if ($event_type =~ m/Dance/) {
            $level_num = $level_hash_dance{$level};
        }
        else {
            $level_num = $level_hash{$level};
        }
        @{$level_starts{$school}}[$level_num] += 1;
        if (@{$event_hash{$event}}[$i] =~ m/^[ ]+W/){
            @{$event_hash{$event}}[$i] .= ",0";
            $skater_point_hash{$skater} += 0;
            $skater_withdrawl_hash{$skater} += 1;
            $team_withdrawls{$school} += 1;
            @{$level_points{$school}}[$level_num] += 0;
        }
        else{
            @{$event_hash{$event}}[$i] .= ",$points_total";
            $skater_point_hash{$skater} += $points_total;
            $skater_withdrawl_hash{$skater} += 0;
            $team_withdrawls{$school} += 0;
            @{$level_points{$school}}[$level_num] += $points_total;
            if ($event =~ m/Dance/){
                $dance_points{$school} += $points_total;
            }
            if ($event =~ m/Short/){
                $short_points{$school} += $points_total;
            }
            if ($event =~ m/Free/){
                if ($event =~ m/Championship/){
                    $championship_points{$school} += $points_total;
                }
                else {
                    $free_points{$school} += $points_total;
                }
            }
            if ($event =~ m/Team/){
                $team_points{$school} += $points_total;
            }
        }
        $skater_start_hash{$skater} += 1;
        $skater_school_hash{$skater} = $school;
        if ($event =~ m/Dance/){
            $dance_starts{$school} += 1;
        }
        if ($event =~ m/Short/){
            $short_starts{$school} += 1;
        }
        if ($event =~ m/Free/){
            if ($event =~ m/Championship/){
                $championship_starts{$school} += 1;
            }
            else {
                $free_starts{$school} += 1;
            }
        }
        if ($event =~ m/Team/){
            $team_starts{$school} += 1;
        }
    }
}

my $string_out = "---------------------------------------- Event Results\n";
foreach $event_name (sort keys %event_hash){
    $string_out .= $event_name."\n";
    foreach (@{$event_hash{$event_name}}){
        $string_out .= $_."\n";
    }
}

foreach $event_name (sort keys %event_hash){
    foreach (@{$event_hash{$event_name}}){
        if ($_ =~ m/^[ ]+([0-9W]+),([a-zA-Z-'. ]+),([a-zA-Z ]+),([.0-9]+)$/) {
            $school = $3;
            $points = $4;
        }
        else {
            print "\n[ERROR] Unexpected skater format:\n\"$_\"\n\n";
            usage_skater_format and
                die "Skater placement failed to match template\n  ";
        }
        $total_hash{$school} += $points;
        $total_starts_hash{$school} += 1;
        $event_hash_total{$event_name}{$school} += $points;
        $starts_hash{$event_name}{$school} += 1;
    }
}

# $string_out .= "---------------------------------------- Skater Results\n";
# $string_out .= "Skater,School,Points,Starts,Withdrawls,Points/Start\n";
# foreach $school (sort {$skater_school_hash{$a} <=> $skater_school_hash{$b}} keys %skater_school_hash){
#     foreach $skater (sort {$skater_point_hash{$b} <=> $skater_point_hash{$a}} keys %skater_point_hash){
#         if ($skater_school_hash{$skater} eq $skater_school_hash{$school}) {
#             $string_out .= $skater,",",$skater_school_hash{$skater},",",$skater_point_hash{$skater},",",$skater_start_hash{$skater},",",$skater_withdrawl_hash{$skater},",",sprintf("%0.2f",$skater_point_hash{$skater}/$skater_start_hash{$skater}),"\n";
#         }
#         # else {
#         #     $string_out .= $skater_school_hash{$skater}."->".$skater_school_hash{$school}."\n";
#         # }
#     }
# }

$string_out .= "---------------------------------------- Team Points & Starts\n";
$string_out .= "School,Points,Starts,Withdrawls,Points/Start\n";
# print FILE_DAT "School Points Starts Withdrawls Points_Start\n";
foreach $school (sort {$total_hash{$b} <=> $total_hash{$a}} keys %total_hash){
    $string_out .= "$school,$total_hash{$school},$total_starts_hash{$school},";
    $string_out .= "$team_withdrawls{$school},";
    $string_out .= sprintf("%0.2f",$total_hash{$school}/$total_starts_hash{$school});
    $string_out .= "\n";
    # $string_out .= $school,",",$total_hash{$school},",",$total_starts_hash{$school},",",sprintf("%0.2f",$total_hash{$school}/$total_starts_hash{$school}),"\n";
    # $string_out .= $school,",",$total_hash{$school},",",$total_starts_hash{$school},",",$team_withdrawls{$school},",",sprintf("%0.2f",$total_hash{$school}/$total_starts_hash{$school}),"\n";
    print "    ",$school,",",$total_hash{$school},",",$total_starts_hash{$school},",",sprintf("%0.2f",$total_hash{$school}/$total_starts_hash{$school}),"\n";
   # print FILE_DAT $school," ",$total_hash{$school}," ",$total_starts_hash{$school}," ",$team_withdrawls{$school}," ",sprintf("%0.2f",$total_hash{$school}/$total_starts_hash{$school}),"\n";
}

#foreach $school_name (sort keys %total_hash){
#    print $school_name,",",$total_hash{$school_name},"\n";
#}

# $string_out .= "---------------------------------------- Team Starts by Event\n";
# $string_out .= "School,Dance,Short,Free,Championship,Team\n";
# foreach $school (sort {$total_hash{$b} <=> $total_hash{$a}} keys %total_hash){
#     if ($dance_starts{$school}){$a=",$dance_starts{$school}";}else{$a=",0";}
#     if ($short_starts{$school}){$b=",$short_starts{$school}";}else{$b=",0";}
#     if ($free_starts{$school}){$c=",$free_starts{$school}";}else{$c=",0";}
#     if ($championship_starts{$school}){$d=",$championship_starts{$school}";}else{$d=",0";}
#     if ($team_starts{$school}){$e=",$team_starts{$school}";}else{$e=",0";}
#     $string_out .= $school,$a,$b,$c,$d,$e,"\n";
# }

# $string_out .= "---------------------------------------- Team Points by Event\n";
# $string_out .= "School,Dance,Short,Free,Championship,Team\n";
# foreach $school (sort {$total_hash{$b} <=> $total_hash{$a}} keys %total_hash){
#     if ($dance_points{$school}){$a=",$dance_points{$school}";}else{$a=",0";}
#     if ($short_points{$school}){$b=",$short_points{$school}";}else{$b=",0";}
#     if ($free_points{$school}){$c=",$free_points{$school}";}else{$c=",0";}
#     if ($championship_points{$school}){$d=",$championship_points{$school}";}else{$d=",0";}
#     if ($team_points{$school}){$e=",$team_points{$school}";}else{$e=",0";}
#     $string_out .= $school,$a,$b,$c,$d,$e,"\n";
# }

# $string_out .= "---------------------------------------- Team Points/Start by Event\n";
# $string_out .= "School,Dance,Short,Free,Championship,Team\n";
# foreach $school (sort {$total_hash{$b} <=> $total_hash{$a}} keys %total_hash){
#     if ($dance_points{$school} && $dance_starts{$school}){
#         $a=sprintf(",%0.2f",$dance_points{$school}/$dance_starts{$school});}else{$a=",0";}
#     if ($short_points{$school} && $short_starts{$school}){
#         $b=sprintf(",%0.2f",$short_points{$school}/$short_starts{$school});}else{$b=",0";}
#     if ($free_points{$school} && $free_starts{$school}){
#         $c=sprintf(",%0.2f",$free_points{$school}/$free_starts{$school});}else{$c=",0";}
#     if ($championship_points{$school} && $championship_starts{$school}){
#         $d=sprintf(",%0.2f",$championship_points{$school}/$championship_starts{$school});}else{$d=",0";}
#     if ($team_points{$school} && $team_starts{$school}){
#         $e=sprintf(",%0.2f",$team_points{$school}/$team_starts{$school});}else{$e=",0";}
#     $string_out .= $school,$a,$b,$c,$d,$e,"\n";
# }

# $string_out .= "---------------------------------------- Team Starts by Level\n";
# $string_out .= "School,Lv1,Lv2,Lv3,Lv4,Lv5,Lv6,Lv7,Lv8\n";
# foreach $school (sort {$total_hash{$b} <=> $total_hash{$a}} keys %total_hash){
#     $string_out .= $school;
#     for ($level = 1; $level < 9; $level ++){
#         if (@{$level_starts{$school}}[$level]){
#             $string_out .= ",",@{$level_starts{$school}}[$level];
#         }
#         else{
#             $string_out .= ",0";
#         }
#     }
#     $string_out .= "\n";
# }

# $string_out .= "---------------------------------------- Team Points by Level\n";
# $string_out .= "School,Lv1,Lv2,Lv3,Lv4,Lv5,Lv6,Lv7,Lv8\n";
# foreach $school (sort {$total_hash{$b} <=> $total_hash{$a}} keys %total_hash){
#     $string_out .= $school;
#     for ($level = 1; $level < 9; $level ++){
#         if (@{$level_points{$school}}[$level]){
#             $string_out .= ",",@{$level_points{$school}}[$level];
#         }
#         else{
#             $string_out .= ",0";
#         }
#     }
#     $string_out .= "\n";
# }

# $string_out .= "---------------------------------------- Team Points/Start by Level\n";
# $string_out .= "School,Lv1,Lv2,Lv3,Lv4,Lv5,Lv6,Lv7,Lv8\n";
# foreach $school (sort {$total_hash{$b} <=> $total_hash{$a}} keys %total_hash){
#     $string_out .= $school;
#     for ($level = 1;$level < 9;$level++){
#         if (@{$level_starts{$school}}[$level]){
#             $string_out .= sprintf(",%0.2f",@{$level_points{$school}}[$level]/@{$level_starts{$school}}[$level]);
#         }
#         else {
#             $string_out .= ",0.00";
#         }
#     }
#     $string_out .= "\n";
# }

# $string_out .= "---------------------------------------- Event Points\n";
# foreach $school_name (sort {$total_hash{$b} <=> $total_hash{$a}} keys %total_hash){
#     $string_out .= ",",$school_name;
# }

# foreach $event_name (sort keys %event_hash){
#     $string_out .= "\n",$event_name;
#     foreach $school_name (sort {$total_hash{$b} <=> $total_hash{$a}} keys %total_hash){
#         $points = 0;
#         foreach $skater_info (@{$event_hash{$event_name}}){
#             if ($skater_info =~ m/$school_name/){
#                 $points = $event_hash_total{$event_name}{$school_name};
#             }
#         }
#         $string_out .= ",",$points;
#     }
# }

# print FILE_DAT "School,";
# foreach $event_name (sort keys %event_hash){
#     # Abbreviate the event names
#     foreach $event (sort keys %level_abbrv){
#         $event_name =~ s/$event/$level_abbrv{$event}/;
#     }
#     print FILE_DAT $event_name.",";
# }
# print FILE_DAT "Total,Starts\n";
# foreach $school_name (sort {$total_hash{$b} <=> $total_hash{$a}} keys %total_hash){
#     $school_instance_abbrv = $school_name;
#     foreach $school (sort keys %school_abbrv) {
#         $school_instance_abbrv =~ s/$school/$school_abbrv{$school}/;
#     }
#     # print FILE_DAT $school_name.",";
#     print FILE_DAT $school_instance_abbrv.",";
#     foreach $event_name (sort keys %event_hash){
#         $points = 0;
#         foreach $skater_info (@{$event_hash{$event_name}}){
#             if ($skater_info =~ m/$school_name/){
#                 $points = $event_hash_total{$event_name}{$school_name};
#             }
#         }
#         print FILE_DAT $points.",";
#     }
#     print FILE_DAT $total_hash{$school_name}.",".$total_starts_hash{$school_name}."\n";
# }

# $string_out .= "\n---------------------------------------- Event Starts\n";
# foreach $school_name (sort {$total_hash{$b} <=> $total_hash{$a}} keys %total_hash){
#     $string_out .= ",",$school_name;
# }

# foreach $event_name (sort keys %event_hash){
#     $string_out .= "\n",$event_name;
#     foreach $school_name (sort {$total_hash{$b} <=> $total_hash{$a}} keys %total_hash){
# #                print $school_name,": ",$starts_hash{$event_name}{$school_name},"\n";
#         if ($starts_hash{$event_name}{$school_name}!=0){
#             $string_out .= ",",$starts_hash{$event_name}{$school_name};
#         }
#         else{
#             $string_out .= ",0";
#         }
#     }
# }

close FILE_RESULTS;

open FILE_OUT, ">", $file_out or
    die "[ERROR] Unable to open >$file_out";
print FILE_OUT $string_out;
close FILE_OUT;

# close FILE_DAT;

print "Done processing $file_out\n";
