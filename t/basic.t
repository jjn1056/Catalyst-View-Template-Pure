use Test::Most;

{
    package  MyApp::View::Include;
    $INC{'MyApp/View/Include.pm'} = __FILE__;

    use Moose;
    extends 'Catalyst::View::Template::Pure';

    sub now { scalar localtime }

    __PACKAGE__->config(
      template => q{
        <div class="timestamp">The Time is now: </div>
      },
      directives => [
        '.timestamp' => 'now'
      ],
    );

    __PACKAGE__->meta->make_immutable;

    package  MyApp::View::Story;
    $INC{'MyApp/View/Story.pm'} = __FILE__;

    use Moose;
    extends 'Catalyst::View::Template::Pure';

    has [qw/title body/] => (is=>'ro', required=>1);

    sub timestamp { scalar localtime }

    __PACKAGE__->config(
      returns_status => [200],
      init_time => scalar(localtime),
      template => q[
        <!doctype html>
        <html lang="en">
          <head>
            <title>Title Goes Here</title>
          </head>
          <body>
            <div id="main">Content goes here!</div>
            <div id="timestamp">Server Started on:</div>
            <?pure-include src='Views.Include'?>
          </body>
        </html>      
      ],
      directives => [
        'title' => 'title',
        '#main' => 'body',
        '#timestamp+' => 'timestamp',
      ],
    );

    __PACKAGE__->meta->make_immutable;

    package MyApp::Controller::Story;
    $INC{'MyApp/Controller/Story.pm'} = __FILE__;

    use Moose;
    use MooseX::MethodAttributes;

    extends 'Catalyst::Controller';

    sub display_story :Path('') Args(0) {
      my ($self, $c) = @_;
      $c->view('Story',
        title => 'A Dark and Stormy Night...',
        body => 'It was a dark and stormy night. Suddenly...',
      )->http_ok;

      Test::Most::is "${\$c->view('Story')}", "${\$c->view('Story')}",
        'make sure the view is per request not factory';
    }

    __PACKAGE__->meta->make_immutable;

    package MyApp;
    $INC{'MyApp.pm'} = __FILE__;

    use Catalyst;

    MyApp->setup;
}

use Catalyst::Test 'MyApp';
use Mojo::DOM58;

ok my $res = request '/story';
ok my $dom = Mojo::DOM58->new($res->content);

#warn $res->content;

is $dom->at('title')->content, 'A Dark and Stormy Night...';
is $dom->at('#main')->content, 'It was a dark and stormy night. Suddenly...';
like $dom->at('#timestamp')->content, qr/Server Started on:.+$/;

done_testing;

