package HTML::FormHandler::Widget::Form::Table;
# ABSTRACT: render a form with a table layout

use Moose::Role;
with 'HTML::FormHandler::Widget::Form::Simple' =>
    { -excludes => [ 'render_start', 'render_end' ] };

=head1 SYNOPSIS

Set in your form:

   has '+widget_form' => ( default => 'Table' );

Use in a template:

   [% form.render %]

=cut

sub render_start {
    my $self   = shift;
    return $self->html_form_tag . "<table>\n";
}

sub render_end {
    my $self = shift;
    my $output .= "</table>\n";
    $output .= "</form>\n";
    return $output;
}

use namespace::autoclean;
1;

