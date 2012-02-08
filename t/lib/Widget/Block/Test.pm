package Widget::Block::Test;
use Moose;
extends 'HTML::FormHandler::Widget::Block';

sub render {
    my $self = shift;

    return "<h2>You got to the Block! Congratulations.</h2>";
}

1;
