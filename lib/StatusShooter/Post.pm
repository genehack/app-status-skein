use MooseX::Declare;
class StatusShooter::Post {
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

  method BUILD {
    my $text = $self->text;

    $text =~ s|(http://\S+)|<a target="_new" href="$1">$1</a>|g;
    $text =~ s|\@(\S+)|<a target="_new" href="http://twitter.com/$1">\@$1</a>|g;
    $text =~ s|\#(\S+)|<a target="_new" href="http://twitter.com/#search?q=%23$1">#$1</a>|g;

    $self->_set_text( $text );
  }

  method pretty_date { return $self->date->strftime( '%H:%M:%S %a %d %b %Y' ) }

}
