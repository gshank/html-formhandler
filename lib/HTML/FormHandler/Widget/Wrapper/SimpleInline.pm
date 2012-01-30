package HTML::FormHandler::Widget::Wrapper::SimpleInline;
# ABSTRACT: simple field wrapper

use Moose::Role;
use namespace::autoclean;

with 'HTML::FormHandler::Widget::Wrapper::Base';

=head1 SYNOPSIS

This works like the Simple Wrapper, except it doesn't wrap Compound
fields.

=cut

sub wrap_field {
    my ( $self, $result, $rendered_widget ) = @_;

    return $rendered_widget if $self->has_flag('is_compound');

    my $output = "\n";
    my $tag = $self->wrapper_tag;
    my $start_tag = $self->get_tag('wrapper_start');
    if( defined $start_tag ) {
        $output .= $start_tag;
    }
    else {
        $output .= "<$tag" . process_attrs( $self->wrapper_attributes($result) ) . ">";
    }

    if ( $self->render_label && length( $self->label ) > 0 ) {
        $output .= $self->do_render_label;
    }

    $output .= $rendered_widget;
    $output .= qq{\n<span class="error_message">$_</span>}
        for $result->all_errors;

    my $end_tag = $self->get_tag('wrapper_end');
    $output .= defined $end_tag ? $end_tag : "</$tag>";

    return "$output\n";
}

1;
