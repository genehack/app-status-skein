use MooseX::Declare;

class App::StatusSkein::CLI {
  use App::StatusSkein::CLI::Account;
  use List::Util                      qw/ first /;
  use Moose::Util::TypeConstraints;
  use Path::Class::File;
  use YAML                            qw/ DumpFile Load /;

  subtype 'App::StatusSkein::ConfigFile'
    => as class_type 'Path::Class::File';

  coerce 'App::StatusSkein::ConfigFile'
    => from 'Str'
      => via { Path::Class::File->new( $_ ) };

  has accounts => (
    is         => 'ro' ,
    isa        => 'ArrayRef[App::StatusSkein::CLI::Account]' ,
    lazy_build => 1 ,
    writer     => '_set_accounts' ,
  );

  has config  => (
    is         => 'rw' ,
    isa        => 'HashRef' ,
    lazy_build => 1 ,
    writer     => '_set_config' ,
  );

  has config_file => (
    is       => 'ro' ,
    isa      => 'App::StatusSkein::ConfigFile' ,
    coerce   => 1 ,
    required => 1 ,
  );

  method _build_accounts {
    my @account_list = ();

    while( my( $name , $config ) = ( each %{ $self->config->{accounts} } )) {
      my $args = {
        name        => $name ,
        type        => $config->{type} ,
        client_args => $config ,
      };
      push @account_list , App::StatusSkein::CLI::Account->new( $args );
    }
    return \@account_list;
  };

  method _build_config {
    my $config = {};

    eval {
      my $contents = $self->config_file->slurp;
      $config = Load( $contents );
    };

    return $config;
  };

  method add_account ( Str $name , HashRef $account ) {
    $account->{account_name} = $name;
    $self->config->{accounts}{$name} = $account;
    $self->write_config_and_reload;
  };

  method add_fave ( Str $account_name , Str $id ) {
    $self->get_account( $account_name )->add_fave( $id );
  };

  method del_fave ( Str $account_name , Str $id ) {
    $self->get_account( $account_name )->del_fave( $id );
  };

  method delete_account ( Str $account_name ) {
    delete $self->config->{accounts}{$account_name};
    $self->write_config_and_reload;
  };

  method get_account ( Str $name ) {
    return first { $_->name eq $name } @{ $self->accounts };
  };

  method get_all_posts ( Num :$since , Bool :$force ) {
    my $posts = [];

    return $posts if ( time() - $since < 60 ) and ! $force;

    foreach my $account ( @{ $self->accounts }) {
      push @$posts , @{ $account->get_posts( since => $since ) };
    }
    return $posts;
  };

  method get_post ( Str $account , Str $id ) {
    return $self->get_account( $account )->get_post( $id );
  };

  method post_new_status ( Str $account , HashRef $args ) {
    return $self->get_account( $account )->post_new_status( $args );
  };

  method recycle_post ( Str $account_name , Str $id ){
    return $self->get_account( $account_name )->recycle_post( $id );
  };

  method reload_accounts { $self->_set_accounts( $self->_build_accounts ) };

  method test_account ( Str $type , HashRef $client_args ) {
    my $account = App::StatusSkein::CLI::Account->new({
      name        => 'test' ,
      type        => $type  ,
      client_args => $client_args ,
    });
    return $account->verify_credentials;
  };

  method write_config_and_reload {
    DumpFile( $self->config_file , $self->config );
    chmod 0600 , $self->config_file;
    $self->_set_config( $self->_build_config );
    $self->reload_accounts;
  };
}
