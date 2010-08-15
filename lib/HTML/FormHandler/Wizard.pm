package HTML::FormHandler::Wizard;
# ABSTRACT: create a multi-page form

use Moose;
extends 'HTML::FormHandler';

with ('HTML::FormHandler::BuildPages', 'HTML::FormHandler::Pages' );

sub is_wizard {1}

1;
