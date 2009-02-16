package Form::MultipleRole;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';
with 'Form::PersonRole';
with 'Form::AddressRole';


no HTML::FormHandler::Moose;
1;
