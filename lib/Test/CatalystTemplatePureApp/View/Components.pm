package  Test::CatalystTemplatePureApp::View::Components;

use Moose;
use HTTP::Status qw(:constants);

extends 'Catalyst::View::Template::Pure';

__PACKAGE__->config(
  returns_status => [HTTP_OK],
  template => q[
    <?pure-overlay src='Views.Common' 
      title=\'title'
      body=\'body'?>
    <html>
      <head>
        <title>Components</title>
      </head>
      <body>
        <h1>Components</h1>
        <div>
          <pure-components-timestamp tz='America/Los_Angeles'/>
        </div>
      </body>
    </html>
  ],
  directives => [
  ],
);

__PACKAGE__->meta->make_immutable;

