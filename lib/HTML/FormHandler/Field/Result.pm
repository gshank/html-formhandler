package HTML::FormHandler::Field::Result;

use Moose;
with 'HTML::FormHandler::Role::Result';


has 'init_value'       => ( is  => 'rw',   clearer   => 'clear_init_value' );


1;
