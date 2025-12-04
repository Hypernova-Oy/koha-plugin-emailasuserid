package Koha::Plugin::Fi::Hypernova::EmailAsUserid::PendingSelfRegistrationsReport;

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

use C4::Reports::Guided;
use Koha::Reports;

our %pendingSelfRegistrationsReportName = (
  "en" => "Pending self-registrations",
  "fi-FI" => "Käsittelyä odottavat itserekisteröinnit",
  "sv-SE" => "Väntande självregistreringar",
);

sub setState {
  my ($plugin, $config) = @_;

  if ($config->{pending_self_registrations}) {
    my $existingReport = getPendingSelfRegistrationsReport($config);
    unless ($existingReport) {
      $config->{pending_self_registrations_report_id} = createPendingSelfRegistrationsReport($plugin);
    }
  } else {
    C4::Reports::Guided::delete_report($config->{pending_self_registrations_report_id}) if $config->{pending_self_registrations_report_id};
    delete $config->{pending_self_registrations_report_id};
  }
}

sub createPendingSelfRegistrationsReport {
  my ($plugin) = @_;

  if (my $patronSelfRegistrationDefaultCategory = C4::Context->preference('PatronSelfRegistrationDefaultCategory')) {
    my $id = C4::Reports::Guided::save_report({
      borrowernumber => C4::Context->userenv ? C4::Context->userenv->{'borrowernumber'} : undef,
      sql => "SELECT borrowernumber, firstname, surname, dateenrolled, updated_on FROM borrowers WHERE categorycode='$patronSelfRegistrationDefaultCategory'",
      name => $pendingSelfRegistrationsReportName{$plugin->_lang()},
      area => undef,
      group => 'plugins',
      subgroup => 'Koha::Plugin::Fi::Hypernova::EmailAsUserid',
      cache_expiry => undef,
      public => undef,
    });
    die "Failed to create pending self-registrations report: $@" unless $id;
    return $id;
  }
}

sub getPendingSelfRegistrationsReport {
  my ($config) = @_;
  return $config->{pending_self_registrations_report_id} ? Koha::Reports->find($config->{pending_self_registrations_report_id}) : undef;
}

1;
