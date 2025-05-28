package Koha::Plugin::Fi::Hypernova::EmailAsUserid::Configure;

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

use C4::Log;
use Koha::Plugin::Fi::Hypernova::EmailAsUserid::Configuration;

#Controller
sub configure {
  my ($plugin, $args) = @_;
  my $cgi = $plugin->{'cgi'};

  eval {
    my $template = $plugin->get_template( { file => $plugin->_absPath('configure.tt') } );

    my $config = Koha::Plugin::Fi::Hypernova::EmailAsUserid::Configuration->newFromDatabase($plugin);
    if ($cgi->param('save')) {
      $config = Koha::Plugin::Fi::Hypernova::EmailAsUserid::Configuration->newFromCGI($cgi);
      $config->store($plugin);
      C4::Log::logaction('EmailAsUserid', 'configure', undef, $config->serialize(), undef, undef);
    }

    $template->param(
      config => $config,
    );

    $plugin->output_html( $template->output(), 200 );
  };
  if ($@) {
    warn 'Koha::Plugin::Fi::Hypernova::EmailAsUserid:> '.$@;
    $plugin->output_html( $@, 500 );
  }
  return 1;
}

1;
