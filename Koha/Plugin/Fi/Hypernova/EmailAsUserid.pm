package Koha::Plugin::Fi::Hypernova::EmailAsUserid;

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

use base qw(Koha::Plugins::Base);

use Cwd;
use File::Slurp;
use Mojo::JSON qw(decode_json);
use YAML;
use Try::Tiny;

use Koha::Plugin::Fi::Hypernova::EmailAsUserid::Configure;
use Koha::Plugin::Fi::Hypernova::EmailAsUserid::Configuration;

our $VERSION = '0.0.1'; #PLACEHOLDER
our $DATE_UPDATED = '2025-05-28'; #PLACEHOLDER

our $metadata = {
  name            => 'EmailAsUserid',
  author          => 'Olli-Antti Kivilahti',
  date_authored   => '2025-05-28',
  date_updated    => $DATE_UPDATED,
  minimum_version => '24.11.01.000',
  maximum_version => undef,
  version         => $VERSION,
  description     => 'Email is used as the borrowers.userid.',
};

our %assets;

sub new {
  my ( $class, $args ) = @_;

  ## We need to add our metadata here so our base class can access it
  $args->{'metadata'} = $metadata;
  $args->{'metadata'}->{'class'} = $class;

  ## Here, we call the 'new' method for our base class
  ## This runs some additional magic and checking
  ## and returns our actual $self
  my $self = $class->SUPER::new($args);
  $self->{cgi} = CGI->new() unless $self->{cgi};

  $self->loadAssets();

  return $self;
}

sub loadAssets {
  my ($self) = @_;
  $assets{'opac'} =
    "<script>\n".
    Koha::Plugin::Fi::Hypernova::EmailAsUserid::Configuration->newFromDatabase($self)->asJavascript()."\n".
    File::Slurp::read_file($self->_absPath('js/lib.js'), { binmode => ':encoding(UTF-8)' })."\n".
    File::Slurp::read_file($self->_absPath('js/opac.js'), { binmode => ':encoding(UTF-8)' })."\n".
    "</script>\n";

  $assets{'/intranet/members/memberentry.pl'} =
    "<script>\n".
    Koha::Plugin::Fi::Hypernova::EmailAsUserid::Configuration->newFromDatabase($self)->asJavascript()."\n".
    File::Slurp::read_file($self->_absPath('js/lib.js'))."\n".
    File::Slurp::read_file($self->_absPath('js/memberentry.js'))."\n".
    "</script>\n";

  $assets{'/intranet/mainpage.pl'} =
    "<script>\n".
    Koha::Plugin::Fi::Hypernova::EmailAsUserid::Configuration->newFromDatabase($self)->asJavascript()."\n".
    File::Slurp::read_file($self->_absPath('js/lib.js'))."\n".
    File::Slurp::read_file($self->_absPath('js/mainpage.js'))."\n".
    "</script>\n";
}

sub install { return 1; }
sub uninstall { return 1; }
sub configure { return Koha::Plugin::Fi::Hypernova::EmailAsUserid::Configure::configure(@_); }

=head2 patron_generate_userid

@IMPLEMENTS Koha::Plugins hook 'patron_generate_userid'
Generates a user ID for a patron based on their email address.

=cut

sub patron_generate_userid {
  my ( $self, $patron ) = @_; # $patron is a Koha::Patron object
  return $patron->email;
}

=head2 intranet_js

@IMPLEMENTS Koha::Plugins hook 'intranet_js'
Generates JavaScript to bind the email field as the user ID field in the patron forms.

=cut

sub intranet_js {
  my ($self) = @_;
  require Encode;
  return Encode::decode('UTF-8', $assets{$self->{'cgi'}->script_name});
}

=head2 opac_js

@IMPLEMENTS Koha::Plugins hook 'opac_js'
Generates JavaScript to bind the email field as the user ID field in the patron forms.

=cut

sub opac_js {
  my ($self) = @_;
  return $assets{'opac'};
}

sub _absPath {
  my ($self, $file) = @_;

  return Cwd::abs_path($self->mbf_path($file));
}

1;
