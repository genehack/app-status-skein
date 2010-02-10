package StatusShooter::Form::Update;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';
with 'HTML::FormHandler::Render::Simple';

has_field 'status' => (
  type             => 'Text' ,
  label            => 'Status' ,
  required         => 1 ,
  required_message => 'You must enter a status' ,
  size             => 140 ,
  maxlength        => 140 ,
);

has_field 'services' => (
  type             => 'Multiple' ,
  widget           => 'CheckboxGroup' ,
  required         => 1 ,
  required_message => 'You must select one or more services' ,
);

sub options_services {[
  twitter  => 'Twitter' ,
  facebook => 'Facebook' ,
  blog     => 'blog' ,
]}

has_field 'submit' => (
  type  => 'Submit' ,
  value => 'Post' ,
);

has_field 'body' => (
  type  => 'TextArea' ,
  label => '' ,
  rows  => 20 ,
  cols  => 80 ,
);

has_field 'tags' => (
  type  => 'Text' ,
  label => 'Tags' ,
  size  => 100 ,
);

sub validate {
  my $self = shift;

  # these validations are only relevant if one or more services are checked...
  if ( my $value = $self->field( 'services' )->value ) {
    ref $value or $value = [ $value ];
    my %services = map { $_ => 1 } @$value;

    # if we're posting to a weblog, we need a post body
    if ( $services{blog} ) {
      unless ( $self->field( 'body' )->value ) {
        $self->field( 'body' )->add_error( 'Posting to weblog requires post body!' );
      }
    }

    # conversely, if we're not posting to a weblog, we shouldn't have a body or tags
    else {
      if ( $self->field( 'body' )->value or $self->field( 'tags' )->value ) {
        $self->field( 'body' )->add_error( 'If you want to post body text or tags, make sure to select the \'blog\' service' );
      }
    }
  }
}


no HTML::FormHandler::Moose;
1;
