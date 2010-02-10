package StatusShooter::Model::Twitter;
use strict;
use warnings;
use base 'Catalyst::Model::Adaptor';

__PACKAGE__->config( class => 'Net::Twitter' );

sub mangle_arguments {
  my( $self , $args ) = @_;
  return %$args;
}

1;
