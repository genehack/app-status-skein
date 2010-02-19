package StatusShooter::Controller::Add;
use namespace::autoclean;

use Moose;
BEGIN { extends 'Catalyst::Controller' }

#use StatusShooter::Form::Add::Facebook;
#use StatusShooter::Form::Add::Idenitca;
use StatusShooter::Form::Add::Twitter;

has 'form' => (
  isa     => 'StatusShooter::Form::Add' ,
  is      => 'rw' ,
  lazy    => 1 ,
  default => sub { die 'tried to use form before initialization!' }
);

sub index :Path :Args(1) {
  my ( $self, $c , $service ) = @_;

  my $service_name = ucfirst( $service );
  my $class = "StatusShooter::Form::Add::$service_name";
  $self->form( $class->new );
  $self->form->action( $c->uri_for( "/add/$service" ));

  $c->stash(
    template => "add/$service.tt" ,
    form     => $self->form ,
  );

  if ( $self->form->process( params => $c->req->parameters )) {
    my $result = $self->form->value;

    $c->config->{"Model::$service_name"}{args}{username} = $result->{username};
    $c->config->{"Model::$service_name"}{args}{password} = $result->{password};

    eval { $c->model( $service_name )->get_posts };
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

    ### FIXME ->  write user/pass into _local.yaml
  }
}

1;
