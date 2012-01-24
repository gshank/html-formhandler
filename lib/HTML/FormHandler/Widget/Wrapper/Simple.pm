package HTML::FormHandler::Widget::Wrapper::Simple;
# ABSTRACT: simple field wrapper

use Moose::Role;
use namespace::autoclean;
use HTML::FormHandler::Render::Util ('process_attrs');

with 'HTML::FormHandler::Widget::Wrapper::Base';

=head1 SYNOPSIS

This is the default wrapper role. It will be installed if
no other wrapper is specified and widget_wrapper is not set to
'none'.

It used the 'widget_tags' keys 'wrapper_start' and 'wrapper_end',
so that the default C<< '<div<%class>>' >> and C<< '</div>' >> tags
may be replaced. The following will cause the fields to be wrapped
in paragraph tags instead:

   has '+widget_tags' => ( default => sub { {
      wrapper_start => '<p>',
      wrapper_end   => '</p>' }
   );

Alternatively, 'wrapper_tag' can be set to switch to a tag besides 'div',
but still use the the wrapper attribute processing:

   has '+widget_tags' => ( default => sub { { wrapper_tag => 'p' } } );

=cut

has 'auto_fieldset' => ( isa => 'Bool', is => 'rw', lazy => 1, default => 1 );

sub wrap_field {
    my ( $self, $result, $rendered_widget ) = @_;

    return $rendered_widget if ( $self->has_flag('is_compound') && $self->get_tag('no_compound_wrapper') );

    my $output = "\n";

    my $tag = $self->wrapper_tag;
    my $start_tag = $self->get_tag('wrapper_start');
    if( defined $start_tag ) {
        $output .= $start_tag;
    }
    else {
        $output .= "<$tag" . process_attrs( $self->wrapper_attributes($result) ) . ">";
    }

    if ( $self->has_flag('is_compound') ) {
        if( $self->auto_fieldset ) {
            $output .= '<fieldset class="' . $self->html_name . '">';
            $output .= '<legend>' . $self->loc_label . '</legend>';
        }
    }
    elsif ( !$self->has_flag('no_render_label') && length( $self->label ) > 0 ) {
        $output .= $self->render_label;
    }

    $output .= $rendered_widget;
    $output .= qq{\n<span class="error_message">$_</span>}
        for $result->all_errors;
    $output .= '</fieldset>'
        if ( $self->has_flag('is_compound') && $self->auto_fieldset );

    my $end_tag = $self->get_tag('wrapper_end');
    $output .= defined $end_tag ? $end_tag : "</$tag>";

    return "$output\n";
}

1;
