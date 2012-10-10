package HTML::FormHandler::Widget::Field::CheckboxGroup;
# ABSTRACT: checkbox group field role

use Moose::Role;
use namespace::autoclean;
use HTML::FormHandler::Render::Util ('process_attrs');

=head1 SYNOPSIS

Checkbox group widget for rendering multiple selects.

Checkbox element label class is 'checkbox', plus 'inline'
if the 'inline' tag is set.

Options hashrefs must have the keys 'value', and 'label'.
They may have an 'attributes' hashref key. The 'checked'
attribute should not be set in the options hashref. It should
be set by supplying a default value or from params input.

=cut

sub render {
    my ( $self, $result ) = @_;
    $result ||= $self->result;
    die "No result for form field '" . $self->full_name . "'. Field may be inactive." unless $result;
    my $output = $self->render_element( $result );
    return $self->wrap_field( $result, $output );
}

sub render_element {
    my ( $self, $result ) = @_;
    $result ||= $self->result;


    # loop through options
    my $output = '';
    foreach my $option ( @{ $self->{options} } ) {
        if ( my $label = $option->{group} ) {
            $label = $self->_localize( $label ) if $self->localize_labels;
            my $attr = $option->{attributes} || {};
            my $attr_str = process_attrs($attr);
            my $lattr = $option->{label_attributes} || {};
            my $lattr_str= process_attrs($lattr);
            $output .= qq{\n<div$attr_str><label$lattr_str>$label</label>};
            foreach my $group_opt ( @{ $option->{options} } ) {
                $output .= $self->render_option( $group_opt, $result );
            }
            $output .= qq{\n</div>};
        }
        else {
            $output .= $self->render_option( $option, $result );
        }
    }
    $self->reset_options_index;
    return $output;
}

sub render_option {
    my ( $self, $option, $result ) = @_;
    $result ||= $self->result;

    # get existing values
    my $fif = $result->fif;
    my %fif_lookup;
    @fif_lookup{@$fif} = () if $self->multiple;

    # create option label attributes
    my $lattr = $option->{label_attributes} || {};
    push @{ $lattr->{class} }, 'checkbox';
    push @{ $lattr->{class} }, 'inline' if $self->get_tag('inline');
    my $lattr_str = process_attrs( $lattr );

    my $id = $self->id . '.' . $self->options_index;
    my $output .= qq{\n<label$lattr_str for="$id">};
    my $value = $option->{value};
    $output .= qq{\n<input type="checkbox"};
    $output .= qq{ value="} . $self->html_filter($value) . '"';
    $output .= qq{ name="} . $self->html_name . '"';
    $output .= qq{ id="$id"};

    # handle option attributes
    my $attr = $option->{attributes} || {};
    if( defined $option->{disabled} && $option->{disabled} ) {
        $attr->{disabled} = 'disabled';
    }
    if ( defined $fif &&
         ( ( $self->multiple && exists $fif_lookup{$value} ) ||
             ( $fif eq $value ) ) ) {
        $attr->{checked} = 'checked';
    }
    $output .= process_attrs($attr);
    $output .= " />\n";

    # handle label
    my $label = $option->{label};
    $label = $self->_localize($label) if $self->localize_labels;
    $output .= $self->html_filter($label);
    $output .= "\n</label>";
    $self->inc_options_index;
    return $output;
}

1;
