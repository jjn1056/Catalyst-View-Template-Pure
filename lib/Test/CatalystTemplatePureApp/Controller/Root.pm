package  Test::CatalystTemplatePureApp::Controller::Root;

use Moose;
use MooseX::MethodAttributes;

extends 'Catalyst::Controller';

sub root :Chained(/) PathPart('') CaptureArgs(0)
{
  my ($self, $c) = @_;
  $c->stash(title => 'My Todo List');
}

  sub summary_list :GET Chained(root) PathPart('') Args(0)  {
    my ($self, $c) = @_;
    $c->view('SummaryList',
      items => $c->model('Schema::Todo'))
      ->apply_view('CommonHead')
      ->http_ok;
  }

  sub add :POST Chained(root) PathPart('') Args(0) {
    my ($self, $c) = @_;
    my $form = $c->model('Form::Todo',
      $c->model('Schema::Todo::Result'));

    my $view = $c->view('SummaryList',
      items => $c->model('Schema::Todo'))
      ->apply_view('CommonHead');

    if($form->is_valid) {
      $view->http_ok;
    } else {
      $view->apply_view('InputErrors',
        errors => $form->errors_by_name)
        ->http_bad_request;
    }
  }

__PACKAGE__->meta->make_immutable;
