package HTML::FormHandler::Widget::Field::CheckboxGroup;
# ABSTRACT: checkbox group field role

use Moose::Role;
use namespace::autoclean;

with 'HTML::FormHandler::Widget::Field::Role::SelectedOption';
with 'HTML::FormHandler::Widget::Field::Role::HTMLAttributes';

sub render {
    my $self = shift;
    my $result = shift || $self->result;
    my $output = " <br />";
    my $index  = 0;
    my $multiple = $self->multiple;
    my $id = $self->id;
    my $html_attributes = $self->_add_html_attributes;

    my $fif = $result->fif;
    my %fif_lookup;
    @fif_lookup{@$fif} = () if $multiple;
    foreach my $option ( @{ $self->{options} } ) {
        my $value = $option->{value};
        $output .= '<input type="checkbox" value="'
            . $self->html_filter($value) . '" name="'
            . $self->html_name . qq{" id="$id.$index"};
        if( defined $option->{disabled} && $option->{disabled} ) {
            $output .= 'disabled="disabled" ';
        }
        if ( defined $fif ) {
            if ( $multiple && exists $fif_lookup{$value} ) {
                $output .= ' checked="checked"';
            }
            elsif ( $fif eq $value ) {
                $output .= ' checked="checked"';
            }
        }
        $output .= $html_attributes;
        my $label = $option->{label};
        $label = $self->_localize($label) if $self->localize_labels;
        $output .= ' />' . ( $self->html_filter($label) || '' ) . '<br />';
        $index++;
    }
    return $self->wrap_field( $result, $output );
}

1;
