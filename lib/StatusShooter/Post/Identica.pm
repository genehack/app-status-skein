use MooseX::Declare;

class StatusShooter::Post::Identica extends StatusShooter::Post {
  use DateTime;
  use Date::Parse;

  has '+post' => ( isa => 'HashRef' );

  method BUILD {
    my $text = $self->text;

    $text =~ s|\@(\S+)|<a target="_new" href="http://identi.ca/$1">\@$1</a>|g;
    $text =~ s|\#(\S+)|<a target="_new" href="http://identi.ca/tag/$1">#$1</a>|g;
    $text =~ s|\!(\S+)|<a target="_new" href="http://identi.ca/group/$1">!$1</a>|g;

    $self->_set_text( $text );
  }

  # lazy builder for 'date' attr, declared in base class
  method _build_date {
    my $epoch = str2time( $self->post->{created_at} );
    my $dt = DateTime->from_epoch( epoch => $epoch );
    $dt->set_time_zone( 'local' );
    return $dt;
  }

  # lazy builder for 'text' attr, declared in base class
  method _build_text { return $self->post->{text} }

  method author      { return $self->post->{user}{name} }
  method avatar_src  { return $self->post->{user}{profile_image_url} }
  method favorited   { return $self->post->{favorited} }
  method id          { return $self->post->{id} }
  method permalink   {
    return sprintf 'http://identi.ca/%s/notice/%s' ,
      $self->user_handle , $self->id
  }

  method reply_btn   {
    my $author = $self->user_handle;
    my $id     = $self->id;

    return <<EOHTML;
<a href=# onclick="identica_reply('\@$author','$id')">Reply</a>
EOHTML
    }

  method user_desc   { return $self->post->{user}{description} }
  method user_handle { return $self->post->{user}{screen_name} }
  method user_url    { return sprintf 'http://identi.ca/%s' , $self->user_handle }
}
