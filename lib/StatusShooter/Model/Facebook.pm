package StatusShooter::Model::Facebook;
use strict;
use warnings;
use base 'Catalyst::Model::Factory';

__PACKAGE__->config( class => 'StatusShooter::Client::Facebook' );

1;
