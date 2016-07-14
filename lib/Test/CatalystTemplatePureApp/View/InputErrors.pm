package  Test::CatalystTemplatePureApp::View::InputErrors;

use Moose;
use HTTP::Status qw(:constants);

extends 'Catalyst::View::Template::Pure';

has 'errors' => (is=>'ro', isa=>'HashRef', required=>1);

__PACKAGE__->config(
  returns_status => [HTTP_BAD_REQUEST],
  directives => [
    'input[name="title"]+' => {
      'err<-errors.optional:title' => [
        '.' => '<p>={err}</p> | encoded_string',
      ],
    },
  ],
);

__PACKAGE__->meta->make_immutable;

