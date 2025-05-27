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

#Controller
sub configure {
  my ($plugin, $args) = @_;
  my $cgi = $plugin->{'cgi'};

  my $template = $plugin->get_template( { file => $plugin->_absPath('configure.tt') } );

  if (my $login_method = $cgi->param('login_method')) {
    if ($login_method =~ /^(?:email|uid|card)$/) {
      $plugin->set_config('login_method', $login_method);
    } else {
      $plugin->set_config('login_method', 'email');
    }
  }

  $plugin->store_data({
    login_method => $login_method,
  });

  $template->param(
    available_subroutines => Koha::Plugin::Fi::Hypernova::ValueBuilder::Builder::Subroutine::ListAvailable(),
    available_triggers => Koha::Plugin::Fi::Hypernova::ValueBuilder::Builder::Trigger::ListAvailable(),
    item_marc_subfield_structures => GetMARCFrameworkSubfields('', '952'),
    valuebuilders => Koha::Plugin::Fi::Hypernova::ValueBuilder::ValueBuilders->new($plugin)->retrieveAll,
  );

  $plugin->output_html( $template->output(), 200 );
  return 1;
}

1;
