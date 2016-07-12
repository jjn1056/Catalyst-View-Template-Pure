package  Test::CatalystTemplatePureApp::View::SummaryList;

use Moose;
use HTTP::Status qw(:constants);

extends 'Catalyst::View::Template::Pure';

has 'items' => (is=>'ro', isa=>'ArrayRef', required=>1);

__PACKAGE__->config(
  returns_status => [HTTP_OK, HTTP_CREATED],
  template => qq[
    <html>
      <head>
        <title>TITLE</title>
      </head>
      <body>
        <h1>Pending Items</h1>
        <ol>
          <li class='item'>Example Item</li>
        </ol>
      </body>
    </html>
  ],
  directives => [
    '.item' => {
      'item<-items' => [
        '.' => 'item',
      ],
    },
  ],
);

__PACKAGE__->meta->make_immutable;

