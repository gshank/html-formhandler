package HTML::FormHandler::Widget::Field::Select;
# ABSTRACT: select field rendering widget

=head1 NAME

HTML::FormHandler::Widget::Field::Select

=head1 DESCRIPTION

Renders single and multiple selects. Options hashrefs must
have 'value' and 'label' keys, and may have an 'attributes' key.

=cut

use Moose::Role;
use namespace::autoclean;
use HTML::FormHandler::Render::Util ('process_attrs');

sub render_element {
    my ( $self, $result ) = @_;
    $result ||= $self->result;

    my $id = $self->id;
    # create select element
    my $output = '<select name="' . $self->html_name . qq{" id="$id"};
    $output .= ' multiple="multiple"' if $self->multiple;
    $output .= ' size="' . $self->size . '"' if defined $self->size;
    $output .= process_attrs($self->element_attributes($result));
    $output .= '>';

    # create empty select
    my $index = 0;
    if( defined $self->empty_select ) {
        my $label = $self->_localize($self->empty_select);
        $output .= qq{\n<option value="" id="$id.$index">$label</option>};
        $index++;
    }

    # current values
    my $fif = $result->fif;
    my %fif_lookup;
    @fif_lookup{@$fif} = () if $self->multiple;

    # loop through options
    foreach my $option ( @{ $self->{options} } ) {
        my $value = $option->{value};
        $output .= qq{\n<option value="} . $self->html_filter($value) . '"';
        $output .= qq{ id="$id.$index"};

        # handle option attributes
        my $attrs = $option->{attributes} || {};
        if( defined $option->{disabled} && $option->{disabled} ) {
            $attrs->{disabled} = 'disabled';
        }
        if ( defined $fif &&
             ( ( $self->multiple && exists $fif_lookup{$value} ) ||
               ( $fif eq $value ) ) ) {
            $attrs->{selected} = 'selected';
        }
        $output .= process_attrs($attrs);

        # handle label
        my $label = $option->{label};
        $label = $self->_localize($label) if $self->localize_labels;
        $output .= '>' . ( $self->html_filter($label) || '' ) . '</option>';
        $index++;
    }
    $output .= '</select>';
    return $output;
}

sub render {
    my ( $self, $result ) = @_;
    $result ||= $self->result;
    my $output = $self->render_element( $result );
    return $self->wrap_field( $result, $output );
}


1;
