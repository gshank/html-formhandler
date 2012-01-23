package Test::NoExtForm;
use Moose;
use HTML::FormHandler::Moose;

has_field 'foo';
has_field 'bar';

1;
