use MooseX::Declare;

class App::StatusSkein::CLI::Client::Facebook extends App::StatusSkein::CLI::Client {
  use App::StatusSkein::CLI::Post::Facebook;
  use WWW::Facebook::API;

  has '_client' => (
    is         => 'ro' ,
    isa        => 'WWW::Facebook::API' ,
    handles    => [ 'status' , 'stream' ] ,
    lazy_build => 1 ,
  );

  has api_key     => ( is => 'ro' , isa => 'Str' , required => 1 );
  has desktop     => ( is => 'ro' , isa => 'Int' , default  => 1 );
  has secret      => ( is => 'ro' , isa => 'Str' , required => 1 );
  has session_key => ( is => 'ro' , isa => 'Str' , required => 1 );

  has '+fave_add_method' => ( default => 'add_like' );
  has '+fave_del_method' => ( default => 'remove_like' );
  has '+type'            => ( default => 'Facebook' );

  method _build__client {
    return WWW::Facebook::API->new(
      api_key     => $self->api_key ,
      desktop     => $self->desktop ,
      secret      => $self->secret ,
      session_key => $self->session_key ,
    );
  }

  method add_like ( $id ) {
    my $status = $self->stream->add_like( post_id => $id );
    return if $status;
    die $status;
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

  method get_posts ( :$start_time ){
    my %args = ();
    $args{start_time} = $start_time if $start_time;

    my $posts = [];

    if ( my $response = $self->stream->get( %args )) {
      if( ref( $response->{posts} ) eq 'ARRAY' ) {
        my %profiles = map { $_->{id} => $_ } @{ $response->{profiles} };

        foreach ( @{ $response->{posts} }) {
          next unless $_->{message};
          push @$posts ,
            App::StatusSkein::CLI::Post::Facebook->new({ post    => $_ ,
                                                         profile => $profiles{$_->{source_id} }});
        }
      }
    }

    return $posts;
  }

  method remove_like ( $id ) {
    my $status = $self->stream->remove_like( post_id => $id );
    return if $status;
    die $status;
  }
}
