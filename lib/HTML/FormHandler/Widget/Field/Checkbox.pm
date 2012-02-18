package HTML::FormHandler::Widget::Field::Checkbox;
# ABSTRACT: HTML attributes field role

=head1 SYNOPSIS

Checkbox field renderer. Supports the following
tags:

   unwrapped -- do not wrap the label around the checkbox
   single_label -- do not use double labels
   inline -- add 'inline' class to inner label

=cut

use Moose::Role;
use namespace::autoclean;
use HTML::FormHandler::Render::Util ('process_attrs');

sub render {
    my $self = shift;
    my $result = shift || $self->result;
    my $checkbox_value = $self->checkbox_value;

    my $output = '<input type="checkbox" name="'
        . $self->html_name . '" id="' . $self->id . '" value="'
        . $self->html_filter($checkbox_value) . '"';
    $output .= ' checked="checked"'
        if $result->fif eq $checkbox_value;
    $output .= process_attrs($self->element_attributes($result));
    $output .= ' />';
    # label and input element, label not wrapped
    if( $self->get_tag('unwrapped' ) ) {
        return $self->wrap_field( $result, $output );
    }
    # single label wrapped around checkbox
    elsif( $self->get_tag('single_label') ) {
        return $self->wrap_field( $result, $output, 'wrap_label' );
    }
    # default processing:
    # do "inner" label wrap, and forward to wrap_field for
    # outer wrapping
    $output = $self->wrap_with_label( $result, $output );
    return $self->wrap_field( $result, $output );
}

sub wrap_with_label {
    my ( $self, $result, $rendered_widget ) = @_;

    my $id = $self->id;
    my $label =  $self->option_label || $self->label;
    my @label_class = ('checkbox');
    push @label_class, 'inline' if $self->get_tag('inline');
    my $lattr = process_attrs( { class => \@label_class } );
    $label = $self->html_filter($self->_localize($label));
    my $output = qq{<label$lattr for="$id">};
    my $label_left = $self->get_tag('label_left');
    $output .= "\n$label" if $label_left;
    $output .= "\n$rendered_widget";
    $output .= "\n$label" if ! $label_left;
    $output .= "\n</label>";
}


1;
