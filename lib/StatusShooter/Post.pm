use MooseX::Declare;
class StatusShooter::Post {
  has 'can_be_favorited' => (
    is      => 'ro' ,
    isa     => 'Bool' ,
    default => 0
  );

  has date => (
    is         => 'ro' ,
    isa        => 'DateTime' ,
    lazy_build => 1 ,
  );

  has post => (
    is       => 'ro' ,
    required => 1 ,
  );

  has text => (
    is         => 'ro' ,
    isa        => 'Str' ,
    lazy_build => 1 ,
    writer     => '_set_text' ,
  );

  has 'type' => (
    is  => 'ro' ,
    isa => 'Str'
  );

  method BUILD {
    my $text = $self->text;

    $text =~ s|(http://\S+)|<a target="_new" href="$1">$1</a>|g;

    $self->_set_text( $text );
  }

  method pretty_date { return $self->date->strftime( '%H:%M:%S %a %d %b %Y' ) }

}
