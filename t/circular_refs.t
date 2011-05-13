use strict;
use warnings;
use Test::More;
use Test::Memory::Cycle;

{
   package My::RepeatableForm;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has '+name' => ( default => 'testform' );
   has_field 'reqname' => ( required => 1 );
   has_field 'entries' => (
        type             => 'Repeatable',
        required         => 1,
        required_message => 'Request without entries not accepted'
    );
    has_field 'entries.rule_index' => ( type => 'PrimaryKey' );
    has_field 'entries.foo' => (
        type     => 'Text',
        required => 1,
    );
    has_field 'entries.bar' => (
        type     => 'Text',
        required => 1,
    );
}

my $form = new_ok( 'My::RepeatableForm' );

my $params = {
    reqname => 'Testrequest',
    'entries.1.foo' => 'test1',
    'entries.1.bar' => 'test1',
    'entries.2.foo' => 'test2',
    'entries.2.bar' => 'test2',
};
memory_cycle_ok( $form, 'form has no memory cycles before process' );
ok( $form->process( params => $params ), 'form processed ok' );
memory_cycle_ok( $form, 'form has no memory cycles after process' );

done_testing;

