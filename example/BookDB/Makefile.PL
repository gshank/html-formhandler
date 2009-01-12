use inc::Module::Install;

name 'BookDB';
abstract('Moose conversion of Form::Processor');
author('Gerda Shank');
all_from 'lib/BookDB.pm';

requires 'Catalyst::Runtime' => '5.7010';
requires 'Catalyst::View::TT';
requires 'Catalyst::Model::DBIC::Schema';
requires 'DBIx::Class';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::FillInForm';
requires 'YAML'; 

catalyst;

install_script glob('script/*.pl');
auto_install;
tests( 't/*.t', 't/*/*.t' );
WriteAll;
