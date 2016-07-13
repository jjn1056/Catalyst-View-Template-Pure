use strict;
use warnings;

package Test::CatalystTemplatePureApp::Schema::Result;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/
  Helper::Row::RelationshipDWIM
  Helper::Row::SelfResultSet
  TimeStamp
  InflateColumn::DateTime/);

sub default_result_namespace { 'Test::CatalystTemplatePureApp::Schema::Result' }

sub add_columns {
  my @ret = (my $class = shift)
    ->next::method(@_);

  # Since we want this on every table...
  $class->add_column(
    created => {
      data_type => 'datetime',
      retrieve_on_insert => 1,
      set_on_create => 1,
  }) unless $class->has_column('created');

  return @ret;
}

1;
