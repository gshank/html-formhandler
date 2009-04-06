{ 
    package BookDB::Form::BookOwner;

    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Field::Compound';
#    with 'HTML::FormHandler::Model::DBIC';
    
#    has '+item_class' => ( default => 'User' );
    
    has_field 'user_name';
    has_field 'fav_cat' => ( label => 'Favorite Book Category' );
    has_field 'fav_book' => ( label => 'Favorite Book' );
    has_field 'occupation';
    has_field 'country' => ( type => 'Select' );
    
    sub validate_occupation
    {
       my ( $self, $field ) = @_;
       if ( $field->value eq 'layabout' )
       {
          $field->add_error('No layabouts allowed');
       }
    }
}

{ 
    package BookDB::Form::BookWithOwner;

    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Model::DBIC';
    
    has '+item_class' => ( default => 'Author' );
    
    has_field 'title' => ( type => 'Text', required => 1 );
    has_field 'publisher' => ( type => 'Text', required => 1 );
    has_field 'owner' => ( type => '+BookDB::Form::BookOwner' );
}
    

   
1;
