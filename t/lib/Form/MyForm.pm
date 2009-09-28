package Form::MyForm;
use strict;
use warnings;

use HTML::FormHandler;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has_field 'optname' => ( min_length => 5, required => 1 );
