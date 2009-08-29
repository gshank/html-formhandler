package HTML::FormHandler::Widget::Wrapper::Div;

use Moose::Role;

has 'auto_fieldset' => ( isa => 'Bool', is => 'rw', default => 1 );
has 'label_types' => (
   metaclass => 'Collection::Hash',
   isa       => 'HashRef[Str]',
   is        => 'rw',
   builder   => 'build_label_types',
   provides   => { get => 'get_label_type', },
);
sub build_label_types
{
   {
      text        => 'label',
      password    => 'label',
      select      => 'label',
      checkbox    => 'label',
      textarea    => 'label',
      radio_group => 'label',
      compound    => 'legend'
   };
}

sub render_label
{
   my $self = shift;
   return '<label class="label" for="' . $self->id . '">' . $self->label . ': </label>';
}

sub render_class
{
   my ( $self, $result ) = @_;

   $result ||= $self->result;
   my $class = '';
   if ( $self->css_class || $result->has_errors ) {
      $class .= ' class="';
      $class .= $self->css_class . ' ' if $self->css_class;
      $class .= ' error"' if $result->has_errors;
   }
   return $class;
}


sub render_field
{
   my ( $self, $result, $rendered_widget ) = @_;

   my $class = $self->render_class( $result );
   my $output = qq{\n<div$class>};
   # couldn't get the label_type hashref to work; it kept getting garbage 
   # collected (I think). At least it ended up undef when that wasn't valid...
   my $test = $self->get_label_type($self->widget);
   if ( $self->widget eq 'compound' ) {
      $output .= '<fieldset class="' . $self->html_name . '">';
      $output .= '<legend>' . $self->label . '</legend>';
   }
   elsif ( !$self->has_flag('no_render_label') ) {
      $output .= $self->render_label;
   }
   $output .= $rendered_widget;
   $output .= qq{\n<span class="error_message">$_</span>} for $result->errors;
   if ( $self->widget eq 'compound' ) {
      $output .= '</fieldset>';
   }
   $output .= "</div>\n";
   return $output;
}

1;
