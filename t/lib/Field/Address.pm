package Field::Address;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Compound';

has_field 'street';
has_field 'city';
has_field 'country';


no HTML::FormHandler::Moose;
1;
