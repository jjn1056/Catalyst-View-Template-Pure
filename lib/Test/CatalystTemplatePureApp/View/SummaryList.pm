package  Test::CatalystTemplatePureApp::View::SummaryList;

use Moose;
use HTTP::Status qw(:constants);

extends 'Catalyst::View::Template::Pure';

has 'items' => (
  is=>'ro',
  isa=>'Object',
  required=>1);

sub timestamp { localtime }

__PACKAGE__->config(
  returns_status => [HTTP_OK],
  template => qq[
    <html>
      <head>
        <title>TITLE</title>
      </head>
      <body>
        <h1>Pending Items on <span id='now'>NOW</span></h1>
        <ol>
          <li class='item'>No items in list</li>
        </ol>
        <form method='post'>
          <label>Title</label>
          <input type="text" name="title" placeholder="New Todo Item..." />
          <button>Submit</button>
        </form>
      </body>
    </html>
  ],
  directives => [
    '.item' => {
      'item<-items' => [
        '.' => 'item.title',
      ],
    },
    '#now' => 'timestamp',
  ],
);

__PACKAGE__->meta->make_immutable;
