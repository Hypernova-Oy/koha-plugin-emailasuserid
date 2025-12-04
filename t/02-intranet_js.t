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

use t::Lib qw(Koha::Plugin::Fi::Hypernova::EmailAsUserid);
use t::Lib::Mocks;

use HTTP::Request::Common qw();
use HTTP::Headers;

subtest("Scenario: Simple plugin lifecycle tests.", sub {
  plan tests => 6;

  ok(t::Lib::Mocks::mock_preference('PatronSelfRegistrationDefaultCategory', 'SELF'), "Mock preference 'PatronSelfRegistrationDefaultCategory' to 'SELF'");
  my $plugin = Koha::Plugin::Fi::Hypernova::EmailAsUserid->new(); #This implicitly calls install()

  subtest("opac_js for opac-memberentry.pl BorrowerSelfRegistration", sub {
    plan tests => 5;

    $plugin->{cgi} = FakeCGI->new(HTTP::Request::Common::GET('/cgi-bin/koha/opac-memberentry.pl'));

    my $js = $plugin->opac_js();
    ok($js, "Loading the javascript");
    like($js, qr!const kpfheauid_config!, "Javascript contains the plugin config");
    like($js, qr!Koha::Plugin::Fi::Hypernova::EmailAsUserid/js/lib.js!, "Javascript contains the plugin js/lib.js");
    like($js, qr!Koha::Plugin::Fi::Hypernova::EmailAsUserid/js/opac.js!, "Javascript contains the plugin js/opac.js");
    like($js, qr!body#opac-patron-registration!, "Javascript contains the correct selector");
  });

  subtest("opac_js for opac-memberentry.pl BorrowerSelfModification", sub {
    plan tests => 5;

    $plugin->{cgi} = FakeCGI->new(HTTP::Request::Common::GET('/cgi-bin/koha/opac-memberentry.pl'));

    my $js = $plugin->opac_js();
    ok($js, "Loading the javascript");
    like($js, qr!const kpfheauid_config!, "Javascript contains the plugin config");
    like($js, qr!Koha::Plugin::Fi::Hypernova::EmailAsUserid/js/lib.js!, "Javascript contains the plugin js/lib.js");
    like($js, qr!Koha::Plugin::Fi::Hypernova::EmailAsUserid/js/opac.js!, "Javascript contains the plugin js/opac.js");
    like($js, qr/body#opac-patron-update/, "Javascript contains the correct selector");
  });

  subtest("opac_js for sco/sco-main.pl", sub {
    plan tests => 10;

    $plugin->{cgi} = FakeCGI->new(HTTP::Request::Common::GET('/opac/sco/sco-main.pl'));
    ok(t::Lib::Mocks::mock_preference('WebBasedSelfCheck', 1), "Mock preference 'WebBasedSelfCheck' enabled");
    ok($plugin = Koha::Plugin::Fi::Hypernova::EmailAsUserid->new(), "Plugin reloaded");

    my $js = $plugin->opac_js();
    ok($js, "Loading the javascript");
    like($js, qr!const kpfheauid_config!, "Javascript contains the plugin config");
    like($js, qr!Koha::Plugin::Fi::Hypernova::EmailAsUserid/js/lib.js!, "Javascript contains the plugin js/lib.js");
    like($js, qr!Koha::Plugin::Fi::Hypernova::EmailAsUserid/js/sco-main.js!, "Javascript contains the plugin js/sco-main.js");
    like($js, qr/body#sco_main.CheckingOut/, "Javascript contains the correct selector");

    ok(t::Lib::Mocks::mock_preference('WebBasedSelfCheck', 0), "Mock preference 'WebBasedSelfCheck' disabled");
    ok($plugin = Koha::Plugin::Fi::Hypernova::EmailAsUserid->new(), "Plugin reloaded");
    $js = $plugin->opac_js();
    is($js, '', "Loading the javascript returns empty string");
  });

  subtest("intranet_js for memberentry.pl", sub {
    plan tests => 5;

    $plugin->{cgi} = FakeCGI->new(HTTP::Request::Common::GET('/intranet/members/memberentry.pl'));

    my $js = $plugin->intranet_js();
    ok($js, "Loading the javascript");
    like($js, qr!const kpfheauid_config!, "Javascript contains the plugin config");
    like($js, qr!Koha::Plugin::Fi::Hypernova::EmailAsUserid/js/lib.js!, "Javascript contains the plugin js/lib.js");
    like($js, qr!Koha::Plugin::Fi::Hypernova::EmailAsUserid/js/memberentry.js!, "Javascript contains the plugin js/memberentry.js");
    like($js, qr/body#pat_memberentrygen/, "Javascript contains the correct selector");
  });

  subtest("intranet_js for mainpage.pl 'pending_self_registrations'", sub {
    plan tests => 6;

    $plugin->{cgi} = FakeCGI->new(HTTP::Request::Common::GET('/intranet/mainpage.pl'));

    ok(my $js = $plugin->intranet_js(), "Loading the javascript");
    like($js, qr!const kpfheauid_config!, "Javascript contains the plugin config");
    like($js, qr!Koha::Plugin::Fi::Hypernova::EmailAsUserid/js/lib.js!, "Javascript contains the plugin js/lib.js");
    like($js, qr!Koha::Plugin::Fi::Hypernova::EmailAsUserid/js/mainpage.js!, "Javascript contains the plugin js/mainpage.js");
    like($js, qr/body#main_intranet-main/, "Javascript contains the correct selector");
    like($js, qr/pending_self_registrations_categorycode: ['"]SELF['"]/, "Javascript contains the pending_self_registrations_categorycode");
  });
});

1;