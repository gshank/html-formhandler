use strict;
use warnings;
use Test::More;

{
    package MyApp::Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'fee';
    has_field 'fie' => ( apply => [
        { when => { fee => 1 }, check => qr/when/, message => 'Wrong fie' },
    ]);
    has_field 'fo';
    has_field 'fum_comp' => ( type => 'Compound' );
    has_field 'fum_comp.one' => ( apply => [
        { when => { '+fee' => sub { $_[0] == 1 } }, check => qr/when/, message => 'Wrong one' },
    ]);
    has_field 'fum_comp.two' => ( apply => [
        { when => { '+fee' => [1,2,3] }, check => qr/when/, message => 'Wrong two' },
    ]);
}

my $form = MyApp::Test::Form->new;
ok( $form );
my $params = {
    fee => '',
    fie => 'where',
    fo => 'my_fo',
    'fum_comp.one' => 2,
    'fum_comp.two' => 'where',
};
$form->process( $params );
ok( $form->validated );
$params->{fee} = 1;
$form->process( $params );
ok( !$form->validated, 'validation failed for fie when fee is 1' );
my @errors = $form->errors;
is( scalar @errors, 3, 'right number of errors' );

done_testing;
