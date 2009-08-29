package HTML::FormHandler::Widget::Form::Div;

use Moose::Role;
use HTML::Entities;


our $VERSION = 0.01;

=head1 NAME

HTML::FormHandler::Widget::Form::Div

=head1 SYNOPSIS

Role to apply to form objects to 

=cut

has 'auto_fieldset' => ( isa => 'Bool', is => 'rw', default => 1 );

sub render
{
   my ( $self ) = @_;

   my $result;
   my $form;
   if( $self->DOES('HTML::FormHandler::Result') ) {
      $result = $self;
      $form = $self->form;
   }
   else {
      $result = $self->result; 
      $form = $self;
   }
   my $output = $form->render_start;

   foreach my $field ( $form->sorted_fields ) {
      my $fld_result;
      if( $field->has_flag('has_static_value') ) {
         $fld_result = $field->result;
      }
      else {
         $fld_result = $result->field($field->name);
      }
      die "no result for " . $field->name unless $fld_result;
      $output .= $field->render($fld_result);
   }

   $output .= $self->render_end;
   return $output;
}

sub render_start
{
   my $self   = shift;
   my $output = '<form ';
   $output .= 'action="' . $self->action . '" '     if $self->action;
   $output .= 'id="' . $self->name . '" '           if $self->name;
   $output .= 'method="' . $self->http_method . '"' if $self->http_method;
   $output .= '>' . "\n";
   $output .= '<fieldset class="main_fieldset">'    if $self->form->auto_fieldset;
   return $output;
}

sub render_end
{
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

no Moose::Role;
1;

