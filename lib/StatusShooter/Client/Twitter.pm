use MooseX::Declare;

class StatusShooter::Client::Twitter extends StatusShooter::Client {
  use Net::Twitter;
  use StatusShooter::Post::Twitter;

  has '_client' => (
    is         => 'ro' ,
    isa        => 'Net::Twitter' ,
    handles    => [ 'update' ] ,
    lazy_build => 1 ,
  );

  has traits              => ( is => 'ro' , isa => 'ArrayRef' , required => 1 );
  has access_token        => ( is => 'ro' , isa => 'Str'      , required => 1 );
  has access_token_secret => ( is => 'ro' , isa => 'Str'      , required => 1 );
  has consumer_secret     => ( is => 'ro' , isa => 'Str'      , required => 1 );
  has consumer_key        => ( is => 'ro' , isa => 'Str'      , required => 1 );

  method _build__client {
    return Net::Twitter->new(
      traits              => $self->traits ,
      access_token        => $self->access_token ,
      access_token_secret => $self->access_token_secret ,
      consumer_secret     => $self->consumer_secret ,
      consumer_key        => $self->consumer_key ,
    );
  }

  method get_posts {
    my $posts;
    eval { $posts = $self->_client->home_timeline };
    die $@ if $@;

    $posts = [ map { StatusShooter::Post::Twitter->new({ post => $_ }) } @$posts ];

    return $posts;
  }
}

