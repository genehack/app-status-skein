package App::StatusSkein::Web::Form::Add::Twitter;

use namespace::autoclean;

use HTML::FormHandler::Moose;
extends 'App::StatusSkein::Web::Form::Add';
with 'HTML::FormHandler::Render::Simple';

has '+name' => ( default => 'add_twitter' );

has_field 'username' => (
  type             => 'Text' ,
  label            => 'Username' ,
  required         => 1 ,
  required_message => 'You must enter a username' ,
  size             => 12 ,
);

has_field 'password' => (
  type             => 'Password' ,
  label            => 'Password' ,
  required         => 1 ,
  required_message => 'You must enter a password' ,
  size             => 12 ,
);

has_field 'type' => (
  type    => 'Hidden' ,
  default => 'Twitter' ,
);

has_field 'submit' => (
  type  => 'Submit' ,
  value => 'Add Twitter Account' ,
);

1;
