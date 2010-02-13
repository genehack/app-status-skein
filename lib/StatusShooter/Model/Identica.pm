package StatusShooter::Model::Identica;
use strict;
use warnings;
use base 'Catalyst::Model::Adaptor';

__PACKAGE__->config( class => 'StatusShooter::Client::Identica' );

1;
