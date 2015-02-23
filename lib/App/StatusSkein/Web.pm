package App::StatusSkein::Web;

use Moose;
use namespace::autoclean;
use Catalyst qw/
                 -Debug
                 ConfigLoader
                 Session
                 Session::Store::FastMmap
                 Session::State::Cookie
                 Static::Simple
               /;
extends 'Catalyst';

__PACKAGE__->config( 'Plugin::ConfigLoader' => { file => 'app_statusskein_web.yaml' } );

__PACKAGE__->setup();

1;
