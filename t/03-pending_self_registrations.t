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

use Koha::Plugins;

use Koha::Plugin::Fi::Hypernova::EmailAsUserid;
use Koha::Plugin::Fi::Hypernova::EmailAsUserid::Configuration;
use Koha::Plugin::Fi::Hypernova::EmailAsUserid::PendingSelfRegistrationsReport;

use t::Lib qw(Koha::Plugin::Fi::Hypernova::EmailAsUserid);
use t::Lib::Util;

use HTTP::Request::Common qw();
use HTTP::Headers;

t::Lib::Util::MockPluginsdir();

subtest("Scenario: Pending self-registrations are enabled and disabled and enabled.", sub {
  plan tests => 4;

  my $plugin = Koha::Plugin::Fi::Hypernova::EmailAsUserid->new(); #This implicitly calls install()
  my $pending_self_registrations_report_id;

  subtest("Enable pending_self_registrations", sub {
    plan tests => 8;

    $plugin->{cgi} = FakeCGI->new(
      HTTP::Request::Common::POST(
        $t::Lib::DEFAULT_URL,
        Content => [
          class => "Koha::Plugin::Fi::Hypernova::EmailAsUserid",
          method => "configure",
          save => "1",
          pending_self_registrations => "1",
          op => '', #C4::Auth.om:189 throws undefined error if op is missing on POST requests
        ],
      ),
    );
    ok($plugin->configure(), "Setting pending_self_registrations");
    is(t::Lib::htmlStatus(), 200, "Status '200'");

    my $c = Koha::Plugin::Fi::Hypernova::EmailAsUserid::Configuration->newFromDatabase($plugin);
    is($c->{pending_self_registrations}, 1, "Configuration 'pending_self_registrations' is enabled");
    $pending_self_registrations_report_id = $c->{pending_self_registrations_report_id};
    ok($pending_self_registrations_report_id, 'pending_self_registrations_report_id set');
    is(ref(Koha::Plugin::Fi::Hypernova::EmailAsUserid::PendingSelfRegistrationsReport::getPendingSelfRegistrationsReport($c)), 'Koha::Report', 'Pending self-registrations -report exists');

    $plugin->{cgi} = FakeCGI->new(
      HTTP::Request::Common::POST(
        $t::Lib::DEFAULT_URL,
        Content => [
          class => "Koha::Plugin::Fi::Hypernova::EmailAsUserid",
          method => "configure",
          op => '', #C4::Auth.om:189 throws undefined error if op is missing on POST requests
        ],
      ),
    );
    ok($plugin->configure(), "Loading the config screen");
    is(t::Lib::htmlStatus(), 200, "Status '200'");
    ok(t::Lib::htmlContains('id="pending_self_registrations_report_id" value="'.$pending_self_registrations_report_id.'"'), "pending_self_registrations_report_id in the config view");
  });

  subtest("Submit new configuration with pending_self_registrations still enabled", sub {
    plan tests => 5;

    $plugin->{cgi} = FakeCGI->new(
      HTTP::Request::Common::POST(
        $t::Lib::DEFAULT_URL,
        Content => [
          class => "Koha::Plugin::Fi::Hypernova::EmailAsUserid",
          method => "configure",
          save => "1",
          pending_self_registrations => "1",
          pending_self_registrations_report_id => $pending_self_registrations_report_id,
          op => '', #C4::Auth.om:189 throws undefined error if op is missing on POST requests
        ],
      ),
    );
    ok($plugin->configure(), "Setting pending_self_registrations");
    is(t::Lib::htmlStatus(), 200, "Status '200'");

    my $c = Koha::Plugin::Fi::Hypernova::EmailAsUserid::Configuration->newFromDatabase($plugin);
    is($pending_self_registrations_report_id, $c->{pending_self_registrations_report_id}, "pending_self_registrations_report_id is unchanged");
    is($c->{pending_self_registrations}, 1, "Configuration 'pending_self_registrations' is enabled");
    is(ref(Koha::Plugin::Fi::Hypernova::EmailAsUserid::PendingSelfRegistrationsReport::getPendingSelfRegistrationsReport($c)), 'Koha::Report', 'Pending self-registrations -report exists');
  });

  subtest("Disable pending_self_registrations", sub {
    plan tests => 5;

    $plugin->{cgi} = FakeCGI->new(
      HTTP::Request::Common::POST(
        $t::Lib::DEFAULT_URL,
        Content => [
          class => "Koha::Plugin::Fi::Hypernova::EmailAsUserid",
          method => "configure",
          save => "1",
          pending_self_registrations => "0",
          pending_self_registrations_report_id => $pending_self_registrations_report_id,
          op => '', #C4::Auth.om:189 throws undefined error if op is missing on POST requests
        ],
      ),
    );
    ok($plugin->configure(), "Disabling pending_self_registrations");
    is(t::Lib::htmlStatus(), 200, "Status '200'");

    my $c = Koha::Plugin::Fi::Hypernova::EmailAsUserid::Configuration->newFromDatabase($plugin);
    isnt($pending_self_registrations_report_id, $c->{pending_self_registrations_report_id}, "pending_self_registrations_report_id has been removed");
    is($c->{pending_self_registrations}, 0, "Configuration 'pending_self_registrations' is disabled");
    is(Koha::Plugin::Fi::Hypernova::EmailAsUserid::PendingSelfRegistrationsReport::getPendingSelfRegistrationsReport($c), undef, 'Pending self-registrations -report missing');
  });

  subtest("Keep pending_self_registrations disabled", sub {
    plan tests => 5;

    $plugin->{cgi} = FakeCGI->new(
      HTTP::Request::Common::POST(
        $t::Lib::DEFAULT_URL,
        Content => [
          class => "Koha::Plugin::Fi::Hypernova::EmailAsUserid",
          method => "configure",
          save => "1",
          pending_self_registrations => "0",
          op => '', #C4::Auth.om:189 throws undefined error if op is missing on POST requests
        ],
      ),
    );
    ok($plugin->configure(), "Disabling pending_self_registrations");
    is(t::Lib::htmlStatus(), 200, "Status '200'");

    my $c = Koha::Plugin::Fi::Hypernova::EmailAsUserid::Configuration->newFromDatabase($plugin);
    ok(! $c->{pending_self_registrations_report_id}, "pending_self_registrations_report_id has been removed");
    is($c->{pending_self_registrations}, 0, "Configuration 'pending_self_registrations' is disabled");
    is(Koha::Plugin::Fi::Hypernova::EmailAsUserid::PendingSelfRegistrationsReport::getPendingSelfRegistrationsReport($c), undef, 'Pending self-registrations -report missing');
  });
});

1;
