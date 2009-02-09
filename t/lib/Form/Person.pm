package Form::Person;

use HTML::FormHandler::Moose; 
extends 'HTML::FormHandler';

has_field 'name';
has_field 'telephone';
has_field 'email';

use HTML::FormHandler::Moose;
1;
