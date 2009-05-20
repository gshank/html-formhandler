package HTML::FormHandler::Field::PrimaryKey;

use Moose;
extends 'HTML::FormHandler::Field';

has 'is_primary_key' => ( isa => 'Bool', is => 'ro', default => '1' );
has '+widget' => ( default => 'hidden' );

1;
