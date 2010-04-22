use strict;
use warnings;
use Test::More;


{
    package Test::MonthYear;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'my_date' => ( type => 'DateTime' );
    has_field 'my_date.month' => ( type => 'Month' );
    has_field 'my_date.year' => ( type => 'Year' );
    has_field 'submit' => ( type => 'Submit' );

}

my $form = Test::MonthYear->new;
ok( $form, 'form builds' );

my $rendered_form = $form->render;

{
    package Test::Field::MonthYear;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Field::DateTime';

    has_field 'month' => ( type => 'Month' );
    has_field 'year' => ( type => 'Year' );
}

{
    package Test::Widget::Field::MonthYear;
    use Moose::Role;
    sub render {
        my $self = shift;
        return '<p>Create your rendering here...</p>';
    }
}

{
    package Test::Form::MonthYearField;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+field_name_space' => ( default => 'Test::Field' );
    has '+widget_name_space' => ( default => sub { ['Test::Widget'] } );
    has_field 'my_date' => ( type => '+MonthYear', widget => 'MonthYear' ); 

}

$form = Test::Form::MonthYearField->new;
ok( $form, 'form builds' );
ok( $form->field('my_date'), 'the field is there' );
is( $form->field('my_date')->render, '<p>Create your rendering here...</p>', 'renders ok' );

{
    package Test2::Widget::Field::SimpleWidget;
    use Moose::Role;
    sub render { "I'am simple widget" }
}
{
    package Test2::Field::CustomWidgetCompoundField;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Field::Compound';
    has_field 'my_text' => ( type => 'Text', widget => 'SimpleWidget' );
}
{
    package Test2::Form::Compound;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    has '+field_name_space' => ( default => sub { 'Test2::Field' } );
    has '+widget_name_space' => ( default => sub { ['Test2::Widget'] } );
    has_field 'test' => ( type => '+CustomWidgetCompoundField' );
}
{
    my $form = Test2::Form::Compound->new;
    ok( $form, 'form builds' );
    ok( $form->field('test.my_text'), 'the field is there' );
    is( $form->field('test.my_text')->render, "I'am simple widget", 'renders ok');
}

done_testing;
