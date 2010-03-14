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
                 Unicode
               /;
extends 'Catalyst';

__PACKAGE__->setup();

1;
