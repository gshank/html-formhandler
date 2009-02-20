package BookDB::Form::User;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';
with 'HTML::FormHandler::Render::Simple';

has_field 'user_name';
has_field 'fav_cat' => ( label => 'Favorite Book Category' );
has_field 'fav_book' => ( label => 'Favorite Book' );
has_field 'occupation';

sub validate_occupation
{
   my ( $self, $field ) = @_;
   if ( $field->value eq 'layabout' )
   {
      $field->add_error('No layabouts allowed');
   }
}

no HTML::FormHandler::Moose;
1;
