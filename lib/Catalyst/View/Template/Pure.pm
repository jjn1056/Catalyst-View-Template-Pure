use strict;
use warnings;

package Catalyst::View::Template::Pure;

use Catalyst::View::Template::Pure::Response;
use Scalar::Util qw/blessed refaddr/;
use Catalyst::Utils;
use HTTP::Status ();

use base 'Catalyst::View';

our $VERSION = '0.001';

sub COMPONENT {
  my ($class, $app, $args) = @_;
  $args = $class->merge_config_hashes($class->config, $args);
  $args = $class->modify_init_args($args) if $class->can('modify_init_args');
  $class->on_init($app, $args) if $class->can('on_init');
  $class->inject_http_status_helpers($args);
  return bless $args, $class;
}

sub inject_http_status_helpers {
  my ($class, $args) = @_;
  foreach my $helper( grep { $_=~/^http/i} @HTTP::Status::EXPORT_OK) {
    my $subname = lc $helper;
    if(grep { HTTP::Status->$helper == $_ } @{ $args->{returns_status}||[]}) {
      eval "sub $class::$subname { return shift->response(HTTP::Status::$helper,\@_) }";
    }
  }
}

sub ACCEPT_CONTEXT {
  my ($self, $c, %args) = @_;
  my $args = $self->merge_config_hashes($self->config, \%args);

  #$c->stats->profile(begin => "=> ". Catalyst::Utils::class2classsuffix($self->catalyst_component_name));

  $args = $self->modify_context_args($args) if $self->can('modify_context_args');
  $self->handle_request($c, %$args) if $self->can('handle_request');

  my $template;
  if(exists($args->{template})) {
    $template = delete ($args->{template});
  } elsif(exists($args->{template_src})) {
    $template = $c->config->{root}->file(delete $args->{template_src})->slurp;
  } else {
    die "Can't find a template for your View";
  }

  my $directives = delete $args->{directives};
  my $pure_class = exists($args->{pure_class}) ?
    delete($args->{pure_class}) :
    'Template::Pure';

  Catalyst::Utils::ensure_class_loaded($pure_class);

  my $key = blessed($self) ? refaddr($self) : $self;

  if(blessed $c) {
    $c->stash->{"__Pure_${key}"} ||= do {
      $self->before_build($c, %$args) if $self->can('before_build');
      my $pure = $pure_class->new(
        template => $template,
        directives => $directives,
        components => +{
          map {
            my $v = $_;
            lc($v) => sub {
            my ($pure, %params) = @_;
            return $c->view($v, %params);
          } } ($c->views)
        },
        %$args,
      );
      
      my $new = ref($self)->new(
        %{$args},
        %{$c->stash},
        ctx => $c,
        pure => $pure,
      );
      $new->after_build($c) if $new->can('after_build');
      $new;
    };
    #$c->stats->profile(end => "=> ". Catalyst::Utils::class2classsuffix($self->catalyst_component_name));
    return $c->stash->{"__Pure_${key}"};
  } else {
    die "Can't make this class without a context";
  }
}

sub apply_view {
  my ($self, $view, %args) = (@_, template => $_[0]->render);
  return $self->{ctx}->view($view, %{$self->{ctx}->stash},%args)
}

sub response {
  my ($self, $status, @proto) = @_;
  die "You need a context to build a response" unless $self->{ctx};

  my $res = $self->{ctx}->res;
  $status = $res->status if $res->status != 200;

  if(ref($proto[0]) eq 'ARRAY') {
    my @headers = @{shift @proto};
    $res->headers->push_header(@headers);
  }

  $self->on_response($self->{ctx},$res) if $self->can('on_response');
  $res->content_type('text/html') unless $res->content_type;
  my $body = $res->body($self->render);

  my $response = bless +{
    ctx => $self->{ctx},
    content => $body,
  }, 'Catalyst::View::Template::Pure::Response';

  return $response;
}

sub render {
  my ($self, $data) = @_;
  $self->{ctx}->stats->profile(begin => "=> ".Catalyst::Utils::class2classsuffix($self->catalyst_component_name)."->Render");

  $self->before_render($self->{ctx}) if $self->can('before_render');
  # quite possible I should do something with $data...
  my $string = $self->{pure}->render($self);
  $self->{ctx}->stats->profile(end => "=> ".Catalyst::Utils::class2classsuffix($self->catalyst_component_name)."->Render");
  return $string;
}

sub TO_HTML {
  my ($self, $pure, $dom, $data) = @_;
  return $self->{pure}->encoded_string(
    $self->render($self));
}

sub Views {
  my $self = shift;
  my %views = (
    map {
      my $v = $_;
      $v => sub {
        my ($pure, $dom, $data) = @_;
        # TODO $data can be an object....
        $self->{ctx}->view($v, %$data);
      }
    } ($self->{ctx}->views)
  );
  return \%views;
}

# Proxy these here for now.  I assume eventually will nee
# a subclass just for components
sub style_fragment { shift->{pure}->style_fragment }
sub script_fragment { shift->{pure}->script_fragment }
sub ctx { return shift->{ctx} }

1;

=head1 TITLE

Catalyst::View::Template::Pure - Catalyst view adaptor for Template::Pure

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

This class defines the following methods.

=head1 ALSO SEE

L<Catalyst>, L<Template::Pure>

=head1 AUTHORS & COPYRIGHT

John Napiorkowski L<email:jjnapiork@cpan.org>

=head1 LICENSE

Copyright 2016, John Napiorkowski  L<email:jjnapiork@cpan.org>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
