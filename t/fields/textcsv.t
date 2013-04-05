use strict;
use warnings;
use Test::More;

# tests the TextCSV field
{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo' => ( type => 'TextCSV' );
    has_field 'bar' => ( type => 'TextCSV' );

}

my $form = MyApp::Form::Test->new;
ok( $form );
my $init_obj = { foo => [1,4,5], bar => ['1,2'] };

$form->process( init_object => $init_obj );
my $fif = $form->fif;
is_deeply( $fif, { foo => '1,4,5', bar => '1,2' },
   'fif is correct' );

my $rendered = $form->render;
ok( $rendered, 'rendering worked' );

my $params = { foo => '', bar => '1,2'  };
$form->process( $params );
$fif = $form->fif;
is_deeply( $fif, $params, 'fif ok' );
my $value = $form->value;
is_deeply( $value, { foo => undef, bar => [1,2] }, 'right value' );
$rendered = $form->render;
ok( $rendered, 'rendering worked' );

done_testing;
