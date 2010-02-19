package App::StatusSkein::Web::Model::CLI;
use strict;
use warnings;
use base 'Catalyst::Model::Adaptor';

__PACKAGE__->config( class => 'App::StatusSkein::CLI' );

1;
