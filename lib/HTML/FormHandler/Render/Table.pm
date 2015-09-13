package HTML::FormHandler::Render::Table;
# ABSTRACT: render a form with a table layout
use strict;
use warnings;

use Moose::Role;

with 'HTML::FormHandler::Render::Simple' =>
    { -excludes => [ 'render', 'wrap_field', 'render_end', 'render_start' ] };
use HTML::FormHandler::Render::Util ('process_attrs');

=head1 SYNOPSIS

Include this role in a form:

   package MyApp::Form::User;
   use Moose;
   with 'HTML::FormHandler::Render::Table';

Use in a template:

   [% form.render %]

=cut

sub render {
    my $self = shift;

    my $output = $self->render_start;
    $output .= $self->render_form_errors;
    foreach my $field ( $self->sorted_fields ) {
        $output .= $self->render_field($field);
    }
    $output .= $self->render_end;
    return $output;
}

sub render_start {
    my $self   = shift;

    my $attrs = process_attrs($self->attributes);
    return qq{<form$attrs><table>};
}

sub render_form_errors {
    my $self = shift;

    return '' unless $self->has_form_errors;
    my $output = "\n<tr class=\"form_errors\"><td colspan=\"2\">";
    $output .= qq{\n<span class="error_message">$_</span>}
        for $self->all_form_errors;
    $output .= "\n</td></tr>";
    return $output;
}

sub render_end {
    my $self = shift;
    my $output .= "</table>\n";
    $output .= "</form>\n";
    return $output;
}

sub wrap_field {
    my ( $self, $field, $rendered_field ) = @_;

    my $attrs = process_attrs($field->wrapper_attributes);
    my $output = qq{\n<tr$attrs>};
    my $l_type = $field->widget eq 'Compound' ? 'legend' : 'label';
    if ( $l_type eq 'label' ) {
        $output .= '<td>' . $self->render_label($field) . '</td>';
    }
    elsif ( $l_type eq 'legend' ) {
        $output .= '<td>' . $self->render_label($field) . '</td></tr>';
    }
    if ( $l_type ne 'legend' ) {
        $output .= '<td>';
    }
    $output .= $rendered_field;
    $output .= qq{\n<span class="error_message">$_</span>} for $field->all_errors;
    if ( $l_type ne 'legend' ) {
        $output .= "</td></tr>\n";
    }
    return $output;
}

use namespace::autoclean;
1;

