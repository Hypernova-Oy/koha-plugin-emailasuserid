package Koha::Plugin::Fi::Hypernova::EmailAsUserid::Installer;

# Copyright 2025 Hypernova Oy
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# This program comes with ABSOLUTELY NO WARRANTY;

use Modern::Perl;
use strict;
use warnings;

use Koha::Plugin::Fi::Hypernova::EmailAsUserid::Configuration;

sub install {
  my ($plugin) = @_;

  my @upgrades;

  my $c = Koha::Plugin::Fi::Hypernova::EmailAsUserid::Configuration->newFromDatabase($plugin);
  unless ($c && keys %$c) {
    $c = Koha::Plugin::Fi::Hypernova::EmailAsUserid::Configuration->new({card => 1, email => 1});
    $c->store($plugin);
    push(@upgrades, $Koha::Plugin::Fi::Hypernova::EmailAsUserid::VERSION);
  }
  return \@upgrades;
}

sub uninstall {
  my ($plugin) = @_;

  my $c = Koha::Plugin::Fi::Hypernova::EmailAsUserid::Configuration->new({});
  $c->store($plugin);
}

1;
