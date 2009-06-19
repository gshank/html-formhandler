package HTML::FormHandler::Render::Simple;

use Moose::Role;
use HTML::Entities;

requires( 'sorted_fields', 'field' );

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
   use Moose;
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

has 'auto_fieldset' => ( isa => 'Bool', is => 'rw', default => 1 );

sub render
{
   my $self = shift;
   my $output = '<form ';
   $output .= 'action="' . $self->action . '" ' if $self->action;
   $output .= 'id="' . $self->name . '" ' if $self->name;
   $output .= 'method="' . $self->http_method . '"' if $self->http_method;
   $output .= '>' . "\n";
   $output .= '<fieldset class="main_fieldset">' if $self->auto_fieldset;

   foreach my $field ( $self->sorted_fields )
   {
      $output .= $self->render_field($field);
   }
   $output .= '</fieldset>' if $self->auto_fieldset;
   $output .= "</form>\n";
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
   unless ( $field->isa('HTML::FormHandler::Field') )
   {
      $field = $self->field($field);
   }
   my $method = 'render_' . $field->widget;
   die "Widget method $method not implemented in H::F::Render::Simple"
      unless $self->can($method);
   my $class = '';
   if( $field->css_class || $field->has_errors )
   {
      $class .= ' class="';
      $class .= $field->css_class . ' ' if $field->css_class;
      $class .= ' error"' if $field->has_errors;
   }
   my $output = qq{\n<div$class>};
   $output .= $self->$method($field);
   $output .= qq{\n<span class="error_message">$_</span>} for $field->errors;
   $output .= "</div>\n";
   return $output;
}

=head2 render_text

Output an HTML string for a text widget

=cut

sub render_text
{
   my ( $self, $field ) = @_;
   # label
   my $output = $self->_label( $field );
   # input
   $output .= '<input type="text" name="';
   $output .= $field->html_name . '"';
   $output .= ' id="' . $field->id . '"';
   $output .= ' value="' . $field->fif . '" />';
   # value
   return $output;
}

=head2 render_password

Output an HTML string for a password widget

=cut

sub render_password
{
   my ( $self, $field ) = @_;
   # label
   my $output = $self->_label( $field );
   # input
   $output .= '<input type="password" name="';
   $output .= $field->html_name . '"';
   $output .= ' id="' . $field->id . '"';
   $output .= ' value="' . $field->fif . '" />';
   # value
   return $output;
}

=head2 render_hidden

Output an HTML string for a hidden input widget

=cut

sub render_hidden
{
   my ( $self, $field ) = @_;
   # input
   my $output = '<input type="hidden" name="';
   $output .= $field->html_name . '"';
   $output .= ' id="' . $field->id . '"';
   $output .= ' value="' . $field->fif . '" />';
   # value
   return $output;
}

=head2 render_select

Output an HTML string for a 'select' widget, single or multiple

=cut

sub render_select
{
   my ( $self, $field ) = @_;

   my $output = $self->_label( $field );
   $output .= '<select name="' . $field->html_name . '"';
   $output .= ' id="' . $field->id . '"';
   $output .= ' multiple="multiple"' if $field->multiple == 1; 
   $output .= ' size="' . $field->size . '"' if $field->size;
   $output .= '>';
   foreach my $option ( $field->options )
   {
      $output .= '<option value="' . $option->{value} . '" ';

      if ($field->fif)
      {
         if ( $field->multiple == 1 )
         {
            my @fif;
            if( ref  $field->fif ){
                @fif = @{ $field->fif };
            }
            else{
                @fif = ( $field->fif );
            }
            foreach my $optval ( @fif )
            {
               $output .= ' selected="selected"'
                  if $optval == $option->{value};
            }
         }
         else
         {
            $output .= 'selected="selected"'
               if $option->{value} eq $field->fif;
         }
      }
      $output .= '>' . $option->{label} . '</option>';
   }
   $output .= '</select>';
   return $output;
}

=head2 render_checkbox

Output an HTML string for a 'checkbox' widget

The equivalent of:


=cut

sub render_checkbox
{
   my ( $self, $field ) = @_;

   my $output = $self->_label( $field );
   $output .= '<input type="checkbox" name="';
   $output .= $field->html_name . '" id="' . $field->id . '" value="' . $field->checkbox_value . '"';
   $output .= ' checked="checked"' if $field->fif eq $field->checkbox_value;
   $output .= ' />';
   return $output;
}


=head2 render_radio_group

Output an HTML string for a 'radio_group' selection widget.
This widget should be for a field that inherits from 'Select',
since it requires the existance of an 'options' array.

=cut

sub render_radio_group
{
   my ( $self, $field ) = @_;

   my $output = "\n";
   $output .= $self->_label($field) . " <br />";
   foreach my $option ( $field->options )
   {
      $output .= '<input type="radio" value="' . $option->{value} . '"';
      $output .= ' name="' . $field->html_name . '" id="' . $field->id . '"';
      $output .= ' selected="selected"' if $option->{value} eq $self->fif;
      $output .= ' />';
      $output .= $option->{label} . '<br />';
   }
   return $output;
}

=head2 render_textarea

Output an HTML string for a textarea widget

=cut

sub render_textarea
{
   my ( $self, $field ) = @_;
   my $fif   = $field->fif || '';
   my $id    = $field->id;
   my $cols  = $field->cols || 10;
   my $rows  = $field->rows || 5;
   my $name  = $field->html_name;

   my $output = $self->_label( $field )
      . qq(<textarea name="$name" id="$id" )
      . qq(rows="$rows" cols="$cols">$fif</textarea>);

   return $output;
}

sub _label
{
   my ( $self, $field ) = @_;
   return '<label class="label" for="' 
   . $field->id
   . '">'
   . $field->label 
   . ': </label>'
}

=head2 render_compound

Renders field with 'compound' widget

=cut

sub render_compound
{
   my ( $self, $field ) = @_;

   my $output = '<fieldset class="' . $field->html_name . '">';
   $output .= '<legend>' . $field->label . '</legend>';
   foreach my $subfield ($field->sorted_fields)
   {
      $output .= $self->render_field($subfield);
   }
   $output .= '</fieldset>';
}

=head2 render_submit

Renders field with 'submit' widget

=cut

sub render_submit
{
   my ( $self, $field ) = @_;
   my $fif = $field->fif || '';
   my $output = '<input type="submit" name="';
   $output .= $field->html_name . '"';
   $output .= ' id="' . $field->id . '"';
   $output .= ' value="' . $fif . '" />';
   return $output;
}

=head1 AUTHORS

Gerda Shank, gshank@cpan.org

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;


