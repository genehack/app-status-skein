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

  $c->stash( message => $c->flash->{message} ) if $c->flash->{message};

  $c->stash(
    template => 'index.tt' ,
    form     => $self->form ,
  );

  $self->form->action( $c->uri_for( 'post' ));

  my $fb_posts = $c->model( 'Facebook' )->get_posts();
  my $tweets   = $c->model( 'Twitter'  )->get_posts();
  my $identica = $c->model( 'Identica' )->get_posts();

  my @posts = sort { $b->date <=> $a->date } @$fb_posts , @$tweets , @$identica ;
  $c->stash( posts => \@posts );
}

sub post :Local :Args(0) {
  my( $self , $c ) = @_;

  if ( $self->form->process( params => $c->req->parameters )) {
    my $result = $self->form->value;

    my %services = map { $_ => 1 } @{ $result->{services} };

    ### FIXME all the interaction with services should be handled by model classes...
    if ( $services{blog} ) {
      my $post = _post_on_blog( $result );

      _post_note_to_facebook( $post , $result )            if( $services{facebook} );
      _post_blog_post_title_to_twitter( $post , $result )  if( $services{twitter}  );
      _post_blog_post_title_to_identica( $post , $result ) if( $services{identica} );
    }
    else {
      if ( $services{facebook} ) {
        $c->model('Facebook')->status->set( status => $result->{status} );
      }

      if ( $services{identica} ) {
        eval { $c->model( 'Identica' )->update( $result->{status} ) };
        die $@ if ( $@ );
      }

      if ( $services{twitter} ) {
        my $args = { status => $result->{status} };
        $args->{in_reply_to_status_id} = $result->{twitter_in_reply_to}
          if $result->{twitter_in_reply_to};
        eval { $c->model('Twitter')->update( $args ) };
        if ( $@ ) {
          return $c->stash( message => $@ );
        }
      }
    }

    $self->form->clear_data;
    $c->flash->{message} = "Posted";
  }
  $c->response->redirect( $c->uri_for_action( 'index' ));
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

sub _post_blog_post_title_to_identica {
  my( $post , $result ) = @_;
}

sub _post_note_to_facebook {
  my( $post , $result ) = @_;
}

sub _post_on_blog {
  my( $result ) = @_;
}

1;
