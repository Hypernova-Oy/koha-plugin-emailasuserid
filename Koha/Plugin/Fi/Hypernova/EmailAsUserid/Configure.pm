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
use C4::Reports::Guided;
use Koha::Plugin::Fi::Hypernova::EmailAsUserid::Configuration;
use Koha::Plugin::Fi::Hypernova::EmailAsUserid::PendingSelfRegistrationsReport;

#Controller
sub configure {
  my ($plugin, $args) = @_;
  my $cgi = $plugin->{'cgi'};

  eval {
    my $template = $plugin->get_template( { file => $plugin->_absPath('configure.tt') } );

    my $config = Koha::Plugin::Fi::Hypernova::EmailAsUserid::Configuration->newFromDatabase($plugin);
    if ($cgi->param('save')) {
      my $newConfig = Koha::Plugin::Fi::Hypernova::EmailAsUserid::Configuration->newFromCGI($cgi);

      Koha::Plugin::Fi::Hypernova::EmailAsUserid::PendingSelfRegistrationsReport::setState($plugin, $newConfig);

      $config = $newConfig->store($plugin);
      C4::Log::logaction('EmailAsUserid', 'configure', undef, $config->serialize(), undef, undef);
    }

    $template->param(
      config => $config,
    );

    $plugin->output_html( $template->output(), 200 );
  };
  if ($@) {
    my $error = $@;
    warn 'Koha::Plugin::Fi::Hypernova::EmailAsUserid:> '.$error;
    eval {
      my $config = Koha::Plugin::Fi::Hypernova::EmailAsUserid::Configuration->newFromDatabase($plugin);
      my $template = $plugin->get_template( { file => $plugin->_absPath('configure.tt') } );
      $template->param(
        config => $config,
        error => $error,
      );
      $plugin->output_html( $template->output(), 200 );
    };
    if ($@) {
      warn 'Koha::Plugin::Fi::Hypernova::EmailAsUserid:> '.$@;
      $plugin->output_html( $@, 500 );
    }
  }
  return 1;
}

1;
