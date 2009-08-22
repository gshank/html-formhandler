package HTML::FormHandler::Render::Result;

use Moose::Role;
use HTML::Entities;


our $VERSION = 0.01;

=head1 NAME

HTML::FormHandler::Render::Result - rendering routine for Result object

=head1 SYNOPSIS

This is a temporary solution for rendering from the Result object. Should
be combined with Render::Simple somehow

=cut

has 'auto_fieldset' => ( isa => 'Bool', is => 'rw', default => 1 );
has 'label_types' => (
   metaclass => 'Collection::Hash',
   isa       => 'HashRef[Str]',
   is        => 'rw',
   default   => sub {
      {
         text        => 'label',
         password    => 'label',
         'select'    => 'label',
         checkbox    => 'label',
         textarea    => 'label',
         radio_group => 'label',
         compound    => 'legend'
      };
   },
   auto_deref => 1,
   provides   => { get => 'get_label_type', },
);

sub render
{
   my $self   = shift;
   my $output = $self->form->render_start;

   foreach my $field ( $self->form->sorted_fields ) {
      $output .= $self->render_field( $field->name );
   }

   $output .= $self->render_end;
   return $output;
}

sub render_start
{
   my $self   = shift;
   my $output = '<form ';
   $output .= 'action="' . $self->form->action . '" '     if $self->form->action;
   $output .= 'id="' . $self->name . '" '           if $self->name;
   $output .= 'method="' . $self->form->http_method . '"' if $self->form->http_method;
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

sub render_field
{
   my ( $self, $field_name ) = @_;

   my $field = $self->field($field_name);
   die "Field $field not found"
      unless ( defined $field && $field->isa('HTML::FormHandler::Field::Result') );
   my $field_def = $field->field_def;
   return '' if $field_def->widget eq 'no_render';
   my $rendered_field;
   if ( $field_def->widget eq 'from_field' ) {
#      $rendered_field = $field->render;
#  
   }
   else {
      my $form_render = 'render_' . $field_def->widget;
      die "Widget method $form_render not implemented in H::F::Render::Result"
         unless $self->can($form_render);
      $rendered_field = $self->$form_render($field);
   }
   my $class = '';
   if ( $field->field_def->css_class || $field->has_errors ) {
      $class .= ' class="';
      $class .= $field_def->css_class . ' ' if $field_def->css_class;
      $class .= ' error"' if $field->has_errors;
   }
   return $self->render_field_struct( $field, $rendered_field, $class );
}

sub render_field_struct
{
   my ( $self, $field, $rendered_field, $class ) = @_;
   my $field_def = $field->field_def;
   my $output = qq{\n<div$class>};
   my $l_type =
      defined $self->get_label_type( $field_def->widget ) ?
      $self->get_label_type( $field_def->widget ) :
      '';
   if ( $l_type eq 'label' ) {
      $output .= $self->_label($field);
   }
   elsif ( $l_type eq 'legend' ) {
      $output .= '<fieldset class="' . $field_def->html_name . '">';
      $output .= '<legend>' . $field_def->label . '</legend>';
   }
   $output .= $rendered_field;
   $output .= qq{\n<span class="error_message">$_</span>} for $field->errors;
   if ( $l_type eq 'legend' ) {
      $output .= '</fieldset>';
   }
   $output .= "</div>\n";
   return $output;
}

sub render_text
{
   my ( $self, $field ) = @_;
   my $field_def = $field->field_def;
   my $output = '<input type="text" name="';
   $output .= $field_def->html_name . '"';
   $output .= ' id="' . $field_def->id . '"';
   $output .= ' size="' . $field_def->size . '"' if $field_def->size;
   $output .= ' maxlength="' . $field_def->maxlength . '"' if $field_def->maxlength;
   $output .= ' value="' . $field->fif . '" />';
   return $output;
}

sub render_password
{
   my ( $self, $field ) = @_;
   my $field_def => $field->field_def;
   my $output = '<input type="password" name="';
   $output .= $field->field_def->html_name . '"';
   $output .= ' id="' . $field_def->id . '"';
   $output .= ' size="' . $field_def->size . '"' if $field_def->size;
   $output .= ' maxlength="' . $field_def->maxlength . '"' if $field_def->maxlength;
   $output .= ' value="' . $field->fif . '" />';
   return $output;
}

sub render_hidden
{
   my ( $self, $field ) = @_;
   my $field_def = $field->field_def;
   my $output = '<input type="hidden" name="';
   $output .= $field_def->html_name . '"';
   $output .= ' id="' . $field_def->id . '"';
   $output .= ' value="' . $field->fif . '" />';
   return $output;
}

sub render_select
{
   my ( $self, $field ) = @_;

   my $field_def = $field->field_def;
   my $output = '<select name="' . $field_def->html_name . '"';
   $output .= ' id="' . $field_def->id . '"';
   $output .= ' multiple="multiple"' if $field_def->multiple == 1;
   $output .= ' size="' . $field_def->size . '"' if $field_def->size;
   $output .= '>';
   my $index = 0;
   foreach my $option ( @{$field_def->{options}} ) {
      $output .= '<option value="' . $option->{value} . '" ';
      $output .= 'id="' . $field_def->id . ".$index\" ";
      if ( my $ffif = $field->fif ) {
         if ( $field_def->multiple == 1 ) {
            my @fif;
            if ( ref $ffif ) {
               @fif = @{ $ffif };
            }
            else {
               @fif = ( $ffif );
            }
            foreach my $optval (@fif) {
               $output .= 'selected="selected"'
                  if $optval == $option->{value};
            }
         }
         else {
            $output .= 'selected="selected"'
               if $option->{value} eq $ffif;
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

   my $field_def = $field->field_def;
   my $fif = $field->fif;
   my $output = '<input type="checkbox" name="';
   $output .=
      $field_def->html_name . '" id="' . $field_def->id . '" value="' . $field_def->checkbox_value . '"';
   $output .= ' checked="checked"' if $fif eq $field_def->checkbox_value;
   $output .= ' />';
   return $output;
}

sub render_radio_group
{
   my ( $self, $field ) = @_;

   my $field_def = $field->field_def;
   my $output = " <br />";
   my $index  = 0;
   foreach my $option ( $field_def->options ) {
      $output .= '<input type="radio" value="' . $option->{value} . '"';
      $output .= ' name="' . $field_def->html_name . '" id="' . $field_def->id . ".$index\"";
      $output .= ' checked="checked"' if $option->{value} eq $field->fif;
      $output .= ' />';
      $output .= $option->{label} . '<br />';
      $index++;
   }
   return $output;
}

sub render_textarea
{
   my ( $self, $field ) = @_;

   my $field_def = $field->field_def;
   my $fif  = $field->fif || '';
   my $id   = $field_def->id;
   my $cols = $field_def->cols || 10;
   my $rows = $field_def->rows || 5;
   my $name = $field_def->html_name;

   my $output =
      qq(<textarea name="$name" id="$id" ) . qq(rows="$rows" cols="$cols">$fif</textarea>);

   return $output;
}

sub _label
{
   my ( $self, $field ) = @_;
   return '<label class="label" for="' . $field->field_def->id . '">' . $field->field_def->label . ': </label>';
}

sub render_compound
{
   my ( $self, $field ) = @_;

   my $output = '';
   my $field_def = $field->field_def;
   foreach my $subfield ( $field_def->sorted_fields ) {
      my $subresult = $field->field($subfield->name);
      next unless $subresult;
      $output .= $self->render_field($subfield->full_name);
   }
   return $output;
}

sub render_submit
{
   my ( $self, $field ) = @_;

   my $field_def = $field->field_def;
   my $output = '<input type="submit" name="';
   $output .= $field_def->html_name . '"';
   $output .= ' id="' . $field_def->id . '"';
   $output .= ' value="' . $field_def->value . '" />';
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

