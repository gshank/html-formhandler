package HTML::FormHandler::Widget::Field::Span;
# ABSTRACT: button field rendering widget
use strict;
use warnings;

=head1 SYNOPSIS

Renders the NonEditable pseudo-field as a span.

   <span id="my_field" class="test">The Field Value</span>

=cut

use Moose::Role;
use HTML::FormHandler::Render::Util ('process_attrs');
use namespace::autoclean;

sub render_element {
    my ( $self, $result ) = @_;
    $result ||= $self->result;

    my $output = '<span';
    $output .= ' id="' . $self->id . '"';
    $output .= process_attrs($self->element_attributes($result));
    $output .= '>';
    $output .= $self->value;
    $output .= '</span>';
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
