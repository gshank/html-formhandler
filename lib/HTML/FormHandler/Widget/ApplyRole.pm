package HTML::FormHandler::Widget::ApplyRole;

use Moose::Role;
use File::Spec;

our $ERROR;

sub apply_widget_role
{
   my ( $self, $target, $widget_name, $dir ) = @_;

   my $widget_name_space = $self->widget_name_space;
   $dir = $dir ? '::' . $dir . '::' : '::';
   my @name_spaces;
   push @name_spaces, ref $widget_name_space ? @{$widget_name_space} : $widget_name_space
      if $widget_name_space;
   push @name_spaces, 'HTML::FormHandler::Widget';
   my $meta;
   foreach my $ns (@name_spaces) {
      my $render_role = $ns . $dir . $self->widget_class($widget_name);
      if ( try_load_class($render_role) ) {
         $target->meta->make_mutable;
         $render_role->meta->apply($target);
         $target->meta->make_immutable;
         last;
      }
   }
}

# this is for compatibility with widget names like 'radio_group'
# RadioGroup, Textarea, etc. also work
sub widget_class
{
   my ( $self, $widget ) = @_;
   return unless $widget;
   $widget =~ s/^(\w{1})/\u$1/g;
   $widget =~ s/_(\w{1})/\u$1/g;
   return $widget;
}

# stolen from Load::Class
# which has been broken on 5.10 for months
sub try_load_class
{
   my $class = shift;
   undef $ERROR;
   return 1 if is_class_loaded($class);
   # see rt . perl . org    #19213
   my @parts = split '::', $class;
   my $file =
      $^O eq 'MSWin32' ?
      join '/', @parts :
      File::Spec->catfile(@parts);
   $file .= '.pm';

   return 1 if eval {
      local $SIG{__DIE__} = 'DEFAULT';
      require $file;
      1;
   };

   $ERROR = $@;
   return 0;
}
sub is_class_loaded
{
   my $class = shift;
   # is the module's file in %INC?
   my $file = (join '/', split '::', $class) . '.pm';
   return 1 if $INC{$file};
}

1;
