use DateTime;
use Test::More tests => 5;

use_ok('HTML::FormHandler::Model');

my $model = HTML::FormHandler::Model->new();

ok( $model, 'get model object');

my $date = DateTime->now;

my $date_model = HTML::FormHandler::Model->new(item => $date);
ok( $date_model, 'get date model object');


ok( $date_model->item_class eq 'DateTime', 'get object class');

my $alt_model = HTML::FormHandler::Model->new(item_class => 'Some::Metadata');
ok( $alt_model->item_class eq 'Some::Metadata', 'new and get object class');

