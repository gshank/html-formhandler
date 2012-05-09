use Test::More;

use lib 't/lib';

use_ok( 'HTML::FormHandler::Field::Duration');
use HTML::FormHandler::I18N;
$ENV{LANGUAGE_HANDLE} = HTML::FormHandler::I18N->get_handle('en_en');

my $field = HTML::FormHandler::Field::Duration->new( name => 'duration' );

ok( $field, 'get compound field');

my $input = {
      hours => 1,
      minutes => 2,
};

$field->_set_input($input);

is_deeply( $field->input, $input, 'field input is correct');

is_deeply( $field->fif, $input, 'field fif is same');

{
   package Duration::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has_field 'name' => ( type => 'Text' );
   has_field 'duration' => ( type => 'Duration' );
   has_field 'duration.hours' => ( type => 'Nested' );
   has_field 'duration.minutes' => ( type => 'Nested' );

}

my $form = Duration::Form->new;
ok( $form, 'get compound form' );
ok( $form->field('duration'), 'duration field' );
ok( $form->field('duration.hours'), 'duration.hours field' );

my $params = { name => 'Testing', 'duration.hours' => 2, 'duration.minutes' => 30 };

$form->process( params => $params );
ok( $form->validated, 'form validated' );

is_deeply($form->fif, $params, 'get fif with right value');
is( $form->field('duration')->value->hours, 2, 'duration value is correct');
$form->process( params => { name => 'Testing', 'duration.hours' => 'abc', 'duration.minutes' => 'xyz' } );
ok( $form->has_errors, 'form does not validate' );
my @errors = $form->errors;
is( $errors[0], 'Invalid value for Duration: Hours', 'correct error message' );

{
   package Form::Start;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has_field 'name' => ( type => 'Text' );
   has_field 'start_date' => ( type => 'DateTime' );
   has_field 'start_date.month' => ( type => 'Month' );
   has_field 'start_date.day' => ( type => 'MonthDay' );
   has_field 'start_date.year' => ( type => 'Year' );

   sub validate_start_date_month
   {
      my ( $self, $field ) = @_;
      $field->add_error("That month is not available")
          if( $field->value == 8 );
   }

}

my $dtform = Form::Start->new;
ok( $dtform, 'datetime form' );
$params = { name => 'DT_testing', 'start_date.month' => '10',
    'start_date.day' => '2', 'start_date.year' => '2008' };
$dtform->process( params => $params );
ok( $dtform->validated, 'form validated' );
is( $dtform->field('start_date')->value->mdy, '10-02-2008', 'datetime value');
$params->{'start_date.month'} = 8;
$dtform->process( params => $params );
ok( !$dtform->validated, 'form did not validate' );
ok( $dtform->has_errors, 'form has error' );
@errors = $dtform->errors;
is_deeply( $errors[0], 'That month is not available', 'correct error' );

{
   package Field::MyCompound;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler::Field::Compound';

   has_field 'aaa';
   has_field 'bbb';
}


{
   package Form::TestValues;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has_field 'compound' => ( type => '+Field::MyCompound', apply => [ { check => sub { $_[0]->{aaa} eq 'aaa'}, message => 'Must be "aaa"' } ] );
}
$form = Form::TestValues->new;
ok( $form, 'Compound form with separate fields declarations created' );

$params = {
    'compound.aaa' => 'aaa',
    'compound.bbb' => 'bbb',
};
$form->process( params => $params );
is_deeply( $form->values, { compound => { aaa => 'aaa', bbb => 'bbb' } }, 'Compound with separate fields - values in hash' );
is_deeply( $form->fif, $params, 'get fif from compound field' );
$form->process( params => { 'compound.aaa' => undef } );
ok( !$form->field( 'compound' )->has_errors, 'Not required compound with empty sub values is not checked');

{

    package Compound;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Field::Compound';

    has_field 'year' => (
        type         => 'Integer',
        required     => 1,
    );

    has_field 'month' => (
        type         => 'Integer',
        range_start  => 1,
        range_end    => 12,
    );

    has_field 'day' => (
        type         => 'Integer',
        range_start  => 1,
        range_end    => 31,
    );

    sub default {
        return {
            year  => undef,
            month => undef,
            day   => undef
        };
    }
}

{

    package Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    has_field 'date' => ( type => '+Compound', required => 1 );
    has_field 'foo';
}

my $f = Form->new;
$f->process( { 'date.day' => '18', 'date.month' => '2', 'date.year' => '2010' } );
is_deeply( $f->field('date')->value, { year => 2010, month => 2, day => 18 }, 'correct value' );

$f = Form->new;
$f->process( { foo => 'testing' } );
is_deeply( $f->field('date')->value, { year => undef, month => undef, day => undef }, 'correct default' );

done_testing;
