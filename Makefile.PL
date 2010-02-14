#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install;

name 'StatusShooter';
all_from 'lib/StatusShooter.pm';

requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Model::Adaptor';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::Unicode';
requires 'Catalyst::Runtime'                   => '5.80014';
requires 'Catalyst::View::TT';
requires 'Config::Any';
requires 'HTML::FormHandler';
requires 'HTML::FormHandler::Moose';
requires 'HTML::FormHandler::Render::Simple';
requires 'Moose';
requires 'MooseX::Declare';
requires 'Net::Twitter';
requires 'WWW::Facebook::API';
requires 'YAML';
requires 'namespace::autoclean';
requires 'parent';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
