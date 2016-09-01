use strict;
use warnings;

package Catalyst::View::Template::Pure::Helpers;

use Exporter 'import';
use Template::Pure::DataProxy;

our @EXPORT_OK = (qw/Uri/);
our %EXPORT_TAGS = (All => \@EXPORT_OK, ALL => \@EXPORT_OK);

sub Uri {
  my ($path, @args) = @_;
  die "$path is not a string" unless ref \$path eq 'SCALAR';
  my ($controller_proto, $action_proto) = ($path=~m/^(.*)\.(.+)$/); 
  return sub {
    my ($pure, $dom, $data) = @_;
    my $c = $pure->{view}{ctx};
    my $controller;
    if($controller_proto) {
      die "$controller_proto is not a controler!" unless
        $controller = $c->controller($controller_proto);
    } else {
      # if not specified, use the current
      $controller = $c->controller;
    }

    die "$action_proto is not an action for controller ${\$controller->component_name}"
      unless my $action = $controller->action_for($action_proto);

    $data = Template::Pure::DataProxy->new(
      $data,
      captures => $c->request->captures || [],
      args => $c->request->args || [],
      query => $c->request->query_parameters|| +{});

    # We need to unroll the @args and fill in any template values.
    my $resolve = sub {
      my $arg = shift;
      if(my ($v) = ($arg=~m/^\=\{(.+)\}$/)) {
        return $pure->data_at_path($data,$v);
      } else {
        return $arg;
      }
    };

    # Change any placeholders.
    my @local_args = map {
      my $arg = $_;
      if(ref \$_ eq 'SCALAR') {
        $arg = $resolve->($arg);
      } elsif(ref $arg eq 'ARRAY') {
        $arg = [map { $resolve->($_) } @$arg];
      } elsif(ref $arg eq 'HASH') {
        $arg = +{map { my $val = $arg->{$_}; $resolve->($_) => $resolve->($val) } keys %$arg};
      }
      $arg;
    } @args;

    my $uri = $c->uri_for($action, @local_args);
    return $pure->encoded_string("$uri"); 
  };
}

1;

=head1 NAME
 
Catalyst::View::Template::Pure::Helpers - Simplify some boilerplate

=head1 SYNOPSIS
 
    package  MyApp::View::Story;

    use Moose;
    use Catalyst::View::Template::Pure::Helpers (':ALL');
    extends 'Catalyst::View::Template::Pure';

    has [qw/title body capture arg q/] => (is=>'ro', required=>1);

    __PACKAGE__->config(
      returns_status => [200],
      template => q[
        <!doctype html>
        <html lang="en">
          <head>
            <title>Title Goes Here</title>
          </head>
          <body>
            <a name="hello">hello</a>
          </body>
        </html>      
      ],
      directives => [

        'a[name="hello"]@href' => Uri('Story.last',['={year}'], '={id}', {q=>'={q}',rows=>5}),
      ],
    );
 
=head1 DESCRIPTION

Generates code for some common tasks you need to do in your templates, such
as build URLs etc.

=head2 Uri

Used to generate a URL via $c->uri_for.  Takes arguements like:

    Uri("$controller.$action", \@captures, @args, \%query)

Basically if follows $c->uri_for, except the first argument must be a string with
the target Controller 'dot' and action.  You can use an action relative to the current
controller by leave off the controller string (but the 'dot' in from the of the action
is required.

We fill placeholders in the arguments in the same was as in templates, for example:

    Uri('Story.last',['={year}'], '={id}', {q=>'={q}',rows=>5})

Would fill year, id and q from the current data context.  We also merge in the following
keys to the current data context:

      captures => $c->request->captures,
      args => $c->request->args,
      query => $c->request->query_parameters;

To make it easier to fill data from the current request.
  
=head1 SEE ALSO
  
L<Template::Pure>, L<Catalyst::View::Template::Pure>
 
=head1 AUTHOR
  
    John Napiorkowski L<email:jjnapiork@cpan.org>
 
=head1 COPYRIGHT & LICENSE
  
Please see L<Catalyst::View::Template::Pure>> for copyright and license information.
 
