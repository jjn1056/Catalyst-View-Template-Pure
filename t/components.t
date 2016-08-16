use Test::Most;

{
    package  MyApp::View::Timestamp;
    $INC{'MyApp/View/Timestamp.pm'} = __FILE__;

    use Moose;
    use DateTime;

    extends 'Catalyst::View::Template::Pure';

    has 'tz' => (is=>'ro', predicate=>'has_tz');

    sub time {
      my ($self) = @_;
      my $now = DateTime->now();
      $now->set_time_zone($self->tz)
        if $self->has_tz;
      return $now;
    }

    __PACKAGE__->config(
      pure_class => 'Template::Pure::Component',
      template => qq[
        <span class='timestamp'>time</span>
      ],
      style => qq[
        .timestamp {
          background:blue;
        }
      ],
      directives => [
        '.timestamp' => 'time',
      ],
    );
    __PACKAGE__->meta->make_immutable;

    package  MyApp::View::Story;
    $INC{'MyApp/View/Story.pm'} = __FILE__;

    use Moose;
    extends 'Catalyst::View::Template::Pure';

    has [qw/title body/] => (is=>'ro', required=>1);

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
            <pure-timestamp />
          </body>
        </html>      
      ],
      directives => [
        'title' => 'title',
        '#main' => 'body',
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

warn $res->content;

is $dom->at('title')->content, 'A Dark and Stormy Night...';
is $dom->at('#main')->content, 'It was a dark and stormy night. Suddenly...';
ok $dom->at('.timestamp')->content;

done_testing;

