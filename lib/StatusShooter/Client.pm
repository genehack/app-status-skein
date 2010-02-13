use MooseX::Declare;
class StatusShooter::Client {
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

  method get_posts {
    my $posts;
    eval { $posts = $self->_client->home_timeline };
    die $@ if $@;

    my $post_class = $self->post_class;
    return [ map { $post_class->new({ post => $_ }) } @$posts ];
  }

  method post_class { return sprintf "StatusShooter::Post::%s" , $self->type }
}
