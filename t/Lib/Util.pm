package t::Lib::Util;

use Modern::Perl;

use Exporter;
our @ISA = qw(Exporter);
# Exporting the add and subtract routine
our @EXPORT = qw(build_patron);

use t::Lib::TestBuilder;

use C4::Context;

unless (C4::Context->interface) {
  C4::Context->interface('intranet');
  print "t::Lib::Util:> Setting interface to 'intranet'\n";
}

our $builder = t::lib::TestBuilder->new;

sub build_patron {
  my ($params) = @_;

  my $flag = $params->{flags} ? 2 ** $params->{flags} : undef;
  my $patron = $builder->build_object(
    {
      class => 'Koha::Patrons',
      value => {
        gonenoaddress   => 0,
        lost            => 0,
        debarred        => undef,
        debarredcomment => undef,
        dateofbirth     => '2000-01-01',
        branchcode => $params->{branchcode} || 'FPL',
        flags => $flag
      }
    }
  );
  my $password = RandomString(16);
  $patron->set_password( { password => $password, skip_validation => 1 } );
  $patron->userid('u' . $patron->borrowernumber)->store;
  my $userid = $patron->userid;

  foreach my $permission (@{$params->{permissions}}) {
    my $dbh   = C4::Context->dbh;
    $dbh->do( "
      INSERT INTO user_permissions (borrowernumber,module_bit,code)
      VALUES (?,?,?)", undef,
      $patron->borrowernumber,
      $permission->{module},
      $permission->{subpermission}
    );
  }

  return ($patron, "$userid:$password", $password);
}

sub decorate_marcxml_for_signum_and_bib_class {
  my ($biblio) = @_;
  unless ($biblio) {
    $biblio = Koha::Biblio->search()->next;
  }
  die "\$biblio='$biblio' is not a Koha::Biblio!" unless ref($biblio) eq 'Koha::Biblio';

  my $r = $biblio->record;
  my @delete = $r->field('08.');
  $r->delete_fields(@delete);
  $r->append_fields(MARC::Field->new('082', '', '', 'a' => '1.2.3.4', '2' => 'YKL'));
  $r->append_fields(MARC::Field->new('084', '', '', 'a' => '84.2', '2' => 'Finto'));
  $r->append_fields(MARC::Field->new('086', '', '', 'a' => 'Muu', '2' => 'Oma'));

  @delete = $r->field('1..');
  $r->delete_fields(@delete);
  $r->append_fields(MARC::Field->new('100', '', '', 'a' => 'Meikäläinen, Matti'));

  C4::Biblio::ModBiblio($r, $biblio->biblionumber, $biblio->frameworkcode);
  return $biblio;
}

#Mock the directory Koha looks for plugins to be this Plugin's dev source code dir
sub MockPluginsdir {
  $C4::Context::context->{config}->{config}->{pluginsdir} = Cwd::abs_path(File::Spec->catfile(__FILE__,'..','..','..'));
}

my @randomStringChars = ('A'..'Z', 'a'..'z', '0'..'9');  # Alphanumeric characters
sub RandomString {
  my $length = shift;
  return join '', map { $randomStringChars[rand @randomStringChars] } 1..$length;
}

1;