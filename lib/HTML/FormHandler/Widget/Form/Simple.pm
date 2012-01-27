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

    my $output = '';
    $output = $self->render_before_form() if $self->can('render_before_form');
    if( $self->get_tag('form_wrapper') ) {
        my $form_wrapper_tag = $self->get_tag('form_wrapper_tag') || 'fieldset';
        my $attrs = process_attrs($self->wrapper_attributes);
        $output .= qq{<$form_wrapper_tag$attrs>};
    }
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

    my $output .= "</form>\n";
    if( $self->get_tag('form_wrapper') ) {
        my $form_wrapper_tag = $self->tag_exists('form_wrapper_tag') ? $self->get_tag('form_wrapper_tag') : 'fieldset';
        $output .= qq{</$form_wrapper_tag>};
    }
    $output .= $self->render_after_form if $self->can('render_after_form' );
    return $output;
}

use namespace::autoclean;
1;

