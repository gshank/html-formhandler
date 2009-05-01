package BookDB::Form::User;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'HTML::FormHandler::Render::Simple';
use DateTime;

has '+item_class' => ( default => 'User');

has_field 'user_name';
has_field 'fav_cat' => ( label => 'Favorite Book Category' );
has_field 'fav_book' => ( label => 'Favorite Book' );
has_field 'occupation';
has_field 'country' => ( type => 'Select' );
has_field 'birthdate' => ( 
    type => 'Compound',
    apply => [ { transform => sub{ DateTime->new( $_[0] ) } } ],
);
has_field 'birthdate.year' => ( type => 'Text', );
has_field 'birthdate.month' => ( type => 'Text', );
has_field 'birthdate.day' => ( type => 'Text', );

has_field 'address' => ( type => 'Compound' );
has_field 'address.street';
has_field 'address.city';
has_field 'address.state';


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
