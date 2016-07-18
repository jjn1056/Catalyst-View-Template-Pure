package  Test::CatalystTemplatePureApp::View::Common;

use Moo;

extends 'Catalyst::View::Template::Pure';

has [qw/init_time title body/] => (is=>'ro', required=>1);

__PACKAGE__->config(
  init_time => scalar(localtime),
  template => qq[
    <!doctype html>
    <html lang="en">
      <head>
        <title>Title Goes Here</title>
        <meta charset="utf-8" />
          <meta name="description" content="ToDo List">
            <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      </head>
      <body>
        <h1>Content goes here!</h1>
        <div>
          <span id="init-time">Server Started On: </span>
        </div>
      </body>
    </html>
  ],
  directives => [
    'title' => 'title',
    '^body h1' => 'body',
    '#init-time+' => 'init_time',
  ],
);

