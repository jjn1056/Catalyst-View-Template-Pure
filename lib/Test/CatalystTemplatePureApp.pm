package Test::CatalystTemplatePureApp;

use Test::DBIx::Class -schema_class => 'Test::CatalystTemplatePureApp::Schema';
use Catalyst qw/
  RedirectTo
  CurrentComponents
  URI
/;

__PACKAGE__->inject_components(
  'Model::Form' => { from_component => 'Catalyst::Model::HTMLFormhandler' },
  'Model::Schema' => { from_component => 'Catalyst::Model::DBIC::Schema' });

__PACKAGE__->request_class_traits([
  'ContentNegotiationHelpers']);

__PACKAGE__->config(
  default_model => 'Schema',
  'Model::Schema' => {
    traits => ['Result', 'SchemaProxy'],
    schema_class => 'Test::CatalystTemplatePureApp::Schema',
    connect_info => [ sub { Schema()->storage->dbh } ],
  },
);
__PACKAGE__->setup;
__PACKAGE__->model('Schema::Todo')
  ->create({title=>'Buy Milk!'});
