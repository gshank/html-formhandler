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

sub render {
    my ( $self, $result ) = @_;
    $result ||= $self->result;
    my $output = $self->render_element( $result );
    return $self->wrap_field( $result, $output );
}

sub render_element {
    my ( $self, $result ) = @_;
    $result ||= $self->result;

    # create select element
    my $output = $self->render_select_start( $result );

    # create empty select
    if( defined $self->empty_select ) {
        $output .= $self->render_empty_select;
    }

    # loop through options
    foreach my $option ( @{ $self->{options} } ) {
        if ( my $label = $option->{group} ) {
            $label = $self->_localize( $label ) if $self->localize_labels;
            $output .= qq{\n<optgroup label="$label">};
            foreach my $group_opt ( @{ $option->{options} } ) {
                $output .= $self->render_option( $group_opt, $result );
            }
            $output .= qq{\n</optgroup>};
        }
        else {
            $output .= $self->render_option( $option, $result );
        }
    }
    $self->reset_options_index;

    $output .= '</select>';
    return $output;
}

sub render_select_start {
    my ( $self, $result ) = @_;
   $result ||= $self->result;

    my $id = $self->id;
    my $output = '<select name="' . $self->html_name . qq{" id="$id"};
    $output .= ' multiple="multiple"' if $self->multiple;
    $output .= ' size="' . $self->size . '"' if defined $self->size;
    $output .= process_attrs($self->element_attributes($result));
    $output .= '>';
    return $output;
}

sub render_empty_select {
    my $self = shift;

    my $label = $self->_localize($self->empty_select);
    my $id = $self->id . "." . $self->options_index;
    my $output .= qq{\n<option value="" id="$id">$label</option>};
    $self->inc_options_index;
    return $output;
}

sub render_option {
    my ( $self, $option, $result ) = @_;
    $result ||= $self->result;

    # current values
    my $fif = $result->fif;
    my %fif_lookup;
    @fif_lookup{@$fif} = () if $self->multiple;

    my $value = $option->{value};
    my $id = $self->id . '.' . $self->options_index;
    my $output .= qq{\n<option value="} . $self->html_filter($value) . '"';
    $output .= qq{ id="$id"};

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
    $self->inc_options_index;
    return $output;
}

1;
