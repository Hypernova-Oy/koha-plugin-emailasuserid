package Koha::Plugin::Fi::Hypernova::EmailAsUserid::Configuration;

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

use YAML::XS;
$YAML::XS::LoadBlessed = 1;
use JSON::XS;

sub new {
  my ($class, $args) = @_;
  die "No args given!" unless ($args && ref($args) eq 'HASH');
  my $self = bless($args, $class);

  return $self;
}

sub newFromCGI {
  my ($class, $cgi) = @_;
  my $args = {};
  $args->{card}  = $cgi->param('card') ? 1 : 0;
  $args->{email} = $cgi->param('email') ? 1 : 0;
  $args->{force_email} = $cgi->param('force_email') ? 1 : 0;
  $args->{hide_branchcode_selection} = $cgi->param('hide_branchcode_selection') ? 1 : 0;
  $args->{pending_self_registrations} = $cgi->param('pending_self_registrations') ? 1 : 0;
  $args->{pending_self_registrations_report_id} = $cgi->param('pending_self_registrations_report_id');
  $args->{studentcard}  = $cgi->param('studentcard') ? 1 : 0;

  if ($args->{pending_self_registrations}) {
    unless(C4::Context->preference('PatronSelfRegistrationDefaultCategory')) {
      die "Koha::Plugin::Fi::Hypernova::EmailAsUserid:> You must set the preference 'PatronSelfRegistrationDefaultCategory' to use pending_self_registrations.";
    }
  }

  return $class->new($args);
}

sub newFromDatabase {
  my ($class, $plugin) = @_;
  my $serialized = $plugin->retrieve_data('config');
  return $class->deserialize($serialized) if $serialized;
  return $class->new({});
}

sub asJavascript {
  my ($self) = @_;
  return
    "const kpfheauid_config = {\n".
    "  card: ".($self->{card} ? 'true' : 'false').",\n".
    "  email: ".($self->{email} ? 'true' : 'false').",\n".
    "  force_email: ".($self->{force_email} ? 'true' : 'false').",\n".
    "  hide_branchcode_selection: ".($self->{hide_branchcode_selection} ? 'true' : 'false').",\n".
    "  pending_self_registrations_categorycode: '".(C4::Context->preference('PatronSelfRegistrationDefaultCategory') // 'null')."',\n".
    "  pending_self_registrations_report_id: ".($self->{pending_self_registrations_report_id} // 'null').",\n".
    "  studentcard: ".($self->{studentcard} ? 'true' : 'false').",\n".
    "};\n";
}

sub serialize {
  my ($self) = @_;
  return YAML::XS::Dump($self);
}
sub deserialize {
  my ($class, $yamlString) = @_;
  return YAML::XS::Load($yamlString);
}
sub store {
  my ($self, $plugin) = @_;
  $plugin->store_data({config => $self->serialize});
  return $self;
}

1;
