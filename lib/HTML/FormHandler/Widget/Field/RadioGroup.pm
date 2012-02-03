package HTML::FormHandler::Widget::Field::RadioGroup;
# ABSTRACT: radio group rendering widget

=head1 SYNOPSIS

Renders a radio group (from a 'Select' field);

Tags: radio_br_after

=cut

use Moose::Role;
use namespace::autoclean;
use HTML::FormHandler::Render::Util ('process_attrs');

sub render {
    my $self = shift;
    my $result = shift || $self->result;
    my $id = $self->id;
    my $output = "<br />";
    my $index  = 0;

    my $fif = $result->fif;
    foreach my $option ( @{ $self->options } ) {
        my $value = $option->{value};
        $output .= qq{<label for="$id.$index"><input type="radio" value="}
            . $self->html_filter($value) . '" name="'
            . $self->html_name . qq{" id="$id.$index"};
        $output .= ' checked="checked"'
            if $fif eq $value;
        $output .= process_attrs($self->element_attributes($result));
        $output .= ' />';
        my $label = $option->{label};
        $label = $self->_localize($label) if $self->localize_labels;
        $output .= $self->html_filter($label) . '</label>';
        $output .= '<br />' if $self->get_tag('radio_br_after');
        $index++;
    }
    return $self->wrap_field( $result, $output );
}

1;
