use MooseX::Declare;
class StatusShooter::Post::Twitter extends StatusShooter::Post {

  has post => (
    isa     => 'Object' ,
    handles => {
      text => 'text' ,
      date => 'created_at' ,
    } ,
  );

  method author { return $self->post->user->name }
}
