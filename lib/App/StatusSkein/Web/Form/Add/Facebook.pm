package App::StatusSkein::Web::Form::Add::Facebook;

use namespace::autoclean;

use HTML::FormHandler::Moose;
extends 'App::StatusSkein::Web::Form::Add';
with 'HTML::FormHandler::Render::Simple';

has '+name' => ( default => 'add_facebook' );

has_field 'token' => (
  type             => 'Text' ,
  label            => 'Token' ,
  required         => 1 ,
  required_message => 'You must enter a token' ,
  size             => 12 ,
);

has_field 'type' => ( type  => 'Hidden' , default => 'Facebook' );

has_field 'submit' => (
  type  => 'Submit' ,
  value => 'Validate Facebook Token' ,
);

1;
