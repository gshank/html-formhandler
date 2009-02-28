use Test::More tests => 6;

use_ok( 'HTML::FormHandler::Params' );

my $p1 = {
   'book.author' => 'J.Doe',
   'book.title' =>  'Doing something',
   'book.date' => '2002',
};

my $p1_exp = HTML::FormHandler::Params->expand_hash( $p1 );

is_deeply( $p1_exp, { book => { author => 'J.Doe', 
                         title => 'Doing something',
                         date => '2002' } }, 'get expanded has' );

my $p2 = {
   'books.0.author' => 'Jane Doe',
   'books.0.title' => 'Janes Book',
   'books.0.date' => '2003',
   'books.1.author' => 'Miss Muffet',
   'books.1.title' => 'Sitting on a Tuffet',
   'books.1.date' => '2004'
};

my $p_hash = {
   books => [
      {  author => 'Jane Doe',
         title  => 'Janes Book',
         date   => '2003',
      },
      {
         author => 'Miss Muffet',
         title  => 'Sitting on a Tuffet',
         date   => '2004',
      }
   ]
};

my $p2_exp = HTML::FormHandler::Params->expand_hash( $p2 );
is_deeply( $p2_exp, $p_hash, 'get expanded hash for dot notation' ); 

my $p3 = {
   'books+0+author' => 'Jane Doe',
   'books+0+title' => 'Janes Book',
   'books+0+date' => '2003',
   'books+1+author' => 'Miss Muffet',
   'books+1+title' => 'Sitting on a Tuffet',
   'books+1+date' => '2004'
};

my $p3_exp = HTML::FormHandler::Params->expand_hash( $p3, '+' );
is_deeply( $p3_exp, $p_hash, 'get expanded hash for plus notation' ); 


my $p4 = {
   'books[0]author' => 'Jane Doe',
   'books[0]title' => 'Janes Book',
   'books[0]date' => '2003',
   'books[1]author' => 'Miss Muffet',
   'books[1]title' => 'Sitting on a Tuffet',
   'books[1]date' => '2004'
};

my $p4_exp = HTML::FormHandler::Params->expand_hash( $p4, '[]' );
is_deeply( $p4_exp, $p_hash, 'get expanded hash for bracket notation' ); 

my $p5 = {
   'book.author' => 'Jane Doe',
   'book.title' => 'Janes Book',
   'book.date' => '2003',
};

my $p5_hash = {
   book => 
      {  author => 'Jane Doe',
         title  => 'Janes Book',
         date   => '2003',
      },
   };
my $p5_exp = HTML::FormHandler::Params->expand_hash( $p5 );
is_deeply( $p5_exp, $p5_hash, 'get hash from single brackets');

