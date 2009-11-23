package HTML::FormHandler::Render::Table;

use Moose::Role;

with 'HTML::FormHandler::Render::Simple' =>
    { excludes => [ 'render', 'render_field_struct', 'render_end', 'render_start' ] };

=head1 NAME

HTML::FormHandler::Render::Table - render a form with a table layout

=head1 SYNOPSIS

Include this role in a form:

   package MyApp::Form::User;
   with 'HTML::FormHandler::Render::Table

Use in a template:

   [% form.render %]

=cut

sub render {
    my $self = shift;

    my $output = $self->render_start;
    foreach my $field ( $self->sorted_fields ) {
        $output .= $self->render_field($field);
    }
    $output .= $self->render_end;
    return $output;
}

sub render_start {
    my $self   = shift;
    my $output = '<form ';
    $output .= 'action="' . $self->action . '" '      if $self->action;
    $output .= 'id="' . $self->name . '" '            if $self->name;
    $output .= 'name="' . $self->name . '" '          if $self->name;
    $output .= 'method="' . $self->http_method . '" ' if $self->http_method;
    $output .= 'enctype="' . $self->enctype . '" '    if $self->enctype;
    $output .= '>' . "\n";
    $output .= "<table>\n";
    return $output;
}

sub render_end {
    my $self = shift;
    my $output .= "</table>\n";
    $output .= "</form>\n";
    return $output;
}

sub render_field_struct {
    my ( $self, $field, $rendered_field, $class ) = @_;
    my $output = qq{\n<tr$class>};
    my $l_type =
        defined $self->get_label_type( $field->widget ) ?
        $self->get_label_type( $field->widget ) :
        '';
    if ( $l_type eq 'label' ) {
        $output .= '<td>' . $self->_label($field) . '</td>';
    }
    elsif ( $l_type eq 'legend' ) {
        $output .= '<td>' . $self->_label($field) . '</td></tr>';
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

=head1 AUTHORS

HFH Contributors, see L<HTML::FormHandler>

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

use namespace::autoclean;
1;

