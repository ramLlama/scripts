#! /usr/bin/env perl

use warnings;
use strict;

use File::Slurp;
use Readonly;

Readonly my $uevent_template => <<'END';
POWER_SUPPLY_NAME=BATCON
POWER_SUPPLY_STATUS=<POWER_SUPPLY_STATUS>
POWER_SUPPLY_PRESENT=1
POWER_SUPPLY_TECHNOLOGY=Virtual
POWER_SUPPLY_CYCLE_COUNT=0
POWER_SUPPLY_VOLTAGE_MIN_DESIGN=0
POWER_SUPPLY_VOLTAGE_NOW=<POWER_SUPPLY_VOLTAGE_NOW>
POWER_SUPPLY_POWER_NOW=<POWER_SUPPLY_POWER_NOW>
POWER_SUPPLY_ENERGY_FULL_DESIGN=<POWER_SUPPLY_ENERGY_FULL_DESIGN>
POWER_SUPPLY_ENERGY_FULL=<POWER_SUPPLY_ENERGY_FULL>
POWER_SUPPLY_ENERGY_NOW=<POWER_SUPPLY_ENERGY_NOW>
POWER_SUPPLY_CAPACITY=0
POWER_SUPPLY_CAPACITY_LEVEL=<POWER_SUPPLY_CAPACITY_LEVEL>
POWER_SUPPLY_MODEL_NAME=Consolidated
POWER_SUPPLY_MANUFACTURER=LlamaCorp
POWER_SUPPLY_SERIAL_NUMBER=1
END

Readonly my $uevent_path_template => "/sys/class/power_supply/<BAT>/uevent";

Readonly my @batteries => ("BAT0", "BAT1");

###############
# get uevents #
###############
my @uevents = ();
for my $battery (@batteries) {
  my $uevent_path = $uevent_path_template;
  $uevent_path =~ s/<BAT>/$battery/g;

  my %uevent = read_file($uevent_path) =~ /^(\w+)=(.*)$/mg;
  push (@uevents, \%uevent)
}

################################
# Generate consolidated uevent #
################################
my %con_uevent =
  (
   "POWER_SUPPLY_STATUS" => "Full",
   "POWER_SUPPLY_VOLTAGE_NOW" => 0,
   "POWER_SUPPLY_POWER_NOW" => 0,
   "POWER_SUPPLY_ENERGY_FULL_DESIGN" => 0,
   "POWER_SUPPLY_ENERGY_FULL" => 0,
   "POWER_SUPPLY_ENERGY_NOW" => 0,
   "POWER_SUPPLY_CAPACITY_LEVEL" => "Full"
  );

for my $uevent (@uevents) {
  my $key = "POWER_SUPPLY_STATUS";
  if (($uevent->{$key} ne "Unknown") && ($uevent->{$key} ne "Full")) {
    $con_uevent{$key} = $uevent->{$key};
  }

  $key = "POWER_SUPPLY_VOLTAGE_NOW";
  $con_uevent{$key} = $con_uevent{$key} + $uevent->{$key};

  $key = "POWER_SUPPLY_POWER_NOW";
  $con_uevent{$key} = $con_uevent{$key} + $uevent->{$key};

  $key = "POWER_SUPPLY_ENERGY_FULL_DESIGN";
  $con_uevent{$key} = $con_uevent{$key} + $uevent->{$key};

  $key = "POWER_SUPPLY_ENERGY_FULL";
  $con_uevent{$key} = $con_uevent{$key} + $uevent->{$key};

  $key = "POWER_SUPPLY_ENERGY_NOW";
  $con_uevent{$key} = $con_uevent{$key} + $uevent->{$key};

  $key = "POWER_SUPPLY_CAPACITY_LEVEL";
  if ($uevent->{$key} ne "Full") {
    $con_uevent{$key} = $uevent->{$key};
  }
}

# need average for voltage
$con_uevent{"POWER_SUPPLY_VOLTAGE_NOW"} =
  $con_uevent{"POWER_SUPPLY_VOLTAGE_NOW"} / scalar(@uevents);

####################
# Print out uevent #
####################
my $uevent = $uevent_template;
$uevent =~ s/<(.*?)>/$con_uevent{$1}/ge;

print "$uevent";
