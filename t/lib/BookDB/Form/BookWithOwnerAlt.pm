{ 
    package BookDB::Field::BookOwnerAlt;

    use Moose;
    extends 'HTML::FormHandler::Field::Compound';
    with 'BookDB::Form::Role::BookOwner';
}

{ 
    package BookDB::Form::BookWithOwnerAlt;

    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Model::DBIC';
    
    has '+item_class' => ( default => 'Author' );
    
    has_field 'title' => ( type => 'Text', required => 1 );
    has_field 'publisher' => ( type => 'Text', required => 1 );
    has_field 'owner' => ( type => '+BookDB::Field::BookOwner' );
}
    
{
   package BookDB::Form::BookOwnerAlt;

   use Moose;
   extends 'HTML::FormHandler::Form::DBIC';
   with 'BookDB::Form::Role::BookOwner';

}
   
1;
