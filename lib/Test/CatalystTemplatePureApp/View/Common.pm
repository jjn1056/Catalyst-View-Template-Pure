package  Test::CatalystTemplatePureApp::View::Common;

use Moo;
extends 'Catalyst::View::Template::Pure';

has [qw/init_time title body/] => (is=>'ro', required=>1);

__PACKAGE__->config(
  init_time => scalar(localtime),
  auto_template_src => 1,
  directives => [
    'title' => 'title',
    '^body h1' => 'body',
    '^#init-time+' => 'init_time',
  ],
);

