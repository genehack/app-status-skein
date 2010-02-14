use MooseX::Declare;

class StatusShooter::Post::Facebook extends StatusShooter::Post {
  use DateTime;

  has '+post' => ( isa => 'HashRef' );
  has '+type' => ( default => 'Facebook' );

  has profile => (
    is       => 'ro' ,
    isa      => 'HashRef' ,
    required => 1 ,
  );

  # lazy builder for 'date' attr, declared in base class
  method _build_date {
    my $dt = DateTime->from_epoch( epoch => $self->post->{created_time} );
    $dt->set_time_zone( 'local' );
    return $dt;
  }

  # lazy builder for 'text' attr, declared in base class
  method _build_text { return $self->post->{message} }

  method author      { return $self->profile->{name} }
  method avatar_src  { return $self->profile->{pic_square} }
  method id          { return $self->post->{post_id} }
  method permalink   { return $self->post->{permalink} }

  method reply_btn   {
    return <<EOHTML;
<strike>REPLY</strike>
EOHTML
  }

  method user_desc   { return $self->author }
  method user_handle { return $self->profile->{name} }
  method user_url    { return $self->profile->{url} }
}
