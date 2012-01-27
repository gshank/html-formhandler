package HTML::FormHandler::Widget::Form::Table;
# ABSTRACT: render a form with a table layout

use Moose::Role;
with 'HTML::FormHandler::Widget::Form::Simple' =>
    { -excludes => [ 'render_start', 'render_end', 'render_form_errors' ] };
use HTML::FormHandler::Render::Util ('process_attrs');

=head1 SYNOPSIS

Set in your form:

   has '+widget_form' => ( default => 'Table' );

Use in a template:

   [% form.render %]

=cut

sub render_start {
    my $self   = shift;
    my $attrs = process_attrs($self->attributes);
    my $wrapper_attrs = $self->get_tag('form_wrapper_attr') || {};
    $wrapper_attrs->{class} = 'form_wrapper' unless exists $attrs->{class};
    my $pattrs = process_attrs($attrs);
    return qq{<form$attrs><table$pattrs>\n};
}

sub render_form_errors {
    my ( $self, $form, $result ) = @_;

    return '' unless $result->has_form_errors;
    my $output = "\n<tr class=\"form_errors\"><td colspan=\"2\">";
    $output .= qq{\n<span class="error_message">$_</span>}
        for $result->all_form_errors;
    $output .= "\n</td></tr>";
    return $output;
}

sub render_end {
    my $self = shift;
    my $output .= "</table>\n";
    $output .= "</form>\n";
    return $output;
}

use namespace::autoclean;
1;

