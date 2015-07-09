package HTML::FormHandler::Widget::Field::Compound;
# ABSTRACT: compound field widget
use strict;
use warnings;
use Moose::Role;

=head1 SYNOPSIS

Widget for rendering a compound field.

=cut

sub render_subfield {
    my ( $self, $result, $subfield ) = @_;
    my $subresult = $result->field( $subfield->name );

    return "" unless $subresult;
    return $subfield->render( $subresult );
}

sub render_element {
    my ( $self, $result ) = @_;
    $result ||= $self->result;

    my $output = '';
    foreach my $subfield ( $self->sorted_fields ) {
        $output .= $self->render_subfield( $result, $subfield );
    }
    $output =~ s/^\n//; # remove newlines so they're not duplicated
    return $output;
}

sub render {
    my ( $self, $result ) = @_;
    $result ||= $self->result;
    die "No result for form field '" . $self->full_name . "'. Field may be inactive." unless $result;
    my $output = $self->render_element( $result );
    return $self->wrap_field( $result, $output );
}

use namespace::autoclean;
1;
