package BookDB::Form::BookHTML;
use Moose;
extends 'HTML::FormHandler::Model::DBIC';


has '+item_class' => ( default => 'Book' );
has '+name' => ( default => 'book' );
has '+html_prefix' => ( default => 1 );

sub field_list {
     [
         title     => {
            type => 'Text',
            required => 1,
         },
         author    => 'Text',
         pages     => 'Integer',
         year      => 'Integer',
     ]
}

1;
