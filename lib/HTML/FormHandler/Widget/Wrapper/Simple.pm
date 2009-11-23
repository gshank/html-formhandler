package HTML::FormHandler::Widget::Wrapper::Simple;

use Moose::Role;
with 'HTML::FormHandler::Widget::Wrapper::Base';

=head1 NAME

HTML::FormHandler::Widget::Wrapper::Simple

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
    
=cut

sub wrap_field {
    my ( $self, $result, $rendered_widget ) = @_;

    my $start_tag = $self->get_tag('wrapper_start') || '<div<%class%>>';
    my $class  = $self->render_class($result);
    $start_tag =~ s/<%class%>/$class/g;
    my $output = "\n" . $start_tag; 
    if ( $self->has_flag('is_compound') ) {
        $output .= '<fieldset class="' . $self->html_name . '">';
        $output .= '<legend>' . $self->label . '</legend>';
    }
    elsif ( !$self->has_flag('no_render_label') && $self->label ) {
        $output .= $self->render_label;
    }
    $output .= $rendered_widget;
    $output .= qq{\n<span class="error_message">$_</span>} for $result->all_errors;
    if ( $self->has_flag('is_compound') ) {
        $output .= '</fieldset>';
    }
    my $end_tag = $self->get_tag('wrapper_end') || '</div>';
    $output .= $end_tag . "\n";
    return $output;
}

no Moose::Role;
1;
