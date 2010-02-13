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
      'show_status' ,
      'update'
    ] ,
    lazy_build => 1 ,
  );

  has username => ( is => 'ro' , isa => 'Str' , required => 1 );
  has password => ( is => 'ro' , isa => 'Str' , required => 1 );

  method _build__client {
    return Net::Identica->new(
      username => $self->username ,
      password => $self->password ,
    );
  }

  method get_posts {
    my $posts;
    eval { $posts = $self->_client->home_timeline };
    die $@ if $@;

    $posts = [ map { StatusShooter::Post::Identica->new({ post => $_ }) } @$posts ];

    return $posts;
  }
}

