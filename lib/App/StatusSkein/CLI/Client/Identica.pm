# PODNAME: App::Statusskein::Cli::Client::Identica
use MooseX::Declare;

class App::StatusSkein::CLI::Client::Identica extends App::StatusSkein::CLI::Client {
  use App::StatusSkein::CLI::Post::Identica;
  use Date::Parse;
  use HTTP::Response;
  use Net::Identica;
  use Net::Twitter::Error;

  has '_client' => (
    is         => 'ro' ,
    isa        => 'Net::Identica' ,
    handles    => [
      'create_favorite' ,
      'destroy_favorite' ,
      'get_error' ,
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
  };

  method add_fave ( Str $id ) { $self->create_favorite( $id ) };
  method del_fave ( Str $id ) { $self->destroy_favorite( $id ) };

  method filter_posts ( Num :$since , ArrayRef :$posts ) {
    return [ grep { str2time( $_->{created_at} ) >= $since } @$posts ];
  };

  method recycle_post ( Str $id ) { $self->retweet( $id ) };

  method verify_credentials {
    my $response = $self->_client->verify_credentials;
    return 1 if defined $response;

    my $error = $self->get_error->{error};
    if ( $error eq 'Could not authenticate you.' ) {
      my $err = Net::Twitter::Error->new(
        http_response => HTTP::Response->new() ,
        twitter_error => $self->get_error ,
      );
      die $err;
    }
    die $error;
  };
}
