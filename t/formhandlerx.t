use strict;
use warnings;
use Test::More;
use Test::Exception;

{
    package HTML::FormHandlerX::Widget::Field::TesT;
    use Moose::Role;
    sub render { '<p>field rendered...</p>' }

}

{
    package HTML::FormHandlerX::Field::TesT;
    use Moose;
    extends 'HTML::FormHandler::Field::Text';

    has '+widget' => ( default => 'TesT' );
}

{
    package Test::HTML::FormHandler::TextFormHandlerX;

    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'field_name' => (
        type => 'TesT',
        required => 1,
    );
}

my $form = Test::HTML::FormHandler::TextFormHandlerX->new;
ok( $form, 'created Form' );
my %params = (
    field_name => 'This is a field',
);
$form->process(params=>\%params);
is( $form->field('field_name')->widget, 'TesT', 'got right widget name' );
is( $form->field('field_name')->render, '<p>field rendered...</p>', 'field rendered' );

{
    package Test::Fail;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo' => ( type => 'Fail' );
}

dies_ok( sub { Test::Fail->new }, 'form dies with invalid field' );

done_testing;
