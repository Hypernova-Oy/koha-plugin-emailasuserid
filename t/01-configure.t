#!/usr/bin/env perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

BEGIN {
  $ENV{LOG4PERL_VERBOSITY_CHANGE} = 6;
  $ENV{MOJO_OPENAPI_DEBUG} = 1;
  $ENV{MOJO_LOG_LEVEL} = 'debug';
  $ENV{VERBOSE} = 1;
  $ENV{KOHA_PLUGIN_DEV_MODE} = 1;
}

use Modern::Perl;
use strict;
use warnings;
use utf8;

use Test::More tests => 1;
use Test::Deep;
use Test::Mojo;

use Koha::Plugin::Fi::Hypernova::EmailAsUserid;
use Koha::Plugin::Fi::Hypernova::EmailAsUserid::Configuration;

use t::Lib qw(Koha::Plugin::Fi::Hypernova::EmailAsUserid);

use HTTP::Request::Common qw();
use HTTP::Headers;

subtest("Scenario: Simple plugin lifecycle tests.", sub {
  plan tests => 4;

  my $plugin = Koha::Plugin::Fi::Hypernova::EmailAsUserid->new(); #This implicitly calls install()

  subtest("Make sure the plugin is uninstalled", sub {
    plan tests => 1;

    $plugin->uninstall(); #So we have to install/upgrade + uninstall the plugin.
    ok(!$plugin->retrieve_data('__INSTALLED__'), "Uninstalled");
  });

  subtest("Install the plugin", sub {
    plan tests => 1;

    $plugin->install();
    ok($plugin->retrieve_data('__INSTALLED__'), "Installed");
  });

=head
  #subtest("Upgrade the plugin", sub {
  #    plan tests => 1;
  #
  #    $plugin->store_data({ '__INSTALLED_VERSION__' => '0.0.0' });
  #    $plugin = Koha::Plugin::Fi::KohaSuomi::SelfService->new(); #This implicitly calls upgrade()
  #    is($plugin->get_metadata->{version}, $plugin->retrieve_data('__INSTALLED_VERSION__'), "Upgraded");
  #});
=cut

  subtest("Load the plugin configurer", sub {
    plan tests => 3;

    $plugin->{cgi} = FakeCGI->new();
    ok($plugin->configure(), "Loading the configure-view");
    is(t::Lib::htmlStatus(), 200, "Status '200'");
    ok(t::Lib::htmlContains(qr!<input type="hidden" name="csrf_token" value=".+?" />!), "CSRF-token included");
  });

  subtest("Save the plugin configuration", sub {
    plan tests => 6;

    $plugin->{cgi} = FakeCGI->new(
      HTTP::Request::Common::POST(
        $t::Lib::DEFAULT_URL,
        Content => [
          class => "Koha::Plugin::Fi::Hypernova::EmailAsUserid",
          method => "configure",
          save => "1",
          force_email => "1",
          email => "1",
          card => "1",
        ],
      ),
    );
    ok($plugin->configure(), "Loading the configure-view");
    is(t::Lib::htmlStatus(), 200, "Status '200'");
    ok(t::Lib::htmlContains(qr!<input type="hidden" name="csrf_token" value=".+?" />!), "CSRF-token included");

    my $c = Koha::Plugin::Fi::Hypernova::EmailAsUserid::Configuration->newFromDatabase($plugin);
    is($c->{force_email}, 1, "Configuration 'force_email' is set to 1");
    is($c->{email}, 1, "Configuration 'email' is set to 1");
    is($c->{card}, 1, "Configuration 'card' is set to 1");
  });
});

1;