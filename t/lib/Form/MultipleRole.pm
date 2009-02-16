package Form::MultipleRole;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';
with ('Form::PersonRole', 'Form::AddressRole');


no HTML::FormHandler::Moose;
1;
