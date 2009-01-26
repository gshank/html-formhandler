package Form::Test;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has_field 'reqname' => ( type => 'Text', required => 1 );
has_field 'optname' => ( type => 'Text' );
has_field 'fruit' => ( type => 'Select' );

has 'name' => ( isa => 'Str', is => 'rw', default => 'TestForm');

sub options_fruit {
    return (
        1   => 'apples',
        2   => 'oranges',
        3   => 'kiwi',
    );
}

no HTML::FormHandler::Moose;
1;

