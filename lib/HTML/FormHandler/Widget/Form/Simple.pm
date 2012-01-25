package HTML::FormHandler::Widget::Form::Simple;
# ABSTRACT: widget to render a form with divs

use Moose::Role;
use HTML::FormHandler::Render::Util ('process_attrs');

with 'HTML::FormHandler::Widget::Form::Role::HTMLAttributes';
our $VERSION = 0.01;

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
    $output .= $form->render_form_errors( $form, $result );

    foreach my $fld_result ( $result->results ) {
        die "no field in result for " . $fld_result->name
            unless $fld_result->field_def;
        $output .= $fld_result->render;
    }

    $output .= $form->render_end;
    return $output;
}

sub render_start {
    my $self = shift;

    my $auto_fieldset = $self->tag_exists('no_form_wrapper') ?
         not( $self->get_tag('no_form_wrapper') ) : $self->auto_fieldset;
    my $form_wrapper_tag = $self->tag_exists('form_wrapper_tag') ? $self->get_tag('form_wrapper_tag') : 'fieldset';
    my $output = qq{<$form_wrapper_tag class="main_fieldset">}
        if $auto_fieldset;
    my $attrs = process_attrs($self->attributes);
    $output .= qq{<form$attrs>};

    return $output
}

sub render_form_errors {
    my ( $self, $form, $result ) = @_;

    return '' unless $result->has_form_errors;
    my $output = "\n<div class=\"form_errors\">";
    $output .= qq{\n<span class="error_message">$_</span>}
        for $result->all_form_errors;
    $output .= "\n</div>";
    return $output;
}

sub render_end {
    my $self = shift;

    my $auto_fieldset = $self->tag_exists('no_form_wrapper') ?
         not( $self->get_tag('no_form_wrapper') ) : $self->auto_fieldset;
    my $form_wrapper_tag = $self->tag_exists('form_wrapper_tag') ? $self->get_tag('form_wrapper_tag') : 'fieldset';
    my $output .= "</form>\n";
    $output .= qq{</$form_wrapper_tag>} if $auto_fieldset;
    return $output;
}

use namespace::autoclean;
1;

