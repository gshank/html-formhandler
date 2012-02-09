package HTML::FormHandler::Widget::Form::Simple;
# ABSTRACT: widget to render a form with divs

use Moose::Role;
use HTML::FormHandler::Render::Util ('process_attrs');

with 'HTML::FormHandler::Widget::Form::Role::HTMLAttributes';
our $VERSION = 0.01;

=head1 SYNOPSIS

Role to apply to form objects to allow rendering. In your form:

   has '+widget_form' => ( default => 'Simple' );

Supported widget_tags:

    form_wrapper   -- put a wrapper around main form
    form_wrapper_tag -- tag for form wrapper; default 'fieldset'
    form_before
    form_after
    form_after_start
    form_before_end

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
    my $output = $form->render_start($result);
    $output .= $form->render_form_errors( $result );

    foreach my $fld_result ( $result->results ) {
        die "no field in result for " . $fld_result->name
            unless $fld_result->field_def;
        $output .= $fld_result->render;
    }

    $output .= $form->render_end;
    return $output;
}

sub render_start {
    my ( $self, $result ) = @_;
    $result ||= $self->result;

    my $output = '';
    $output = $self->get_tag('form_before') if $self->tag_exists('form_before');
    if( $self->get_tag('form_wrapper') ) {
        my $form_wrapper_tag = $self->get_tag('form_wrapper_tag') || 'fieldset';
        my $attrs = process_attrs($self->form_wrapper_attributes($result));
        $output .= qq{<$form_wrapper_tag$attrs>};
    }
    my $attrs = process_attrs($self->attributes($result));
    $output .= qq{<form$attrs>};
    $output .= $self->get_tag('form_after_start') if $self->tag_exists('form_after_start');

    return $output
}

sub render_form_errors {
    my ( $self, $result ) = @_;

    return '' unless $result->has_form_errors;
    my $output = qq{\n<div class="form_errors">};
    $output .= qq{\n<span class="error_message">$_</span>}
        for $result->all_form_errors;
    $output .= "\n</div>";
    return $output;
}

sub render_end {
    my $self = shift;

    my $output = $self->get_tag('before_form_end') if $self->tag_exists('before_form_end');
    $output .= "</form>\n";
    if( $self->get_tag('form_wrapper') ) {
        my $form_wrapper_tag = $self->tag_exists('form_wrapper_tag') ? $self->get_tag('form_wrapper_tag') : 'fieldset';
        $output .= qq{</$form_wrapper_tag>};
    }
    $output .= $self->get_tag('form_after') if $self->tag_exists('form_after' );
    return $output;
}
use namespace::autoclean;
1;

