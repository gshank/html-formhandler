package BookDB::Form::User2;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'HTML::FormHandler::Render::Simple';

has_field 'birthdate' => ( 
    type => 'Compound',
    apply => [ { transform => sub{ DateTime->new( $_[0] ) } } ],
    deflations => [ sub { { year => 1000, month => 1, day => 1 } } ],
);
has_field 'birthdate.year';
has_field 'birthdate.month';
has_field 'birthdate.day' => (
    deflations => [ sub { $_[0] + 4 } ],
);


no HTML::FormHandler::Moose;
1;
