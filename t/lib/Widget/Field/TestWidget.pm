package Widget::Field::TestWidget;

use Moose::Role;

sub render
{
   return "<p>The test succeeded.</p>";
}

1;
