package StatusShooter::Controller::Root;
use Moose;
BEGIN { extends 'Catalyst::Controller' }

use StatusShooter::Form::Update;

__PACKAGE__->config->{namespace} = '';

has 'form' => (
  isa => 'StatusShooter::Form::Update' , is => 'rw' , lazy => 1 ,
  default => sub { StatusShooter::Form::Update->new }
);

sub index :Path :Args(0) {
  my ( $self, $c ) = @_;

  $c->stash(
    template => 'index.tt' ,
    form     => $self->form ,
    message  => 'Not Valid' ,
  );

  return unless $self->form->process( params => $c->req->parameters );

  my $result = $self->form->value;

  my %services = map { $_ => 1 } @{ $result->{services} };

  my $body;

  if ( $services{blog} ) {
    $body .= "Post to blog\n";
    if ( $services{facebook} ) {
      $body .= "Post note on facebook\n";
    }
    if ( $services{twitter} ) {
      $body .= "Post blog post title to twitter\n";
    }
  }
  else {
    if ( $services{facebook} ) {
      $body .= "Post status to Facebook\n";
    }

    if ( $services{twitter} ) {
      $body .= "Post status to Twitter\n";
    }
  }

  $c->log->info( $body );
  $c->response->body( $body );

}

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

sub end : ActionClass('RenderView') {}

1;
