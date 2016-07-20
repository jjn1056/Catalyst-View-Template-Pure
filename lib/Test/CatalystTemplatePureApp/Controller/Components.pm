package  Test::CatalystTemplatePureApp::Controller::Components;

use Moose;
use MooseX::MethodAttributes;

extends 'Catalyst::Controller';

sub root :Chained(../) PathPart('components') CaptureArgs(0)
{
  my ($self, $c) = @_;
  $c->current_view_instance(
    $c->view('Components'));
}

  sub display :GET Chained(root) PathPart('') Args(0)  {
    my ($self, $c) = @_;
    $c->view->http_ok;
  }

__PACKAGE__->meta->make_immutable;
