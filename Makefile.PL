#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install;

name 'App-StatusSkein';
all_from 'lib/App/StatusSkein.pm';

requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Model::Adaptor';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::Unicode';
requires 'Catalyst::Runtime'                   => '5.8002';
requires 'Catalyst::View::JSON';
requires 'Catalyst::View::TT';
requires 'Config::Any';
requires 'Data::Dumper::HTML';
requires 'Date::Parse';
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
