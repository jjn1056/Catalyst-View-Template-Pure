package  Test::CatalystTemplatePureApp::Controller::Root;

use Moose;
use MooseX::MethodAttributes;

extends 'Catalyst::Controller';

sub root :Chained(/) PathPart('') CaptureArgs(0)
{
  my ($self, $c) = @_;
}

  sub summary_list :Chained(root) PathPart('') Args(0)
  {
    my ($self, $c) = @_;
    $c->view('SummaryList',
        errors => $c->model('Form::Todo'),
        items => $c->model('Schema::Todo'))
      ->apply_view('CommonHead',
        title => 'My Todo List')
      ->http_ok;
  }

  sub add :POST Chained(root) PathPart('') Args(0)
  {
    my ($self, $c) = @_;
    my $form = $c->model('Form::Todo',
      $c->model('Schema::Todo::Result'));
    $c->detach('summary_list');
  }

__PACKAGE__->meta->make_immutable;
