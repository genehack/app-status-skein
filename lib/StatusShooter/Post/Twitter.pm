use MooseX::Declare;

class StatusShooter::Post::Twitter extends StatusShooter::Post {

  has '+post' => ( isa => 'Object' );

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
  method id          { return $self->post->id }
  method permalink   {
    return sprintf 'http://twitter.com/%s/status/%s' ,
      $self->user_handle , $self->post->id
  }

  method user_desc   { return $self->post->user->description }
  method user_handle { return $self->post->user->screen_name }
  method user_url    { return sprintf 'http://twitter.com/%s' , $self->user_handle }
}
