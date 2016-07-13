package  Test::CatalystTemplatePureApp::View::InputErrors;

use Moose;
use HTTP::Status qw(:constants);

extends 'Catalyst::View::Template::Pure';

has 'errors' => (is=>'ro', isa=>'HashRef', required=>1);

__PACKAGE__->config(
  template => q[
    <div>
      <ol>
        <li>ERR</li>
      </ol>
    </div>
  ],
  
  directives => [
    'li' => {
      'err<-errors' => [
        '.' => 'err',
      ],
    },
  ],
);

__PACKAGE__->meta->make_immutable;

