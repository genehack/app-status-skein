package App::StatusSkein::Web::Controller::Add;
use namespace::autoclean;

use Moose;
BEGIN { extends 'Catalyst::Controller' }

use App::StatusSkein::Web::Form::Add::Facebook;
use App::StatusSkein::Web::Form::Add::Identica;
use App::StatusSkein::Web::Form::Add::Twitter;
use LWP::Simple;
use WWW::Facebook::API;

has 'form' => (
  isa     => 'App::StatusSkein::Web::Form::Add' ,
  is      => 'rw' ,
  lazy    => 1 ,
  default => sub { die 'tried to use form before initialization!' }
);

sub facebook :Local {
  my( $self , $c ) = @_;

  $self->form( App::StatusSkein::Web::Form::Add::Facebook->new );
  $self->form->action( $c->uri_for( "/add/facebook" ));

  my $api_key = $c->config->{facebook_api_key};

  my $fb_url = get( "http://genehack.org/statusskein/session_url.cgi?api_key=$api_key" );

  $c->stash(
    template => "add/facebook.tt" ,
    fb_url   => $fb_url ,
    form     => $self->form ,
  );

  if ( $self->form->process( params => $c->req->parameters )) {
    my $result = $self->form->value;
    my $token  = $result->{token};

    my $session_info = get( "http://genehack.org/statusskein/token2session.cgi?api_key=$api_key&token=$token" );

    if ( $session_info eq 'ERROR' ) {
      $c->stash( message => 'Token validation failed' );
      return;
    }

    my( $key , $secret ) = split /\n/ , $session_info;

    my $name = "facebook-" . $key;

    my $account = {
      api_key     => $api_key ,
      session_key => $key ,
      secret      => $secret ,
      type        => $result->{type} ,
    };

    $c->model( 'CLI' )->add_account( $name => $account );

    my $perms_url  = 'http://www.facebook.com/connect/prompt_permissions.php';
    $perms_url    .= "?api_key=$api_key&fbconnect=true&v=1.0&display=popup&extern=1";
    $perms_url    .= "&next=http://www.facebook.com/connect/login_success.html?xxRESULTTOKENxx";
    $perms_url    .= "&ext_perm=read_stream,publish_stream";

    $c->stash(
      template  => 'add/facebook2.tt' ,
      perms_url => $perms_url ,
    );
  }
};

sub index :Path {
  my ( $self, $c , $service ) = @_;

  unless ( $service ) {
    $c->stash( template => 'add.tt' );
    return;
  }

  my $service_name = ucfirst( $service );
  my $class = "App::StatusSkein::Web::Form::Add::$service_name";
  $self->form( $class->new );
  $self->form->action( $c->uri_for( "/add/$service" ));

  $c->stash(
    template => "add/$service.tt" ,
    form     => $self->form ,
  );

  if ( $self->form->process( params => $c->req->parameters )) {
    my $result = $self->form->value;

    eval { $c->model( 'CLI' )->test_account( $service_name => $result ) };
    if ( my $err = $@ ) {
      use Scalar::Util qw/ blessed /;
      die "UNHOLY $err" unless blessed $err;
      die ref $err unless $err->isa( 'Net::Twitter::Error' );

      if ( $err->error eq 'Could not authenticate you.' ) {
        $c->stash( message => 'Authentication failed.' );
        return;
      }
      else { die $err; }
    }

    my $account_name = sprintf "%s-%s" , $service , $result->{username};

    $c->model( 'CLI' )->add_account( $account_name => $result );

    $c->response->redirect( $c->uri_for( '/' ));
  }
};

1;
