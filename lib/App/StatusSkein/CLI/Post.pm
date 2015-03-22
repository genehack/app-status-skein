# PODNAME: App::StatusSkein::CLI::Post
use utf8;
use MooseX::Declare;
class App::StatusSkein::CLI::Post {
  has account_name => (
    is       => 'ro' ,
    isa      => 'Str' ,
    required => 1 ,
  );

  has 'can_be_favorited' => (
    is      => 'ro' ,
    isa     => 'Bool' ,
    default => 0
  );

  has 'can_be_recycled' => (
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
    writer   => '_set_post' ,
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

  method linkify_text ( Str $text ) {
    use HTTP::Tiny;
    use URI::Find;

    my $finder = URI::Find->new( sub {
      my( $url , $text ) = shift;
      my $link = my $target = $url->as_string;
      if ( $link =~ /t\.co/ ) {
        ### FIXME should probably have a timeout or something, and do this in
        ### a try/catch
        my $r = HTTP::Tiny->new(max_redirect => 0 )->get($link);
        $link = $r->{headers}{location} if $r->{headers}{location};
        $target = length $link > 50 ? substr( $link , 0 , 45 ) . '…' : $link;
      }
      return qq|<a href=$link target=_blank>$target</a>|;
    });
    $finder->find( \$text );

    return $text;
  }

  method pretty_date { return $self->date->strftime( '%H:%M:%S %a %d %b %Y' ) }

}
