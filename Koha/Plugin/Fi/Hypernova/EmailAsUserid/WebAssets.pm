package Koha::Plugin::Fi::Hypernova::EmailAsUserid::WebAssets;

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

our %assets = (
  'opac' => sub {
    return _HTMLScriptElement($_[0],
      $_[0]->config->asJavascript()."\n".
      File::Slurp::read_file($_[0]->_absPath('js/lib.js'), { binmode => ':encoding(UTF-8)' })."\n".
      File::Slurp::read_file($_[0]->_absPath('js/opac.js'), { binmode => ':encoding(UTF-8)' })."\n"
    );
  },
  '/opac/sco/sco-main.pl' => sub {
    return _HTMLScriptElement($_[0],
      $_[0]->config->asJavascript()."\n".
      File::Slurp::read_file($_[0]->_absPath('js/lib.js'))."\n".
      File::Slurp::read_file($_[0]->_absPath('js/sco-main.js'))."\n"
    ) if ($_[0]->config->{sco_refresher});
    return '';
  },
  '/intranet/members/memberentry.pl' => sub {
    return _HTMLScriptElement($_[0],
      $_[0]->config->asJavascript()."\n".
      File::Slurp::read_file($_[0]->_absPath('js/lib.js'))."\n".
      File::Slurp::read_file($_[0]->_absPath('js/memberentry.js'))."\n"
    );
  },
  '/intranet/mainpage.pl' => sub {
    return _HTMLScriptElement($_[0],
      $_[0]->config->asJavascript()."\n".
      File::Slurp::read_file($_[0]->_absPath('js/lib.js'))."\n".
      File::Slurp::read_file($_[0]->_absPath('js/mainpage.js'))."\n"
    );
  },
);

sub intranet_js {
  my ($plugin) = @_;
  require Encode;
  return Encode::decode('UTF-8', $assets{$plugin->{'cgi'}->script_name} && $assets{$plugin->{'cgi'}->script_name}->($plugin));
}

sub opac_js {
  my ($plugin) = @_;
  if ($assets{$plugin->{'cgi'}->script_name}) {
    return $assets{$plugin->{'cgi'}->script_name}->($plugin);
  }
  return $assets{'opac'}->($plugin);
}

sub _HTMLScriptElement {
  my ($self, $content) = @_;

  return '<script nonce="'.($ENV{csp_nonce} || $ENV{'plack.middleware.Koha.CSP.csp_nonce'} || '').'">'."\n".$content.'</script>';
}

1;
