package  Test::CatalystTemplatePureApp::View::TicTacToe;

use Moose;
use HTTP::Status qw(
  HTTP_OK,
  HTTP_CREATED);

extends 'Catalyst::View::Template::Pure';

has 'title' => (is=>'ro', required=>1);

__PACKAGE__->config(
  returns_status => [HTTP_OK, HTTP_CREATED],
  template => qq[
    <html>
      <head>
        <title>New Game</title>
      </head>
      <body>
        <h1>Information</h1>
          <dl>
            <dt>Time of Request</dt>
            <dd id='time'>Jan 1</dd>
            <dt>Requested Move</dt>
            <dd id='moves'>2</dd>
          </dl>
        <h1>Links</h1>
        <p>Your <a id='new_game_url'>new game</a></p>
        <h1 id='game'>Current Game Status</h1>
      </body>
    </html>
  ],
  directives => [
    title => 'title',
  ],
);

__PACKAGE__->meta->make_immutable;

