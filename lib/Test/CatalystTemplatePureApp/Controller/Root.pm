package  Test::CatalystTemplatePureApp::Controller::Root;

use Moose;
use MooseX::MethodAttributes;

extends 'Catalyst::Controller';

sub root :Chained(/) PathPart('') CaptureArgs(0)
{
  my ($self, $c) = @_;
  $c->current_view_instance(
    $c->view('SummaryList',
      items => $c->model));
}

  sub summary_list :GET Chained(root) PathPart('') Args(0)  {
    my ($self, $c) = @_;
    $c->view->http_ok;
  }

  sub add :POST Chained(root) PathPart('') Args(0) {
    my ($self, $c) = @_;
    my $form = $c->model('Form::Todo',
      $c->model->new_result(+{}));
    $form->is_valid ?
      $c->view->http_ok :
      $c->view->apply('InputErrors', $form)
        ->http_bad_request;
  }

__PACKAGE__->meta->make_immutable;
