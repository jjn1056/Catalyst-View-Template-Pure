use strict;
use warnings;

package Test::CatalystTemplatePureApp::Schema::Result::Todo;

use base 'Test::CatalystTemplatePureApp::Schema::Result';

__PACKAGE__->table('todo');
__PACKAGE__->add_columns(
  todo_id => {
    data_type => 'integer',
    is_auto_increment => 1,
  },
  title => {
    data_type => 'varchar',
    size => '60',
  },
  order => {
    data_type => 'integer',
  },
  completed => {
    data_type => 'boolean',
    default_value => 'false',
  },
);

__PACKAGE__->set_primary_key('todo_id');
__PACKAGE__->load_components('Ordered');
__PACKAGE__->position_column('order');

1;
