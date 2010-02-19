package App::StatusSkein::Web;

use strict;
use warnings;

use Catalyst::Runtime 5.80;

use parent qw/Catalyst/;
use Catalyst qw/
                 -Debug
                 ConfigLoader
                 Session
                 Session::Store::FastMmap
                 Session::State::Cookie
                 Static::Simple
                 Unicode
               /;

our $VERSION = '0.01';

__PACKAGE__->setup();

1;
