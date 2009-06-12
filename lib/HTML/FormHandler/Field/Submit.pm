package HTML::FormHandler::Field::Submit;

use Moose;
extends 'HTML::FormHandler::Field';

has 'value' => (
   is        => 'rw',
   predicate => 'has_value',
   default => 'Save'
);

has '+widget' => ( default => 'submit' );
has '+writeonly' => ( default => 1 );

sub validate_field { }

sub clear_value { }

__PACKAGE__->meta->make_immutable;
no Moose;
1;
