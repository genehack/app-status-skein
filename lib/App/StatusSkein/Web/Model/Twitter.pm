package App::StatusSkein::Web::Model::Twitter;
use strict;
use warnings;
use base 'Catalyst::Model::Adaptor';

__PACKAGE__->config( class => 'App::StatusSkein::CLI::Client::Twitter' );

1;
