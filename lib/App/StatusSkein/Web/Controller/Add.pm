package App::StatusSkein::Web::Controller::Add;
use namespace::autoclean;

use Moose;
BEGIN { extends 'Catalyst::Controller' }

#use App::StatusSkein::Web::Form::Add::Facebook;
#use App::StatusSkein::Web::Form::Add::Idenitca;
use App::StatusSkein::Web::Form::Add::Twitter;

has 'form' => (
  isa     => 'App::StatusSkein::Web::Form::Add' ,
  is      => 'rw' ,
  lazy    => 1 ,
  default => sub { die 'tried to use form before initialization!' }
);

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
