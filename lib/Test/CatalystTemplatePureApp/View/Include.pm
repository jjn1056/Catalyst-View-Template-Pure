package  Test::CatalystTemplatePureApp::View::Include;

use Moose;
use HTTP::Status qw(:constants);

extends 'Catalyst::View::Template::Pure';

has 'items' => (is=>'ro', required=>1);

__PACKAGE__->config(
  template => q{
    <p>Total Items: </p>
  },
  directives => [
    'p+' => sub {
      my ($t, $dom, $data) = @_;
      return $t->data_at_path($data, 'items.count');
    },
  ],
);

__PACKAGE__->meta->make_immutable;

