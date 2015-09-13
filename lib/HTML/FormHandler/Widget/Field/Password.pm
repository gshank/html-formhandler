package HTML::FormHandler::Widget::Field::Password;
# ABSTRACT: password rendering widget
use strict;
use warnings;
use Moose::Role;
use namespace::autoclean;
use HTML::FormHandler::Render::Util ('process_attrs');

=head1 SYNOPSIS

Renders a password field

=cut

sub render_element {
    my $self = shift;
    my $result = shift || $self->result;
    my $t;

    my $output = '<input type="password" name="'
        . $self->html_name . '" id="' . $self->id . '"';
    $output .= qq{ size="$t"} if $t = $self->size;
    $output .= qq{ maxlength="$t"} if $t = $self->maxlength;
    $output .= ' value="' . $self->html_filter($result->fif) . '"';
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
