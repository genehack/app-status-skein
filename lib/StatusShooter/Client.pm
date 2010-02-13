use MooseX::Declare;
class StatusShooter::Client {
  has 'type' => (
    is  => 'ro' ,
    isa => 'Str' ,
  );

  method post_class { return sprintf "StatusShooter::Post::%s" , $self->type }
}
