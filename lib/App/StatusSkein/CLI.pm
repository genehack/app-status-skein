use MooseX::Declare;

class App::StatusSkein::CLI {
  use Moose::Util::TypeConstraints;
  use YAML qw/ Load /;

  has clients => (
    is         => 'ro' ,
    isa        => 'Array[App::StatusSkein::CLI::Client]' ,
    lazy_build => 1 ,
  );

  has config  => (
    is         => 'rw' ,
    isa        => 'HashRef' ,
    lazy_build => 1 ,
  );

  subtype 'App::StatusSkein::ConfigFile' => as class_type 'Path::Class::File';

  coerce 'App::StatusSkein::ConfigFile'
    => from 'Str'
      => via { Path::Class::File->new( $_ ) };

  has config_file => (
    is       => 'ro' ,
    isa      => 'App::StatusSkein::ConfigFile' ,
    coerce   => 1 ,
    required => 1 ,
  );

  method _build_config { return Load( $self->config_file->slurp ); };

  method _build_clients {
    my @clients;
    foreach ( $self->config->{accounts} ) {
      my $type = 'App::StatusSkein::CLI::Client::' . $_->{type};
      push @clients , $type->new( $_ );
    }
    return \@clients;
  };

  method add_acount ( HashRef $account ){

  };

  method delete_accounts {};

  method get_accounts {};

  method get_all_posts {};

  method get_post {};

  method post_new_status {};

  method recycle_post {};

  method reload_accounts {};

  method reply_to_post {};

  method toggle_favorite {};

}

