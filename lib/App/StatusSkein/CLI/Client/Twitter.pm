# PODNAME: App::StatusSkein::CLI::Client::Twitter
use MooseX::Declare;

class App::StatusSkein::CLI::Client::Twitter extends App::StatusSkein::CLI::Client {
  use Net::Twitter;
  use App::StatusSkein::CLI::Post::Twitter;

  has '_client' => (
    is         => 'ro' ,
    isa        => 'Net::Twitter' ,
    handles    => [
      'create_favorite' ,
      'destroy_favorite' ,
      'get_authorization_url' ,
      'request_access_token' ,
      'request_token' ,
      'request_token_secret' ,
      'retweet' ,
      'show_status' ,
      'update' ,
      'verify_credentials' ,
    ] ,
    lazy_build => 1 ,
  );

  has traits => (
    is       => 'ro' ,
    isa      => 'ArrayRef' ,
    required => 1 ,
    default  => sub { [ qw/ API::REST OAuth InflateObjects / ] }
  );

  has access_token => (
    is => 'ro' ,
    isa => 'Str',
  );

  has access_token_secret => (
    is => 'ro' ,
    isa => 'Str' ,
  );

  has consumer_key => ( is => 'ro' , default => '1c4qi8rmSJg9bcKZMn22Hg' );
  has consumer_secret => ( is => 'ro' , default => 'nc6TJuYtjvKhuRiPVOrWkRpq1bOLe6BA90q2doSuLgs');

  has '+type' => ( default => 'Twitter' );

  method _build__client {
    my $client = Net::Twitter->new(
      traits          => $self->traits ,
      consumer_key    => $self->consumer_key ,
      consumer_secret => $self->consumer_secret ,
    );
    $client->access_token( $self->access_token ) if $self->access_token;
    $client->access_token_secret( $self->access_token_secret )
      if $self->access_token_secret;

    return $client;

  };

  method add_fave ( Str $id ) { $self->create_favorite( $id ) };
  method del_fave ( Str $id ) { $self->destroy_favorite( $id ) };

  ### FIXME this can't work as things currently are because we don't know the
  ### screen name of the account...
  # after filter_posts ( Num :$since , ArrayRef :$posts ) {
  #   return [ grep {
  #     defined $_ &&
  #     $_->can('retweeter') &&
  #     $_->retweeter->screen_name eq $account->screen_name
  #   } @$posts ];
  # };

  method recycle_post ( Str $id ) { $self->retweet( $id ) };
}
