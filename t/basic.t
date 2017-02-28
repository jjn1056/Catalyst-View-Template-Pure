use Test::Most;

{
    package  MyApp::View::Directives;
    $INC{'MyApp/View/Directives.pm'} = __FILE__;

    use Moose;
    extends 'Catalyst::View::Template::Pure';

    has [qw/body title names/] => (is=>'ro', required=>1);

    sub directives {
      my $self = shift;
      'title' => 'title',
      '#main' => 'body',
      '#names' => 'populate_names';
    }

    sub populate_names {
      my $self = shift;
      'li' => +{ 'name<-names' => 'name' };
    }

    # Insert stuff
    # Wrap a match
    sub add_sidebar {
      my ($self, $message) = @_;
      push @{$self->{pure}->{directives}},
        '+body' => sub {
          use Template::Pure;
          shift->encoded_string(Template::Pure->new(
            template => '<p>sidebar</p>',
            directives => [ p=>'message' ])
          ->render({ message=>$message}));
            
        },
    }

    __PACKAGE__->config(
      returns_status => [200],
      template => q[
        <!doctype html>
        <html lang="en">
          <head>
            <title>Title Goes Here</title>
          </head>
          <body>
            <div id="main">Content goes here!</div>
            <ul id="names">
              <li>Name</li>
            </ul>
          </body>
        </html>      
      ]);
    
    MyApp::View::Directives->meta->make_immutable;
    
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

    MyApp::View::Include->meta->make_immutable;

    package  MyApp::View::Story;
    $INC{'MyApp/View/Story.pm'} = __FILE__;

    use Moose;
    use Catalyst::View::Template::Pure::Helpers (':ALL');
    extends 'Catalyst::View::Template::Pure';

    has [qw/title body capture arg q author_action/] => (is=>'ro', required=>1);

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
            <a name="hello">hello</a>
            <a href="aaa?aa=1&bb=2">sss</a>
            <?pure-include src='Views.Include'?>
            <a name="authors">Authors</a>
          </body>
        </html>      
      ],
      directives => [
        'title' => 'title',
        '#main' => 'body',
        '#timestamp+' => 'timestamp',
        'a[name="hello"]@href' => Uri('last',['={capture}'], '={arg}', {q=>'={q}',rows=>5}),
        #  'a[name="authors"]@href' => Uri('Story::Authors.last',['={capture}']),
        #'a[name="authors"]@href' => Uri('authors/last',['={capture}']),
        #'a[name="authors"]@href' => Uri('/story/authors/last',['={capture}']),
        'a[name="authors"]@href' => Uri('={author_action}',['={capture}']),


      ],
    );

    MyApp::View::Story->meta->make_immutable;

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
        capture => 100, arg => 200, q => 'why',
        author_action => $self->action_for('authors/last'),
      )->http_ok;

      Test::Most::is "${\$c->view('Story')}", "${\$c->view('Story')}",
        'make sure the view is per request not factory';
    }

    sub directives :Path(/directives) {
      my ($self, $c) = @_;
      my $v = $c->view('Directives',
        title => 'subsub',
        body => 'hello body!',
        names => [ qw/aaa bbb ccc/ ],
      );
      
      $v->add_sidebar('hello');

      return $v->http_ok;
    }

    sub root :Chained(/) CaptureArgs(1) { }
    sub last :Chained(root) Args(1) {
      my ($self, $c, $id) = @_;
    }

    MyApp::Controller::Story->meta->make_immutable;

    package MyApp::Controller::Story::Authors;
    $INC{'MyApp/Controller/Story/Authors.pm'} = __FILE__;

    use Moose;
    use MooseX::MethodAttributes;

    extends 'Catalyst::Controller';

    sub root :Chained(/story/root) CaptureArgs(0) { }
    sub last :Chained(root) Args(0) {
      my ($self, $c, $id) = @_;
    }

    MyApp::Controller::Story::Authors->meta->make_immutable;

    package MyApp;
    $INC{'MyApp.pm'} = __FILE__;

    use Catalyst;

    MyApp->setup;
}

use Catalyst::Test 'MyApp';
use Mojo::DOM58;

{
  ok my $res = request '/story';
  ok my $dom = Mojo::DOM58->new($res->content);


  is $dom->at('title')->content, 'A Dark and Stormy Night...';
  is $dom->at('#main')->content, 'It was a dark and stormy night. Suddenly...';
  like $dom->at('#timestamp')->content, qr/Server Started on:.+$/;
}

{
  ok my $res = request '/directives';
  ok my $dom = Mojo::DOM58->new($res->content);

  is $dom->at('title')->content, 'subsub';
  is $dom->at('#main')->content, 'hello body!';
  is $dom->at('p')->content, 'hello';
  is $dom->find('#names li')->[0]->content, 'aaa';
  is $dom->find('#names li')->[1]->content, 'bbb';
  is $dom->find('#names li')->[2]->content, 'ccc';
}

done_testing;
