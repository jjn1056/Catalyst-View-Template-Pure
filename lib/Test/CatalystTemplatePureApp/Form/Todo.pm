package Test::CatalystTemplatePureApp::Form::Todo;

use HTML::FormHandler::Moose;

extends 'HTML::FormHandler';

has_field 'title' => (
  type => 'Text',
  minlength => 3,
  maxlength => 60,
  required => 1 );

sub update_model {
  my $self = shift;
  my %values = %{$self->values};
  for($self->item) {
    $_->title($values{title});
    $_->insert_or_update;
  }
}

sub prepare_error_response {  
  return +{
    form_error => $_[0]->form_errors,
    error_by_field => $_[0]->errors_by_name,
    fields => $_[0]->fif};
}

__PACKAGE__->meta->make_immutable;
