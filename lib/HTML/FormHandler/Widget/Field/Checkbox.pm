package HTML::FormHandler::Widget::Field::Checkbox;
# ABSTRACT: HTML attributes field role
use strict;
use warnings;
use Moose::Role;
use namespace::autoclean;
use HTML::FormHandler::Render::Util ('process_attrs');

=head1 SYNOPSIS

Checkbox field renderer

=cut

sub render_element {
    my ( $self, $result ) = @_;
    $result ||= $self->result;

    my $checkbox_value = $self->checkbox_value;
    my $output = '<input type="checkbox" name="'
        . $self->html_name . '" id="' . $self->id . '" value="'
        . $self->html_filter($checkbox_value) . '"';
    $output .= ' checked="checked"'
        if $result->fif eq $checkbox_value;
    $output .= process_attrs($self->element_attributes($result));
    $output .= ' />';
    return $output;
}

sub render {
    my ( $self, $result ) = @_;
    $result ||= $self->result;
    die "No result for form field '" . $self->full_name . "'. Field may be inactive." unless $result;
    my $output = $self->render_element( $result );
    return $self->wrap_field( $result, $output );
}

1;
