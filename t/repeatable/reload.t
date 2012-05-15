use strict;
use warnings;
use Test::More;

# this test emulates using a database item, and checks
# to see that the repeatable is updated from the item,
# and that 'fif' is correct
{
    package MyApp::Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo';
    has_field 'bar';
    has_field 'my_rep' => ( type => 'Repeatable' );
    has_field 'my_rep.rep_id' => ( type => 'PrimaryKey' );
    has_field 'my_rep.one';
    has_field 'my_rep.two';

    sub update_model {
        my $self = shift;
        my $value = $self->value;
        my $index = 1;
        foreach my $rep ( @{ $value->{my_rep} } ) {
            $rep->{rep_id} = $index;
            $index++;
        }
        $self->item( $value );
    }
}

my $form = MyApp::Test::Form->new;
ok( $form );

my $item = {
    foo => 'my_foo',
    bar => 'my_bar',
    my_rep => [
    ],
};
$form->process( item => $item );
my $fif = $form->fif;
$fif->{'my_rep.0.one'} = 'my_one';
$fif->{'my_rep.0.two'} = 'my_two';
$form->process( item => $item, params => $fif );
$fif->{'my_rep.0.rep_id'} = 1;
my $new_fif = $form->fif;
is_deeply( $new_fif, $fif, 'fif is correct' );
is( $form->field('my_rep.0.rep_id')->value, 1, 'pk has correct value' );

done_testing;
