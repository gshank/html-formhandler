use strict;
use warnings;
use Test::More;

{
    package Test::Field::MyComp;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Field::Compound';

    has_field 'flim' => ( type => 'Select', options_method => \&options_flim );
    has_field 'flam' => ( type => 'Multiple', options_method => \&options_flam );
    has_field 'flot';

    sub options_flim {
        my $self = shift;
        return [ { value => 1, label => 'one' }, { value => 2, label => 'two' } ];
    }

    sub options_flam {
        my $self = shift;
        return [ { value => 1, label => 'red' }, { value => 2, label => 'blue' } ];
    }

}

{
    package Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+field_name_space' => ( default => sub { [ 'Test::Field' ] } );
    has_field 'floo' => ( type => 'MyComp' );
    has_field 'ploot';

}

my $form = Test::Form->new;
ok( $form, 'form built' );
my $flim_options = $form->field('floo.flim')->options;
is( scalar @$flim_options, 2, 'right number of flim options' );
my $flam_options = $form->field('floo.flam')->options;
is( scalar @$flam_options, 2, 'right number of flam options' );

done_testing;
