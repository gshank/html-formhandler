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

You are advised to create a copy of this module for use in your
forms, since it is not possible to make improvements to this module
and maintain backwards compatibility.

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

=head2 render_start, render_end

Will render the beginning and ending <form> tags and fieldsets. Allows for easy
splitting up of the form if you want to hand-render some of the fields.

   [% form.render_start %]
   [% form.render_field('title') %]
   <insert specially rendered field>
   [% form.render_field('some_field') %]
   [% form.render_end %]

=head2 render_field

Render a field passing in a field object or a field name

   $form->render_field( $field )
   $form->render_field( 'title' )

=head2 render_text

Output an HTML string for a text widget

=head2 render_password

Output an HTML string for a password widget

=head2 render_hidden

Output an HTML string for a hidden input widget

=head2 render_select

Output an HTML string for a 'select' widget, single or multiple

=head2 render_checkbox

Output an HTML string for a 'checkbox' widget

=head2 render_radio_group

Output an HTML string for a 'radio_group' selection widget.
This widget should be for a field that inherits from 'Select',
since it requires the existance of an 'options' array.

=head2 render_textarea

Output an HTML string for a textarea widget

=head2 render_compound

Renders field with 'compound' widget

=head2 render_submit

Renders field with 'submit' widget

=cut


has 'auto_fieldset' => ( isa => 'Bool', is => 'rw', default => 1 );
has 'label_types' => (
   metaclass  => 'Collection::Hash',
   isa        => 'HashRef[Str]',
   is         => 'rw',
   default    => sub { {
           text => 'label', password => 'label', 'select' => 'label',  checkbox => 'label', textarea => 'label',
           radio_group => 'label', compound => 'legend'
       }
   },
   auto_deref => 1,
   provides   => {
       get       => 'get_label_type',
   },
);

sub render
{
   my $self = shift;
   my $output = $self->render_start;

   foreach my $field ( $self->sorted_fields )
   {
      $output .= $self->render_field($field);
   }

   $output .= $self->render_end;
   return $output;
}

sub render_start
{
   my $self = shift;
   my $output = '<form ';
   $output .= 'action="' . $self->action . '" ' if $self->action;
   $output .= 'id="' . $self->name . '" ' if $self->name;
   $output .= 'method="' . $self->http_method . '"' if $self->http_method;
   $output .= '>' . "\n";
   $output .= '<fieldset class="main_fieldset">' if $self->auto_fieldset;
   return $output;
}

sub render_end
{
   my $self = shift;
   my $output;
   $output .= '</fieldset>' if $self->auto_fieldset;
   $output .= "</form>\n";
   return $output;
}


sub render_field {
    my( $self, $field ) = @_;
    unless ( $field->isa('HTML::FormHandler::Field') )
    {
       $field = $self->field($field);
    }
    return '' if $field->widget eq 'no_render';
    my $field_method = 'render_' . $field->widget;
    die "Widget method $field_method not implemented in H::F::Render::Simple"
      unless $self->can($field_method);
    my $class = '';
    if( $field->css_class || $field->has_errors )
    {
       $class .= ' class="';
       $class .= $field->css_class . ' ' if $field->css_class;
       $class .= ' error"' if $field->has_errors;
    }
    return $self->render_field_struct($field, $field_method, $class);
}

sub render_field_struct
{
   my ( $self, $field, $method, $class ) = @_;
   my $output = qq{\n<div$class>};
   my $l_type = defined $self->get_label_type( $field->widget ) ? $self->get_label_type( $field->widget ) : '';
   if( $l_type eq 'label' ){
       $output .= $self->_label( $field );
   }
   elsif( $l_type eq 'legend' ){
       $output .= '<fieldset class="' . $field->html_name . '">';
       $output .= '<legend>' . $field->label . '</legend>';
   }
   $output .= $self->$method($field);
   $output .= qq{\n<span class="error_message">$_</span>} for $field->errors;
   if( $l_type eq 'legend' ){
       $output .= '</fieldset>';
   }
   $output .= "</div>\n";
   return $output;
}

sub render_text
{
   my ( $self, $field ) = @_;
   my $output = '<input type="text" name="';
   $output .= $field->html_name . '"';
   $output .= ' id="' . $field->id . '"';
   $output .= ' size="' . $field->size . '"' if $field->size;
   $output .= ' maxlength="' . $field->maxlength. '"' if $field->maxlength;
   $output .= ' value="' . $field->fif . '" />';
   return $output;
}

sub render_password
{
   my ( $self, $field ) = @_;
   my $output = '<input type="password" name="';
   $output .= $field->html_name . '"';
   $output .= ' id="' . $field->id . '"';
   $output .= ' size="' . $field->size . '"' if $field->size;
   $output .= ' maxlength="' . $field->maxlength. '"' if $field->maxlength;
   $output .= ' value="' . $field->fif . '" />';
   return $output;
}

sub render_hidden
{
   my ( $self, $field ) = @_;
   my $output = '<input type="hidden" name="';
   $output .= $field->html_name . '"';
   $output .= ' id="' . $field->id . '"';
   $output .= ' value="' . $field->fif . '" />';
   return $output;
}

sub render_select
{
   my ( $self, $field ) = @_;

   my $output = '<select name="' . $field->html_name . '"';
   $output .= ' id="' . $field->id . '"';
   $output .= ' multiple="multiple"' if $field->multiple == 1;
   $output .= ' size="' . $field->size . '"' if $field->size;
   $output .= '>';
   my $index = 0;
   foreach my $option ( $field->options )
   {
      $output .= '<option value="' . $option->{value} . '" ';
      $output .= 'id="' . $field->id . ".$index\" ";
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
               $output .= 'selected="selected"'
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
      $index++;
   }
   $output .= '</select>';
   return $output;
}

sub render_checkbox
{
   my ( $self, $field ) = @_;

   my $output = '<input type="checkbox" name="';
   $output .= $field->html_name . '" id="' . $field->id . '" value="' . $field->checkbox_value . '"';
   $output .= ' checked="checked"' if $field->fif eq $field->checkbox_value;
   $output .= ' />';
   return $output;
}


sub render_radio_group
{
   my ( $self, $field ) = @_;

   my $output = " <br />";
   my $index = 0;
   foreach my $option ( $field->options )
   {
      $output .= '<input type="radio" value="' . $option->{value} . '"';
      $output .= ' name="' . $field->html_name . '" id="' . $field->id . ".$index\"";
      $output .= ' checked="checked"' if $option->{value} eq $self->fif;
      $output .= ' />';
      $output .= $option->{label} . '<br />';
      $index++;
   }
   return $output;
}

sub render_textarea
{
   my ( $self, $field ) = @_;
   my $fif   = $field->fif || '';
   my $id    = $field->id;
   my $cols  = $field->cols || 10;
   my $rows  = $field->rows || 5;
   my $name  = $field->html_name;

   my $output = qq(<textarea name="$name" id="$id" )
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

sub render_compound
{
   my ( $self, $field ) = @_;

   my $output = '';
   foreach my $subfield ($field->sorted_fields)
   {
      $output .= $self->render_field($subfield);
   }
   return $output;
}

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

See CONTRIBUTORS in L<HTML::FormHandler>

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

no Moose::Role;
1;


