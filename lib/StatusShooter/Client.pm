use MooseX::Declare;
class StatusShooter::Client {
  has 'type' => (
    is  => 'ro' ,
    isa => 'Str' ,
  );
}
