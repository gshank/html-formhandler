package HTML::FormHandler::Field::Result;

use Moose;

has 'name' => ( isa => 'Str', is => 'rw', required => 1 );

# do we need 'accessor' ?
has 'parent' => ( is =>'rw' );

has 'input' => (
   is        => 'rw',
   clearer   => '_clear_input',
   writer    => '_set_input',
   predicate => 'has_input',
);
   
has 'value' => (
   is        => 'rw',
   writer    => '_set_value',
   clearer   => '_clear_value',
   predicate => 'has_value',
);

has 'errors'     => (
   metaclass  => 'Collection::Array',
   isa        => 'ArrayRef[Str]',
   is         => 'rw',
   auto_deref => 1,
   default    => sub { [] },
   provides   => {
      'push'  => 'push_errors',
      'count' => 'num_errors',
      'empty' => 'has_errors',
      'clear' => 'clear_errors',
   }
);

has 'children'     => (
   metaclass  => 'Collection::Array',
   isa        => 'ArrayRef[HTML::FormHandler::Field::Result]',
   is         => 'rw',
   auto_deref => 1,
   default    => sub { [] },
   provides   => {
      'push'  => 'add_child',
      'count' => 'num_children',
      'empty' => 'has_children',
      'clear' => 'clear_children',
   }
);
sub validated { !$_[0]->has_errors && $_[0]->has_input  }
sub ran_validation { shift->has_input }

has 'init_value'       => ( is  => 'rw',   clearer   => 'clear_init_value' );

sub field
{
   my ( $self, $name, $die ) = @_;

   my $index;
   # if this is a full_name for a compound field
   # walk through the fields to get to it
   if ( $name =~ /\./ ) {
      my @names = split /\./, $name;
      my $f = $self;
      foreach my $fname (@names) {
         $f = $f->field($fname);
         return unless $f;
      }
      return $f;
   }
   else    # not a compound name
   {
      for my $field ( $self->children ) {
         return $field if ( $field->name eq $name );
      }
   }
   return unless $die;
   die "Field '$name' not found in '$self'";
}

1;
