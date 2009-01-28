package Form::Test;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has '+name' => ( default => 'TestForm');

has_field 'reqname' => ( type => 'Text', required => 1 );
has_field 'optname' => ( type => 'Text' );
has_field 'fruit' => ( type => 'Select' );


sub options_fruit {
    return (
        1   => 'apples',
        2   => 'oranges',
        3   => 'kiwi',
    );
}

no HTML::FormHandler::Moose;
1;

