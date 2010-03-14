package App::StatusSkein::Web::Model::CLI;
use base 'Catalyst::Model::Adaptor';

my $config = App::StatusSkein::Web->path_to( 'app_statusskein_cli.yaml' );

__PACKAGE__->config(
  args  => { config_file => $config } ,
  class => 'App::StatusSkein::CLI' ,
);

1;
