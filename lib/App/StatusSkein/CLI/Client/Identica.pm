use MooseX::Declare;

class App::StatusSkein::CLI::Client::Identica extends App::StatusSkein::CLI::Client {
  use Net::Identica;
  use App::StatusSkein::CLI::Post::Identica;

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

