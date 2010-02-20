use MooseX::Declare;
class App::StatusSkein::CLI::Client {
  has fave_add_method => (
    is      => 'ro' ,
    isa     => 'Str',
    default => 'create_favorite' ,
  );

  has fave_del_method => (
    is      => 'ro' ,
    isa     => 'Str',
    default => 'destroy_favorite' ,
  );

  has 'type' => (
    is  => 'ro' ,
    isa => 'Str' ,
  );

  method get_post ( $id ) {
    my $post;
    eval { $post = $self->show_status( $id ) };
    die $@ if $@;

    my $post_class = $self->post_class;
    return $post_class->new({ post => $post });
  }

  method get_posts ( Num :$since ) {
    my $posts;
    eval { $posts = $self->_client->home_timeline() };
    if ( my $err = $@ ) {
      die $@ unless blessed $err and $err->isa('Net::Twitter::Error');

      # bail on the fail whale
      return [] if $err->code eq '502';

      die $err;
    }

    my $post_class = $self->post_class;
    return [ map { $post_class->new({ post => $_ }) }
               grep { $_->created_at->epoch >= $since } @$posts ];
  };

  method post_class { return sprintf "App::StatusSkein::CLI::Post::%s" , $self->type }
}
