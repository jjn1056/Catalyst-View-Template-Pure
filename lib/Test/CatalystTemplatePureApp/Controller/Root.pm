package  Test::CatalystTemplatePureApp::Controller::Root;

use Moose;
use MooseX::MethodAttributes;

extends 'Catalyst::Controller';

sub root :Chained(/) PathPart('') CaptureArgs(0)
{
  my ($self, $c) = @_;
}

  sub ttt :Chained(root) Args(0)
  {
    my ($self, $c) = @_;
    $c->view('TicTacToe',
      title=>'Hello World')
      ->http_ok
      ->{ctx}
      ->detach;
  }

__PACKAGE__->config(namespace => '');
__PACKAGE__->meta->make_immutable;
