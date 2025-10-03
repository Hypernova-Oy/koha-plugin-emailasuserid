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

#Controller
sub configure {
  my ($plugin, $args) = @_;
  my $cgi = $plugin->{'cgi'};

  eval {
    my $template = $plugin->get_template( { file => $plugin->_absPath('configure.tt') } );

    my $config = Koha::Plugin::Fi::Hypernova::EmailAsUserid::Configuration->newFromDatabase($plugin);
    if ($cgi->param('save')) {
      my $newConfig = Koha::Plugin::Fi::Hypernova::EmailAsUserid::Configuration->newFromCGI($cgi);

      if ($newConfig->{pending_self_registrations}) {
        $newConfig->{pending_self_registrations_report_id} = createPendingSelfRegistrationsReport($plugin);
      } else {
        C4::Reports::Guided::delete_report($newConfig->{pending_self_registrations_report_id}) if $newConfig->{pending_self_registrations_report_id};
        delete $newConfig->{pending_self_registrations_report_id};
      }

      $config = $newConfig->store($plugin);
      C4::Log::logaction('EmailAsUserid', 'configure', undef, $config->serialize(), undef, undef);
      $plugin->loadAssets(); #Reload assets to get the new config
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

sub createPendingSelfRegistrationsReport {
  my ($plugin) = @_;

  if (my $patronSelfRegistrationDefaultCategory = C4::Context->preference('PatronSelfRegistrationDefaultCategory')) {
    my $id = C4::Reports::Guided::save_report({
      borrowernumber => C4::Context->userenv ? C4::Context->userenv->{'borrowernumber'} : undef,
      sql => "SELECT borrowernumber, firstname, surname, dateenrolled, updated_on FROM borrowers WHERE categorycode='$patronSelfRegistrationDefaultCategory'",
      name => 'Pending Self-registrations',
      area => undef,
      group => 'plugins',
      subgroup => undef,
      cache_expiry => undef,
      public => undef,
    });
    die "Failed to create pending self-registrations report: $@" unless $id;
    return $id;
  }
}

1;
