use strict;
use warnings;

package Catalyst::View::Template::Pure::Response;

sub detach { shift->{ctx}->detach }

1;

