package HTML::FormHandler::Widget::Field::Select;
# ABSTRACT: select field rendering widget

use Moose::Role;
use namespace::autoclean;

with 'HTML::FormHandler::Widget::Field::Role::HTMLAttributes';

sub render {
    my $self = shift;
    my $result = shift || $self->result;
    my $id = $self->id;
    my $index = 0;
    my $multiple = $self->multiple;
    my $output = '<select name="' . $self->html_name . qq{" id="$id"};
    my $t;
    my $html_attributes = $self->_add_html_attributes;

    $output .= ' multiple="multiple"' if $multiple;
    $output .= qq{ size="$t"} if $t = $self->size;
    $output .= $html_attributes;
    $output .= '>';

    if( defined $self->empty_select ) {
        $t = $self->_localize($self->empty_select);
        $output .= qq{<option value="">$t</option>};
    }

    my $fif = $result->fif;
    my %fif_lookup;
    @fif_lookup{@$fif} = () if $multiple;
    foreach my $option ( @{ $self->{options} } ) {
        my $value = $option->{value};
        $output .= '<option value="'
            . $self->html_filter($value)
            . qq{" id="$id.$index"};
        if( defined $option->{disabled} && $option->{disabled} ) {
            $output .= 'disabled="disabled" ';
        }
        if ( defined $fif ) {
            if ( $multiple && exists $fif_lookup{$value} ) {
                $output .= ' selected="selected"';
            }
            elsif ( $fif eq $value ) {
                $output .= ' selected="selected"';
            }
        }
        $output .= $html_attributes;
        my $label = $option->{label};
        $label = $self->_localize($label) if $self->localize_labels;
        $output .= '>' . ( $self->html_filter($label) || '' ) . '</option>';
        $index++;
    }
    $output .= '</select>';
    return $self->wrap_field( $result, $output );
}

1;
