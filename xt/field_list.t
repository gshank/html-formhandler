use strict;
use warnings;
use Test::More tests => 4;
use Data::Clone;

use HTML::FormHandler;

my $field_list = [
   id => {
      type     => 'Text',
      required => 1,
   },
   submit => 'Submit',
];

my $form = HTML::FormHandler->new( field_list => $field_list );

ok( $form, 'created form OK the first time');
ok( $form->field('id'), 'id field exists' );

$form = HTML::FormHandler->new( field_list => [@{$field_list}, new_field => 'Text'] );

ok( $form, 'created form OK the second time' );
ok( $form->field('id'), 'id field exists' );

