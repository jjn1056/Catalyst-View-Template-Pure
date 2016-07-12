package  Test::CatalystTemplatePureApp::View::CommonHead;

use Moose;
use HTTP::Status qw(:constants);

extends 'Catalyst::View::Template::Pure';

has 'title' => (is=>'ro', isa=>'Str', required=>1);

__PACKAGE__->config(
  returns_status => [HTTP_OK, HTTP_CREATED],
  directives => [ title => 'title' ],
);

__PACKAGE__->meta->make_immutable;

