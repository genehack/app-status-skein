package App::StatusSkein::Web::Model::Facebook;
use strict;
use warnings;
use base 'Catalyst::Model::Adaptor';

__PACKAGE__->config( class => 'App::StatusSkein::CLI::Client::Facebook' );

1;
