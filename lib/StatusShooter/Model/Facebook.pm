package StatusShooter::Model::Facebook;
use strict;
use warnings;
use base 'Catalyst::Model::Adaptor';

__PACKAGE__->config( class => 'StatusShooter::Client::Facebook' );

1;
