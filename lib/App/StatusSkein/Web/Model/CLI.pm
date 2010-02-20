package App::StatusSkein::Web::Model::CLI;
use strict;
use warnings;
use base 'Catalyst::Model::Adaptor';

__PACKAGE__->config( class => 'App::StatusSkein::CLI' );

my $config = App::StatusSkein::Web->path_to( 'app_statusskein_cli.yaml' );

__PACKAGE__->config( args => { config_file => $config } );

1;
