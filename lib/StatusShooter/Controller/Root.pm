package StatusShooter::Controller::Root;
use namespace::autoclean;

use Moose;
BEGIN { extends 'Catalyst::Controller' }

use StatusShooter::Form::Update;

__PACKAGE__->config->{namespace} = '';

has 'form' => (
  isa     => 'StatusShooter::Form::Update' ,
  is      => 'rw' ,
  lazy    => 1 ,
  default => sub { StatusShooter::Form::Update->new }
);

sub index :Path :Args(0) {
  my ( $self, $c ) = @_;

  $c->stash(
    template => 'index.tt' ,
    form     => $self->form ,
  );

  if( $self->form->process( params => $c->req->parameters )) {
    my $result = $self->form->value;

    my %services = map { $_ => 1 } @{ $result->{services} };

    ### FIXME all the interaction with services should be handled by model classes...

    if ( $services{blog} ) {
      my $post = _post_on_blog( $result );

      _post_note_to_facebook( $post , $result )           if ( $services{facebook} );
      _post_blog_post_title_to_twitter( $post , $result ) if ( $services{twitter}  );
    }
    else {
      _post_status_to_facebook( $result ) if ( $services{facebook} );
      _post_status_to_twitter( $result )  if ( $services{twitter}  );
    }

    $c->stash(
      message => "Posted" ,
      form    => StatusShooter::Form::Update->new ,
    );
  }
}

sub default :Path {
  my ( $self, $c ) = @_;
  $c->response->body( 'Page not found' );
  $c->response->status(404);
}

sub end : ActionClass('RenderView') {}

sub _post_blog_post_title_to_twitter {
  my( $post , $result ) = @_;
}

sub _post_note_to_facebook {
  my( $post , $result ) = @_;
}

sub _post_on_blog {
  my( $result ) = @_;
}

sub _post_status_to_facebook {
  my( $result ) = @_;
}

sub _post_status_to_twitter {
  my( $result ) = @_;
}

1;
