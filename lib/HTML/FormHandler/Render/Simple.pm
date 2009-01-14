package HTML::FormHandler::Render::Simple;

use Moose::Role;

requires ('sorted_fields', 'field');

our $VERSION = 0.01;

=head1 NAME

HTML::FormHandler::Render::Simple - Simple rendering routine

=head1 SYNOPSIS

This is a Moose role that is an example of a very simple rendering 
routine for L<HTML::FormHandler>. It has almost no features, but can
be used as an example for producing something more complex.
The idea is to produce your own custom rendering roles...

In your Form class:

   package MyApp::Form::Silly;
   extends 'HTML::FormHandler::Model::DBIC';
   with 'HTML::FormHandler::Render::Simple';

In a template:

   [% form.render %]

or for individual fields:
  
   [% form.field_render( 'title' ) %]


=head1 DESCRIPTION

This role provides HTML output routines for the 'widget' types
defined in the provided FormHandler fields. Each 'widget' name
has a 'widget_$name' method here.

These widget routines output strings with HTML suitable for displaying
form fields.

The widget for a particular field can be defined in the form. You can
create additional widget routines in your form for custom widgets.

=cut

=head2 render

To render all the fields in a form in sorted order (using
'sorted_fields' method). 

=cut

sub render
{
   my $self = shift;
   my $output;
   foreach my $field ($self->sorted_fields)
   {
      $output .= "\n<div>" . $self->render_field($field) . "</div>\n";
   }
   return $output;
}

=head2 render_field

Render a field passing in a field object or a field name

   $form->render_field( $field )
   $form->render_field( 'title' )

=cut

sub render_field
{
   my ( $self, $field ) = @_;
   unless ( $field->isa( 'HTML::FormHandler::Field' ) )
   {
      $field = $self->field( $field );
   }
   my $method = 'render_' . $field->widget;
   return $self->$method( $field );
}

=head2 render_text

Output an HTML string for a text widget

=cut

sub render_text
{
   my ( $self, $field ) = @_;
   # label
   my $fif = $field->fif || ''; 
   my $output .= "\n<label class=\"label\" for=\"";
   $output .= $field->name . "\">";
   $output .= $field->label . ":</label>";
   # input
   $output .= "<input type=\"text\" name=\"";
   $output .= $field->name . "\"";
   $output .= " id=\"" . $field->id . "\"";
   $output .= " value=\"" . $fif . "\">";
   # value
   return $output;
}

=head2 render_select

Output an HTML string for a 'select' widget, single or multiple

=cut

sub render_select
{
   my ( $self, $field ) = @_;

   my $fif = $field->fif || ''; 
   my $output = "<label class=\"label\" for=\"";
   $output .= $field->name . "\">" . $field->label . "</label>";
   $output .= "<select name=\"" . $field->name . "\""; 
   $output .= " multiple=\"multiple\" size=\"5\"" if $field->multiple == 1;
   $output .= "\">";
   foreach my $option ($field->options)
   {
      $output .= "<option value=\"" . $option->{value} ."\" ";
      
      if ( $fif )
      {
         if ( $field->multiple == 1 )
         {
            foreach my $optval ( @{$field->fif} )
            {
               $output .= " selected=\"selected\"" 
                     if $optval == $option->{value};
            }
         }
         else
         {
         $output .= "selected=\"selected\"" 
                if $option->{value} eq $fif;
         }
      }
      $output .= ">" . $option->{label} . "</option>";
   }
   $output .= "</select>";
   return $output;
}


=head2 render_checkbox

Output an HTML string for a 'checkbox' widget

The equivalent of:


=cut

sub render_checkbox
{
   my ( $self, $field ) = @_;
   
   my $fif = $field->fif || ''; 
   my $output = "<input type=\"checkbox\" name=\"";
   $output .= $field->name . "\" value=\"1\"";
   $output .= " checked=\"checked\"" if $fif eq '1';
   $output .= "/>";
   return $output;
}

=head2 render_radio

Output an HTML string for a 'radio' widget

=cut

sub render_radio
{
   my ( $self, $field ) = @_;

   my $output = "\n";
   my $fif = $field->fif || ''; 
   foreach my $option ($field->options)
   {
      $output = "<label class=\"label\" for=\"";
      $output .= $field->name . "\">" . $option->{label} . "</label>";
      $output .= "<input name=\"" . $field->name;
      $output .= " type=\"radio\" value=\"" . $option->{value} ."\"";
      $output .= " selected=\"selected\"" if $option->{value} eq $fif;
      $output .= " />\n";
   }
   return $output;
}

=head1 AUTHORS

Gerda Shank, gshank@cpan.org

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

