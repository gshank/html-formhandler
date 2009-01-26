package  # hide from Pause
    HTML::FormHandler::Meta::Class;
use Moose;
extends 'Moose::Meta::Class';

has 'field_list' => ( is => 'rw' );

no Moose;
1;
