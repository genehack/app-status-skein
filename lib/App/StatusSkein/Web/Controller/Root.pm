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

  $c->session->{time} = 1;

  $c->stash( message => $c->flash->{message} ) if $c->flash->{message};

  $c->stash(
    template => 'index.tt' ,
    form     => $self->form ,
  );

  $self->form->action( $c->uri_for( 'post' ));

  my $account_checkbox_options = [ map {
    { value => $_->name , label => $_->type }
  } sort { $a->type cmp $b->type } @$accounts ];

  $self->form->field( 'accounts' )->options( $account_checkbox_options );
}

sub inspect :Local :Args(2) {
  my( $self , $c , $name , $id ) = @_;

  my $status = $c->model( 'CLI' )->get_post( $name , $id );
  my $text   = $status->text;
  my $body   =  "TEXT: $text\n\n" . Dumper( $status->{post} );

  $c->response->content_type( 'text/plain' );
  $c->response->body( $body );
}

sub new_posts :Local {
  my( $self , $c , $force ) = @_;

  $force ||= 0;

  my $new_time = time();
  my $old_time = $c->session->{time} || 0;

  my $posts = $c->model( 'CLI' )->get_all_posts( since => $old_time , force => $force );

  $c->session->{time} = $new_time;

  my @posts = sort { $a->date <=> $b->date } @$posts;

  $c->stash(
    posts    => \@posts ,
    template => 'new_posts.tt' ,
  );
}

sub post :Local :Args(0) {
  my( $self , $c ) = @_;

  my $form = $self->form;
  my $accounts = $c->model( 'CLI' )->accounts;
  my $account_checkbox_options = [ map {
    { value => $_->name , label => $_->type }
  } sort { $a->type cmp $b->type } @$accounts ];

  $self->form->field( 'accounts' )->options( $account_checkbox_options );

  my $response = {};

  if ( $form->process( params => $c->req->parameters )) {
    my $result = $form->value;

    my $args = { status => $result->{status} };
    $args->{in_reply_to_status_id} = $result->{in_reply_to} if $result->{in_reply_to};

    foreach ( @{ $result->{accounts} } ) {
      $c->model( 'CLI' )->post_new_status( $_ , $args );
    }

    $response = {
      message => '<h2>Posted</h2>' ,
      success => 1 ,
    };
  }
  else {
    my $message;
    foreach my $field ( $form->error_fields ) {
      foreach my $error ( @{ $field->errors }) {
        $message .= qq|<h2 class="error">$error</h2>|;
      }
    }
    $response = {
      message => $message ,
      success => 0 ,
    };
  }

  $c->stash(
    current_view  => 'JSON' ,
    json_response => $response ,
  );
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
