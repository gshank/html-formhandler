use strict;
use warnings;
use Test::More;

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'float1' => ( type => 'Float', decimal_symbol_for_db => ',' );
    has_field 'float2' => ( type => 'Float' );
    has_field 'float3' => ( type => 'Float' );
}

my $form = Test::Form->new;
my $params = { float1 => '+1.00', float2 => '3.35', float3 => '44.0' };
$form->process( params => $params );

my $float1 = $form->field('float1')->value;
is( $float1, '1,00', 'float has been deflated' );
my $float2 = $form->field('float2')->value;
is( $float2, '3.35', 'correct float value' );

done_testing;
