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

sub render_element {
    my ( $self, $result ) = @_;
    $result ||= $self->result;

    my $id = $self->id;
    my $fif = $result->fif;
    my %fif_lookup;
    @fif_lookup{@$fif} = () if $self->multiple;

    # create option label attributes
    my @option_label_class = ('checkbox');
    push @option_label_class, 'inline' if $self->get_tag('inline');
    my $opt_lattrs = process_attrs( { class => \@option_label_class } );

    # loop through options
    my $index  = 0;
    my $output = '';
    foreach my $option ( @{ $self->{options} } ) {
        $output .= qq{\n<label$opt_lattrs for="$id.$index">};
        my $value = $option->{value};
        $output .= qq{\n<input type="checkbox"};
        $output .= qq{ value="} . $self->html_filter($value) . '"';
        $output .= qq{ name="} . $self->html_name . '"';
        $output .= qq{ id="$id.$index"};

        # handle option attributes
        my $attrs = $option->{attributes} || {};
        if( defined $option->{disabled} && $option->{disabled} ) {
            $attrs->{disabled} = 'disabled';
        }
        if ( defined $fif &&
             ( ( $self->multiple && exists $fif_lookup{$value} ) ||
                 ( $fif eq $value ) ) ) {
            $attrs->{checked} = 'checked';
        }
        $output .= process_attrs($attrs);
        $output .= " />\n";

        # handle label
        my $label = $option->{label};
        $label = $self->_localize($label) if $self->localize_labels;
        $output .= $self->html_filter($label) || '';
        $output .= "\n</label>";
        $index++;
    }
    return $output;
}

sub render {
    my ( $self, $result ) = @_;
    $result ||= $self->result;
    my $output = $self->render_element( $result );
    return $self->wrap_field( $result, $output );
}

1;
