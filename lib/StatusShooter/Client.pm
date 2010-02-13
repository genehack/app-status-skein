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

  method post_class { return sprintf "StatusShooter::Post::%s" , $self->type }
}
