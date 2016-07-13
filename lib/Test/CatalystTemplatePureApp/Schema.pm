use strict;
use warnings;

package Test::CatalystTemplatePureApp::Schema;

our $VERSION = 1;
use base 'DBIx::Class::Schema';

__PACKAGE__->load_components(qw/
  Helper::Schema::QuoteNames
  Helper::Schema::DidYouMean
  Helper::Schema::DateTime/);

__PACKAGE__->load_namespaces(
  default_resultset_class => "DefaultRS");

sub now {
  my $self = shift;
  my $dbh = $self->storage->dbh;
  my $now = $dbh->selectrow_arrayref(
    "select now() from users limit 1");
  return $now;
}

sub setup {
  my $self = shift;
}

1;

