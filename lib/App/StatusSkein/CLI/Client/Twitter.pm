use MooseX::Declare;

class App::StatusSkein::CLI::Client::Twitter extends App::StatusSkein::CLI::Client {
  use Net::Twitter;
  use App::StatusSkein::CLI::Post::Twitter;

  has '_client' => (
    is         => 'ro' ,
    isa        => 'Net::Twitter' ,
    handles    => [
      'create_favorite' ,
      'destroy_favorite' ,
      'retweet' ,
      'show_status' ,
      'update' ,
      'verify_credentials' ,
    ] ,
    lazy_build => 1 ,
  );

  has traits => (
    is       => 'ro' ,
    isa      => 'ArrayRef' ,
    required => 1 ,
    default  => sub { [ qw/ API::REST InflateObjects / ] }
  );

  has username => ( is => 'ro' , isa => 'Str'      , required => 1 );
  has password => ( is => 'ro' , isa => 'Str'      , required => 1 );

  has '+type' => ( default => 'Twitter' );

  method _build__client {
    return Net::Twitter->new(
      traits   => $self->traits ,
      username => $self->username ,
      password => $self->password ,
    );
  }
}

