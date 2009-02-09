package Form::Address;

use HTML::FormHandler::Moose; 
extends 'HTML::FormHandler';

has_field 'street';
has_field 'city';
has_field 'state';
has_field 'zip';

no HTML::FormHandler::Moose;
1;
