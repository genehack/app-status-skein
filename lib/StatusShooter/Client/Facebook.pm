use MooseX::Declare;

class StatusShooter::Client::Facebook extends StatusShooter::Client {
  use StatusShooter::Post::Facebook;
  use WWW::Facebook::API;

  has '_client' => (
    is         => 'ro' ,
    isa        => 'WWW::Facebook::API' ,
    handles    => [ 'status' ] ,
    lazy_build => 1 ,
  );

  has api_key     => ( is => 'ro' , isa => 'Str' , required => 1 );
  has desktop     => ( is => 'ro' , isa => 'Int' , default  => 1 );
  has secret      => ( is => 'ro' , isa => 'Str' , required => 1 );
  has session_key => ( is => 'ro' , isa => 'Str' , required => 1 );

  has '+type' => ( default => 'Facebook' );

  method _build__client {
    return WWW::Facebook::API->new(
      api_key     => $self->api_key ,
      desktop     => $self->desktop ,
      secret      => $self->secret ,
      session_key => $self->session_key ,
    );
  }

  # this is fairly wasteful -- we're going to request the whole stream and
  # throw away everything but the post we want -- but there doesn't seem to be
  # a way to ask for a particular single post thru the Facebook API...
  method get_post ( $id ) {
    my $response = $self->get_posts;

    foreach ( @{ $response }) {
      next unless $_->id eq $id;
      return $_;
    }

    die "Unable to find post $id";
  }

  method get_posts {
    my $response = $self->_client->stream->get();

    my %profiles = map { $_->{id} => $_ } @{ $response->{profiles} };

    my $posts;

    foreach ( @{ $response->{posts} }) {
      next unless $_->{message};
      push @$posts ,
        StatusShooter::Post::Facebook->new({ post    => $_ ,
                                             profile => $profiles{$_->{source_id} }});
    }

    return $posts;
  }
}
