use MooseX::Declare;

class App::StatusSkein::CLI::Post::Twitter extends App::StatusSkein::CLI::Post {

  has 'retweeter' => (
    is     => 'ro' ,
    isa    => 'Object' ,
    writer => '_set_retweeter' ,
  );

  has '+can_be_favorited' => ( default => 1 );
  has '+can_be_recycled'  => ( default => 1 );

  has '+post' => (
    isa => 'Object' ,
    handles => [
      'favorited' ,
      'id' ,
      'user' ,
    ] ,
  );

  has '+type' => ( default => 'Twitter' );

  method BUILD {
    if ( $self->post->{retweeted_status} ) {
      $self->_set_retweeter( $self->user );
      $self->post->{retweeted_status}{id} = $self->id;
      $self->_set_post( $self->post->{retweeted_status} );
      $self->_set_text( $self->post->text );
    }

    my $text = $self->text;

    $text =  $self->linkify_text( $text );
    $text =~ s|(\A\| )\@([_a-zA-Z0-9]+)|$1<a target=_blank href=http://twitter.com/$2>\@$2</a>|g;
    $text =~ s|(\A\| )\#(\S+)|$1<a target=_blank href="http://twitter.com/#search?q=%23$2">#$2</a>|g;

    $self->_set_text( $text );
  }

  # lazy builder for 'date' attr, declared in base class
  method _build_date {
    my $dt = $self->post->created_at;
    $dt->set_time_zone( 'local' );
    return $dt;
  }

  # lazy builder for 'text' attr, declared in base class
  method _build_text { return $self->post->text }

  method author       { return $self->user->name }
  method avatar_src   { return $self->user->profile_image_url }
  method in_reply_to  { return $self->post->in_reply_to_screen_name }
  method is_protected { return $self->user->protected }
  method is_reply     { return $self->in_reply_to ? 1 : 0 }

  method permalink {
    my $user = $self->retweeter ? $self->retweeter->screen_name : $self->user_handle;
    return sprintf 'http://twitter.com/%s/status/%s' , $user , $self->id
  }

  method reply_permalink {
    return sprintf 'http://twitter.com/%s/status/%s' ,
      $self->in_reply_to , $self->post->in_reply_to_status_id;
  }

  method retweeter_url { return sprintf 'http://twitter.com/%s' , $self->retweeter->screen_name }
  method user_desc     { return $self->user->description }
  method user_handle   { return $self->user->screen_name }
  method user_url      { return sprintf 'http://twitter.com/%s' , $self->user_handle }
}
