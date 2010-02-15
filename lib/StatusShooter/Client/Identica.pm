use MooseX::Declare;

class StatusShooter::Client::Identica extends StatusShooter::Client {
  use Net::Identica;
  use StatusShooter::Post::Identica;

  has '_client' => (
    is         => 'ro' ,
    isa        => 'Net::Identica' ,
    handles    => [
      'create_favorite' ,
      'destroy_favorite' ,
      'retweet' ,
      'show_status' ,
      'update'
    ] ,
    lazy_build => 1 ,
  );

  has username => ( is => 'ro' , isa => 'Str' , required => 1 );
  has password => ( is => 'ro' , isa => 'Str' , required => 1 );

  has '+type' => ( default => 'Identica' );

  method _build__client {
    return Net::Identica->new(
      username => $self->username ,
      password => $self->password ,
    );
  }
}

