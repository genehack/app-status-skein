package App::StatusSkein::Web::Form::Update;

use namespace::autoclean;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';
with 'HTML::FormHandler::Render::Simple';

has '+name' => ( default => 'statusskein' );

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

has_field 'identica_in_reply_to' => ( type => 'Hidden' );
has_field 'twitter_in_reply_to'  => ( type => 'Hidden' );

has_field 'submit' => (
  type  => 'Submit' ,
  value => 'Post' ,
);

1;
