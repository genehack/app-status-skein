use MooseX::Declare;
class StatusShooter::Post::Facebook extends StatusShooter::Post {
  use DateTime;

  has '+post' => ( isa => 'HashRef' );

  has profile => (
    is       => 'ro' ,
    isa      => 'HashRef' ,
    required => 1 ,
  );

  method author { return $self->profile->{name} }
  method date   { return DateTime->from_epoch( epoch => $self->post->{created_time} ) }
  method text   { return $self->post->{message} }
}
