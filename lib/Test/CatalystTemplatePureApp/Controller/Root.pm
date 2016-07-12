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
        items=>[qw/aaa bbb ccc/])
      ->apply_view('CommonHead',
        title => 'My Todo List')
      ->http_ok;
  }

__PACKAGE__->config(namespace => '');
__PACKAGE__->meta->make_immutable;
