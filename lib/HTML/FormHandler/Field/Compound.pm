package HTML::FormHandler::Field::Compound;

use Moose;
use MooseX::AttributeHelpers;
extends 'HTML::FormHandler::Field';

has '+widget' => ( default => 'compound' );

has 'children' => ( isa => 'ArrayRef', 
   is => 'rw',
   metaclass => 'Collection::Array',
   auto_deref => 1,
   default => sub {[]},
   provides => {
      push => 'add_child',
      empty => 'has_children',
      clear => 'clear_children',
   }
);

augment 'validate_field' => sub {
   shift->clear_fif;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;
