package Form::AddressRole;

use HTML::FormHandler::Moose::Role;

has_field 'street';
has_field 'city';
has_field 'state';
has_field 'zip';

no HTML::FormHandler::Moose::Role;
1;
