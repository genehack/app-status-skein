use MooseX::Declare;
class App::StatusSkein::CLI::Account {
  use App::StatusSkein::CLI::Client::Facebook;
  use App::StatusSkein::CLI::Client::Identica;
  use App::StatusSkein::CLI::Client::Twitter;

  has 'client' => (
    is         => 'ro' ,
    isa        => 'App::StatusSkein::CLI::Client' ,
    lazy_build => 1 ,
    handles    => [
      'add_fave' ,
      'del_fave' ,
      'get_post'  ,
      'get_posts' ,
      'recycle_post' ,
      'verify_credentials' ,
    ] ,
  );

  has 'client_args' => (
    is       => 'ro' ,
    isa      => 'HashRef' ,
    required => 1 ,
  );

  has 'name' => (
    is  => 'ro' ,
    isa => 'Str' ,
  );

  has 'type' => (
    is  => 'ro' ,
    isa => 'Str' ,
  );

  method _build_client {
    my $type_class = 'App::StatusSkein::CLI::Client::' . $self->type;
    my $args = $self->client_args;
    $args->{account_name} = $self->name;
    return $type_class->new( $args );
  };
}
