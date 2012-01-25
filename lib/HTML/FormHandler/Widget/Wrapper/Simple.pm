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


sub wrap_field {
    my ( $self, $result, $rendered_widget ) = @_;

    return $rendered_widget if ( $self->has_flag('is_compound') && ! $self->get_tag('compound_wrapper') );

    my $output = "\n";

    my $wrapper_tag = $self->wrapper_tag;
    my $start_tag = $self->get_tag('wrapper_start');
    if( defined $start_tag ) {
        $output .= $start_tag;
    }
    else {
        $output .= "<$wrapper_tag" . process_attrs( $self->wrapper_attributes($result) ) . ">";
    }
    # if this a compound field, the accumulated rendered subfields will have
    # been passed in $rendered_widget, so ... is this double wrapping?
    if ( $self->has_flag('is_compound') && $self->get_tag('compound_wrapper') ) {
        my $compound_wrapper_tag = $self->get_tag('compound_wrapper_tag') || 'fieldset';
        my $html_name = $self->html_name;
        $output .= qq{<$compound_wrapper_tag class="$html_name">};
        if( $compound_wrapper_tag eq 'fieldset' ) {
            $output .= '<legend>' . $self->loc_label . '</legend>';
        }
    }
    elsif ( !$self->has_flag('no_render_label') && length( $self->label ) > 0 ) {
        $output .= $self->render_label;
    }

    $output .= $rendered_widget;
    $output .= qq{\n<span class="error_message">$_</span>}
        for $result->all_errors;
    if ( $self->has_flag('is_compound') && $self->get_tag('compound_wrapper') ) {
        my $compound_wrapper_tag = $self->get_tag('compound_wrapper_tag') || 'fieldset';
        $output .= "</$compound_wrapper_tag>";
    }

    my $end_tag = $self->get_tag('wrapper_end');
    $output .= defined $end_tag ? $end_tag : "</$wrapper_tag>";

    return "$output\n";
}

1;
