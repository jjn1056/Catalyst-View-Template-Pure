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
        <script src="https://cdn.jsdelivr.net/semantic-ui/2.2.2/semantic.min.js"></script>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/semantic-ui/2.2.2/semantic.min.css">
        <title>TITLE</title>
      </head>
      <body>
        <h1>Pending Items on <span id='now'>NOW</span></h1>
        <ol>
          <li class='item'>No items in list</li>
        </ol>
        <form class='ui form' method='post'>
          <div class="ui form">
            <div class="field">
              <label>Title</label>
              <input type="title" placeholder="New Todo Item...">
            </div>
            <div class="ui error message">
              <p>eorr.</p>
            </div>
            <div class="ui submit button">Submit</div>
          </div>
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
    'input[name="title"]+' => sub {
      return 'ddd';
    }
  ],
);

__PACKAGE__->meta->make_immutable;
