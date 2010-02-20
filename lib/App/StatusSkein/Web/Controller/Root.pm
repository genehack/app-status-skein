package App::StatusSkein::Web::Controller::Root;
use namespace::autoclean;

use Moose;
BEGIN { extends 'Catalyst::Controller' }

use Data::Dumper;
use Data::Dumper::HTML             qw/ dumper_html /;
use App::StatusSkein::Web::Form::Update;

__PACKAGE__->config->{namespace} = '';

has 'form' => (
  isa     => 'App::StatusSkein::Web::Form::Update' ,
  is      => 'rw' ,
  lazy    => 1 ,
  default => sub { App::StatusSkein::Web::Form::Update->new }
);

sub delete_session :Local :Args(0) {
  my( $self , $c ) = @_;

  $c->delete_session( 'user request' );
  $c->response->redirect( $c->uri_for_action( 'index' ));
}

sub index :Path :Args(0) {
  my ( $self, $c ) = @_;

  my $accounts = $c->model( 'CLI' )->accounts;

  unless ( @$accounts ) {
    $c->stash( template => 'initial_run.tt' );
    return;
  }

  $c->stash( message => $c->flash->{message} ) if $c->flash->{message};

  $c->stash(
    template => 'index.tt' ,
    form     => $self->form ,
  );

  $self->form->action( $c->uri_for( 'post' ));

  my $services = [ map {
    { value => $_->name , label => $_->type }
  } sort { $a->type cmp $b->type } @$accounts ];

  $self->form->field( 'services' )->options( $services );
}

sub inspect :Local :Args(2) {
  my( $self , $c , $name , $id ) = @_;

  my $status = $c->model( 'CLI' )->get_post( $name , $id );

  $c->response->body( dumper_html( $status->{post} ));
}

sub new_posts :Local :Args(0) {
  my( $self , $c ) = @_;

  my $old_time = $c->session->{time} || 0;

  my $posts = $c->model( 'CLI' )->get_all_posts( since => $old_time );

  $c->session->{time} = time();

  my @posts = sort { $a->date <=> $b->date } @$posts;

  $c->stash(
    posts    => \@posts ,
    template => 'new_posts.tt' ,
  );
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

  _reset_session_time_if_needed( $c );
  $c->response->redirect( $c->uri_for_action( 'index' ));
}

sub toggle_fave :Local :Args(2) {
  my( $self , $c , $account_name , $id  ) = @_;

  my $message;
  eval {
    my $post = $c->model( 'CLI' )->get_post( $account_name , $id );
    my $method = $post->favorited ? 'del_fave' : 'add_fave';
    $c->model( 'CLI' )->$method( $account_name , $id );
    $message = $post->favorited ? 'fave_off.png' : 'fave_on.png';
  };
  die $@ if $@;

  $c->response->body( $message );
}

sub recycle_post :Local :Args(2) {
  my( $self , $c , $account_name , $id  ) = @_;

  my $message;
  eval {
    my $status = $c->model( 'CLI' )->recycle_post( $account_name , $id );
  };
  if ( my $err = $@ ) {
    die $@ unless blessed $err and $err->isa('Net::Twitter::Error');
    if ( $err->twitter_error->errors eq 'Share sharing is not permissable for this status' ) {
      # this will just fade out the recycle button silently, which is the same thing...
      $c->response->body(1);
    }
    else { die Dumper $err }
  }
  else { $c->response->body(1) }
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

sub _reset_session_time_if_needed {
  my $c = shift;

  my $new_time = time();
  my $old_time = $c->session->{time} || 0;

  if ( $old_time and $new_time - $old_time < 60 ) {
    $c->session->{time} = $new_time - 61;
  }
}

1;
