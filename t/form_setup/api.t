use strict;
use warnings;
use Test::More;
use Data::Printer;

{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+use_fields_for_input_without_param' => ( default => 1 );
    has_field 'foo';
    has_field 'bar' => ( default => 2 );
    has_field 'moxy';
    has_field 'naffy' => ( type => 'Compound' );
    has_field 'naffy.one';
    has_field 'naffy.two' => ( default => 'two');

}

my $form = MyApp::Form::Test->new;
ok( $form );

# process with no params
$form->process( {} );
my $fif = $form->fif;
my $exp_fif = {
    foo => '',
    bar => 2,
    moxy => '',
    'naffy.one' => '',
    'naffy.two' => 'two',
};
is_deeply( $fif, $exp_fif, 'expected fif for non-validated' );

# process with only one param, others from fields
my $params = { foo => 1 };
$form->process( $params );
$fif = $form->fif;
$exp_fif = {
    foo => 1,
    bar => 2,
    moxy => '',
    'naffy.one' => '',
    'naffy.two' => 'two',
};
is_deeply( $fif, $exp_fif, 'got expected fill-in-form including defaults' );

# moxy && # naffy->{one} are missing because not validated, so not
# moved to value.
my $value = $form->value;
my $val_exp = {
    foo => 1,
    bar => 2,
    moxy => undef,
    naffy => {
        one => undef,
        two => 'two',
    },
};
is_deeply( $value, $val_exp, 'got expected value' );

done_testing;
