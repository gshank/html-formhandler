package HTML::FormHandler::Render::Table;

use Moose::Role;

with 'HTML::FormHandler::Render::Simple' => { excludes => [ 'render', 'render_field_struct' ] };

sub render
{
   my $self = shift;
   my $output = '<form ';
   $output .= 'action="' . $self->action . '" ' if $self->action;
   $output .= 'id="' . $self->name . '" ' if $self->name;
   $output .= 'name="' . $self->name . '" ' if $self->name;
   $output .= 'method="' . $self->http_method . '"' if $self->http_method;
   $output .= '>' . "\n";
   $output .= "<table>\n";

   foreach my $field ( $self->sorted_fields )
   {
      $output .= $self->render_field($field);
   }
   $output .= "</table>\n";
   $output .= "</form>\n";
   return $output;
}

sub render_field_struct
{
   my ( $self, $field, $method, $class ) = @_;
   my $output = qq{\n<tr$class>};
   my $l_type = defined $self->get_label_type( $field->widget ) ? $self->get_label_type( $field->widget ) : '';
   if( $l_type eq 'label' ){
       $output .= '<td>' . $self->_label( $field ) . '</td>';
   }
   elsif( $l_type eq 'legend' ){
       $output .= '<td>' . $self->_label( $field ) . '</td></tr>';
   }
   if( $l_type ne 'legend' ){
       $output .= '<td>';
   }
   $output .= $self->$method($field);
   $output .= qq{\n<span class="error_message">$_</span>} for $field->errors;
   if( $l_type ne 'legend' ){
       $output .= "</td></tr>\n";
   }
   return $output;
}

no Moose::Role;
1;


