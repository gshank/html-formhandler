use strict;
use warnings;
use Test::More;
use Test::Exception;
use HTML::FormHandler::Field::Text;

use_ok('HTML::FormHandler::I18N::de_de');

# ensure $ENV is properly set up
delete $ENV{$_}
    for qw(LANGUAGE_HANDLE HTTP_ACCEPT_LANGUAGE LANG LANGUAGE);

# a primitive translation package
{
    package HTML::FormHandler::I18N::xx_xx;
    use base 'HTML::FormHandler::I18N';

    # Auto define lexicon
    our %Lexicon = (
        '_AUTO' => 1,
        'You lost, insert coin' => 'Not won, coin needed',
    );
}

# a simple demo form
{
   package Test::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';

   has_field 'test_field';
}

my $form;


################ Locale -none-

# create form w/o locale must work
lives_ok { $form = Test::Form->new } 'create form w/o locale lives';
ok($form, 'create form w/o locale');
is(ref($form->language_handle), 'HTML::FormHandler::I18N::en_us', 'locale en_us');

# ensure we know / don't know the translations
$HTML::FormHandler::I18N::en_us::Lexicon{'You lost, insert coin'} = 'XX Dummy 42';
$HTML::FormHandler::I18N::en_us::Lexicon{'Must insert a [_1] coin'} = 'Want a [_1] coin';
delete $HTML::FormHandler::I18N::en_us::Lexicon{'You won'};

# translating a known error works
$form->field('test_field')->clear_errors;
$form->field('test_field')->add_error('You lost, insert coin');
is_deeply($form->field('test_field')->errors, ['XX Dummy 42'], 'error is translated into en_us');

# translating a known error with a positional parameter
$form->field('test_field')->clear_errors;
$form->field('test_field')->add_error('Must insert a [_1] coin', 'cleaned');
is_deeply($form->field('test_field')->errors, ['Want a cleaned coin'], 'error w/parameter is translated into en_us');

# translating an unknown error also works
$form->field('test_field')->clear_errors;
$form->field('test_field')->add_error('You won');
is_deeply($form->field('test_field')->errors, ['You won'], 'error is translated into en_us');


################ Locale xx_xx set via ENV{LANG}
$ENV{LANG} = 'xx_xx';

# create form w/ locale must work
undef $form;
lives_ok { $form = Test::Form->new } 'create form w/ locale lives';
ok($form, 'create form w/ locale');
is(ref($form->language_handle), 'HTML::FormHandler::I18N::xx_xx', 'locale xx_xx');

# translating a known error works
$form->field('test_field')->clear_errors;
$form->field('test_field')->add_error('You lost, insert coin');
is_deeply($form->field('test_field')->errors, ['Not won, coin needed'], 'error is translated into xx_xx');

# translating an unknown error also works
$form->field('test_field')->clear_errors;
$form->field('test_field')->add_error('You won');
is_deeply($form->field('test_field')->errors, ['You won'], 'error is translated into xx_xx');

done_testing;
