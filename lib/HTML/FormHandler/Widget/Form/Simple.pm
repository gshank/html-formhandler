package HTML::FormHandler::Widget::Form::Simple;

use Moose::Role;

with 'HTML::FormHandler::Widget::Form::Role::HTMLAttributes';
our $VERSION = 0.01;

=head1 NAME

HTML::FormHandler::Widget::Form::Simple - render a form with divs

=head1 SYNOPSIS

Role to apply to form objects to allow rendering. In your form:

   has '+widget_form' => ( default => 'Simple' );

=cut

has 'auto_fieldset' => ( isa => 'Bool', is => 'rw', lazy => 1, default => 1 );

sub render {
    my ($self) = @_;

    my $result;
    my $form;
    if ( $self->DOES('HTML::FormHandler::Result') ) {
        $result = $self;
        $form   = $self->form;
    }
    else {
        $result = $self->result;
        $form   = $self;
    }
    my $output = $form->render_start;

    foreach my $fld_result ( $result->results ) {
        die "no field in result for " . $fld_result->name
            unless $fld_result->field_def;
        $output .= $fld_result->render;
    }

    $output .= $self->render_end;
    return $output;
}

sub render_start {
    my $self = shift;

    my $output = $self->html_form_tag;

    $output .= '<fieldset class="main_fieldset">'
        if $self->form->auto_fieldset;

    return $output
}

sub render_end {
    my $self = shift;
    my $output;
    $output .= '</fieldset>' if $self->form->auto_fieldset;
    $output .= "</form>\n";
    return $output;
}

=head1 AUTHORS

See CONTRIBUTORS in L<HTML::FormHandler>

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

use namespace::autoclean;
1;

