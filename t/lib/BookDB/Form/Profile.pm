package BookDB::Form::Profile;

extends 'HTML::FormHandler';

has_field 'username';
has_field 'fav_cat' => ( label => 'Favorite Book Category' );
has_field 'fav_book' => ( label => 'Favorite Book' );
has_field 'occupation';


no 'HTML::FormHandler';
1;
