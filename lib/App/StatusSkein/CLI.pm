use MooseX::Declare;

class App::StatusSkein::CLI {
  use App::StatusSkein::CLI::Client::Twitter;
  use Moose::Util::TypeConstraints;
  use Path::Class::File;
  use YAML qw/ DumpFile Load /;

  has clients => (
    is         => 'ro' ,
    isa        => 'ArrayRef[App::StatusSkein::CLI::Client]' ,
    lazy_build => 1 ,
    writer     => '_set_clients' ,
  );

  has config  => (
    is         => 'rw' ,
    isa        => 'HashRef' ,
    lazy_build => 1 ,
    writer     => '_set_config' ,
  );

  subtype 'App::StatusSkein::ConfigFile'
    => as class_type 'Path::Class::File';

  coerce 'App::StatusSkein::ConfigFile'
    => from 'Str'
      => via { Path::Class::File->new( $_ ) };

  has config_file => (
    is       => 'ro' ,
    isa      => 'App::StatusSkein::ConfigFile' ,
    coerce   => 1 ,
    required => 1 ,
  );

  method _build_config {
    my $config = {};

    eval {
      my $contents = $self->config_file->slurp;
      $config = Load( $contents );
    };

    return $config;
  };

  method _build_clients {
    my @clients  = ();
    my $accounts = $self->get_accounts;
    foreach ( keys %$accounts ) {
      my $type = 'App::StatusSkein::CLI::Client::' . $accounts->{$_}{type};
      push @clients , $type->new( $accounts->{$_} );
    }
    return \@clients;
  };

  method add_account ( Str $name , HashRef $account ) {
    $self->config->{accounts}{$name} = $account;
    $self->write_config_and_reload;
  };

  method delete_account ( Str $account_name ) {
    delete $self->config->{accounts}{$account_name};
    $self->write_config_and_reload;
  };

  method get_accounts { return $self->config->{accounts} };

  method get_all_posts {};

  method get_post {};

  method post_new_status {};

  method recycle_post {};

  method reload_accounts { $self->_set_clients( $self->_build_clients ) };

  method reply_to_post {};

  method test_account ( Str $name , HashRef $account ) {
    my $client_class = "App::StatusSkein::CLI::Client::$name";
    my $client = $client_class->new( $account );
    return $client->verify_credentials;
  };

  method toggle_favorite {};

  method write_config_and_reload {
    DumpFile( $self->config_file , $self->config );
    $self->_set_config( $self->_build_config );
    $self->reload_accounts;
  };

}

