use MooseX::Declare;

class StatusShooter::Post::Twitter extends StatusShooter::Post {

  has '+can_be_favorited' => ( default => 1 );
  has '+can_be_recycled'  => ( default => 1 );
  has '+post'             => ( isa => 'Object' );
  has '+type'             => ( default => 'Twitter' );

  method BUILD {
    my $text = $self->text;

    $text =~ s|\@(\S+)|<a target="_new" href="http://twitter.com/$1">\@$1</a>|g;
    $text =~ s|\#(\S+)|<a target="_new" href="http://twitter.com/#search?q=%23$1">#$1</a>|g;

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

  method author      { return $self->post->user->name }
  method avatar_src  { return $self->post->user->profile_image_url }
  method favorited   { return $self->post->favorited }
  method id          { return $self->post->id }
  method is_protected { return $self->post->user->protected }
  method permalink   {
    return sprintf 'http://twitter.com/%s/status/%s' ,
      $self->user_handle , $self->id
  }

  method reply_btn   {
    my $author = $self->user_handle;
    my $id     = $self->id;

    return <<EOHTML;
<a href=# class=reply_btn onclick="twitter_reply('\@$author','$id')">Reply</a>
EOHTML
  }

  method user_desc   { return $self->post->user->description }
  method user_handle { return $self->post->user->screen_name }
  method user_url    { return sprintf 'http://twitter.com/%s' , $self->user_handle }
}
