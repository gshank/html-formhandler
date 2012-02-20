package Field::MyComp;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Compound';

has_field 'flim' => ( type => 'Select', options_method => \&options_flim );
has_field 'flam' => ( type => 'Multiple', options_method => \&options_flam );
has_field 'flot';

sub options_flim {
    my $self = shift;
    my $form = $self->form;
    return [ { value => 1, label => 'one' }, { value => 2, label => 'two' } ];
}

sub options_flam {
    my $self = shift;
    my $form = $self->form;
    return [ { value => 1, label => 'red' }, { value => 2, label => 'blue' } ];
}

1;
