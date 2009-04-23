package Form::Two;

use HTML::FormHandler::Moose;
extends 'Form::Test';

has '+name' => ( default => 'FormTwo' );
has_field 'new_field' => ( required => 1 );
has_field 'optname' => ( temp => 'Txxt' );
has_field '+reqname' => ( temp => 'Abc' );

no HTML::FormHandler::Moose;
1;
