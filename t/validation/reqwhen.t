use strict;
use warnings;
use Test::More;

# required_when test
{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'fee';
    has_field 'fie' => ( required_when => { 'fee' => 2 } );

}

my $form = MyApp::Form::Test->new;
my $params = { fee => 1, fie => '' };
$form->process( $params );
ok( $form->validated );
$params = { fee => 2, fie => '' };
$form->process( $params );
ok( ! $form->validated, 'did not validate when fee is 2' );

# required when the other field isn't empty
{
    package MyApp::Form::Test2;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'fee';
    has_field 'fie' => ( required_when => { 'fee' => sub { $_[0] ne '' } } );

}

$form = MyApp::Form::Test->new;
$params = { fee => '', fie => '' };
$form->process( $params );
ok( $form->validated );
$params = { fee => 2, fie => '' };
$form->process( $params );
ok( ! $form->validated, 'did not validate when fee is 2' );

done_testing;
