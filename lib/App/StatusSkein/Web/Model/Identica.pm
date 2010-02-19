package App::StatusSkein::Web::Model::Identica;
use strict;
use warnings;
use base 'Catalyst::Model::Adaptor';

__PACKAGE__->config( class => 'App::StatusSkein::CLI::Client::Identica' );

1;
