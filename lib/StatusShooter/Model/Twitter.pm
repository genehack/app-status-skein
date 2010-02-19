package StatusShooter::Model::Twitter;
use strict;
use warnings;
use base 'Catalyst::Model::Factory';

__PACKAGE__->config( class => 'StatusShooter::Client::Twitter' );

1;
