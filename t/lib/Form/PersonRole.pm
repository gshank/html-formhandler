package Form::PersonRole;

use HTML::FormHandler::Moose::Role;

has_field 'name';
has_field 'telephone';
has_field 'email';

no HTML::FormHandler::Moose::Role;
1;
