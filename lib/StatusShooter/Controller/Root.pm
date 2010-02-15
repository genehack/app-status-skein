package StatusShooter::Controller::Root;
use namespace::autoclean;

use Moose;
BEGIN { extends 'Catalyst::Controller' }

use Data::Dumper;
use Data::Dumper::HTML             qw/ dumper_html /;
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

  my $new_time = time();
  my $old_time = $c->session->{time} || 0;

  if ( $old_time and $new_time - $old_time < 60 ) {
    $c->stash( message => 'Less than 60 seconds since last page load! Wait longer!' );
    return;
  }

  my $twitter_max  = $c->session->{twitter_max}  || 0;
  my $identica_max = $c->session->{identica_max} || 0;

  my $fb_posts = $c->model( 'Facebook' )->get_posts( start_time => $old_time     );
  my $tweets   = $c->model( 'Twitter'  )->get_posts( max_id     => $twitter_max  );
  my $identica = $c->model( 'Identica' )->get_posts( max_id     => $identica_max );

  $c->session->{time} = $new_time;

  my $new_twitter_max = _find_max_id( $tweets );
  $c->session->{twitter_max}  = $new_twitter_max if $new_twitter_max;

  my $new_identica_max = _find_max_id( $identica );
  $c->session->{identica_max} = $new_identica_max if $new_identica_max;

  my @posts = sort { $a->date <=> $b->date } @$fb_posts , @$tweets , @$identica ;
  $c->stash( posts => \@posts );
}

sub _find_max_id {
  my $array_ref = shift;

  my $max = 0;

  foreach ( @$array_ref ) {
    $max = $_->id if ($_->id > $max );
  }

  return $max;
}

sub inspect :Local :Args(2) {
  my( $self , $c , $type , $id ) = @_;

  my $status = $c->model( $type )->get_post( $id );

  $c->response->body( dumper_html( $status->{post} ));
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
        my $args = { status => $result->{status} };
        $args->{in_reply_to_status_id} = $result->{identica_in_reply_to}
          if $result->{identica_in_reply_to};
        eval { $c->model( 'Identica' )->update( $args ) };
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

sub toggle_fave :Local :Args(2) {
  my( $self , $c , $type , $id  ) = @_;

  my $message;
  eval {
    my $model  = $c->model( $type );
    my $status = $model->get_post( $id );

    my $method = $status->favorited ? $model->fave_del_method : $model->fave_add_method;
    $message = $status->favorited ? 'Favorite removed' : 'Favorite added';
    $c->model( $type )->$method( $id );
  };
  die $@ if $@;

  $c->flash->{message} = $message;
  $c->response->redirect( $c->uri_for_action( 'index' ));
}

sub toggle_recycle :Local :Args(2) {
  my( $self , $c , $type , $id  ) = @_;

  my $message;
  eval {
    my $status = $c->model( $type )->get_post( $id );

    $c->model( $type )->retweet( $id );
  };
  if ( my $err = $@ ) {
    die $@ unless blessed $err and $err->isa('Net::Twitter::Error');
    if ( $err->twitter_error->errors eq 'Share sharing is not permissable for this status' ) {
      $c->flash->{message} = 'Already recycled that one...';
    }
    else { die Dumper $err }
  }
  else { $c->flash->{message} = 'Recycled' }

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
