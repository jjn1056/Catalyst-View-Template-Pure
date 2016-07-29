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

__PACKAGE__->meta->make_immutable;
