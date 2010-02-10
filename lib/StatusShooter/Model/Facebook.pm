package StatusShooter::Model::Facebook;
use strict;
use warnings;
use base 'Catalyst::Model::Adaptor';

__PACKAGE__->config( class => 'WWW::Facebook::API' );

1;
