use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo';
    has_field 'bar';
    has_field 'sbmt' => ( type => 'Submit', value => 'Test', default_method => \&default_submit );
    sub default_submit {
        my $self = shift;
        my $value = $self->value;
        $value .= "_from_method";
    }

}

my $form = MyApp::Form::Test->new;
ok( $form );
my $expected =
'<div><input id="sbmt" name="sbmt" type="submit" value="Test_from_method" /></div>';
my $rendered = $form->field('sbmt')->render;
is_html( $rendered, $expected, 'submit button renders ok' );

done_testing;
