package Form::Two;

use HTML::FormHandler::Moose;
extends 'Form::Test';

has '+name' => ( default => 'FormTwo' );
has_field 'new_field' => ( required => 1 );
has_field 'optname' => ( required => 1, temp => 'Txxt' );

no HTML::FormHandler::Moose;
1;
