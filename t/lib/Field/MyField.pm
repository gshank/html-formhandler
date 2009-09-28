package Field::MyField;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Text';

has '+widget'           => ( default => 'password' );
has '+min_length'       => ( default => 6 );

__PACKAGE__->meta->make_immutable;
no Moose;
1;
