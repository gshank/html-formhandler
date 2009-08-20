package HTML::FormHandler::Result;

use Moose;
with 'HTML::FormHandler::Role::Result';
# this will be the form result object.

has 'form' => ( isa => 'HTML::FormHandler', is => 'ro' );



1;
