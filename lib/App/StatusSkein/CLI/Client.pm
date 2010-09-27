use MooseX::Declare;
class App::StatusSkein::CLI::Client {
  has 'account_name' => (
    is       => 'ro' ,
    isa      => 'Str' ,
    required => 1 ,
  );

  has 'type' => (
    is       => 'ro' ,
    isa      => 'Str' ,
    required => 1 ,
  );

  method get_post ( Str $id ) {
    my $post;
    eval { $post = $self->show_status( $id ) };
    die $@ if $@;

    my $post_class = $self->post_class;
    return $post_class->new({ post => $post , account_name => $self->account_name });
  };

  method get_posts ( Num :$since ) {
    my $posts;
    eval { $posts = $self->_client->home_timeline() };
    if ( my $err = $@ ) {
      die $@ unless blessed $err and $err->isa('Net::Twitter::Error');

      # bail on the fail whale
      return [] if $err->code eq '502';

      die $err;
    }

    $posts = $self->filter_posts( since => $since , posts => $posts );

    my $post_class = $self->post_class;
    return [ map {
      $post_class->new({ post => $_ , account_name => $self->account_name })
    } @$posts ];
  };

  method filter_posts ( Num :$since , ArrayRef :$posts ) {
    return [ grep { defined $_ && $_->can('created_at') && $_->created_at->epoch >= $since } @$posts ];
  };

  method post_class { return sprintf "App::StatusSkein::CLI::Post::%s" , $self->type };

  method post_new_status ( HashRef $args ) { $self->update( $args ) };

  method recycle_post ( Str $id ) { die "not supported on this client" };
}
