package HTML::FormHandler::Widget::Field::RadioGroup;
# ABSTRACT: radio group rendering widget
use Moose::Role;
use namespace::autoclean;
use HTML::FormHandler::Render::Util ('process_attrs');

=head1 SYNOPSIS

Renders a radio group (from a 'Select' field);

Tags: radio_br_after

=cut

sub render_element {
    my ( $self, $result ) = @_;
    $result ||= $self->result;

    my $id = $self->id;
    my $output = '';
    $output .= "<br />" if $self->get_tag('radio_br_after');
    my $index  = 0;

    my $fif = $result->fif;
    my @label_class = ('radio');
    my $lattrs = process_attrs( { class => \@label_class } );
    foreach my $option ( @{ $self->options } ) {
        my $value = $option->{value};
        $output .= qq{\n<label$lattrs for="$id.$index">\n<input type="radio" value="}
            . $self->html_filter($value) . '" name="'
            . $self->html_name . qq{" id="$id.$index"};
        $output .= ' checked="checked"'
            if $fif eq $value;
        $output .= process_attrs($self->element_attributes($result));
        $output .= ' />';
        my $label = $option->{label};
        $label = $self->_localize($label) if $self->localize_labels;
        $output .= "\n" . $self->html_filter($label);
        $output .= "\n</label>";
        $output .= '<br />' if $self->get_tag('radio_br_after');
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
