use MooseX::Declare;

class StatusShooter::Post::Identica extends StatusShooter::Post {
  use DateTime;
  use Date::Parse;

  has 'retweeter' => (
    is     => 'ro' ,
    isa    => 'HashRef' ,
    writer => '_set_retweeter' ,
  );

  has '+can_be_favorited' => ( default => 1 );
  has '+can_be_recycled'  => ( default => 1 );
  has '+post'             => ( isa => 'HashRef' );
  has '+type'             => ( default => 'Identica' );

  method BUILD {
    if ( $self->post->{retweeted_status} ) {
      $self->_set_retweeter( $self->post->{user} );
      $self->post->{retweeted_status}{id} = $self->post->{id};
      $self->_set_post( $self->post->{retweeted_status} );
      $self->_set_text( $self->post->{text} );
    }

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

  method author       { return $self->post->{user}{name} }
  method avatar_src   { return $self->post->{user}{profile_image_url} }
  method favorited    { return $self->post->{favorited} }
  method id           { return $self->post->{id} }
  method in_reply_to  { return $self->post->{in_reply_to_screen_name} }
  method is_protected { return $self->post->{user}{protected} }
  method is_reply     { return $self->in_reply_to ? 1 : 0 }

  method permalink {
    return sprintf 'http://identi.ca/notice/%s' , $self->id;
  }

  method reply_permalink {
    return sprintf 'http://identi.ca/notice/%s' , $self->post->{in_reply_to_status_id};
  }

  method retweeter_url { return sprintf 'http://identi.ca/%s' , $self->retweeter->{screen_name} }
  method user_desc   { return $self->post->{user}{description} }
  method user_handle { return $self->post->{user}{screen_name} }
  method user_url    { return sprintf 'http://identi.ca/%s' , $self->user_handle }
}
