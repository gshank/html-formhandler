use strict;
use warnings;
use Test::More;
use Test::Exception;
use HTML::FormHandler::Field::Text;

use lib ('t/lib');

# ensure $ENV is properly set up
my @LH_VARS = ('LANGUAGE_HANDLE', 'HTTP_ACCEPT_LANGUAGE', 'LANG', 'LANGUAGE' );
my %LOC_ENV;
$LOC_ENV{$_} = delete $ENV{$_} for @LH_VARS;

# a primitive translation package
{
    package HTML::FormHandler::I18N::xx_xx;
    use base 'HTML::FormHandler::I18N';

    # Auto define lexicon
    our %Lexicon = (
        '_AUTO' => 1,
        'You lost, insert coin' => 'Not won, coin needed',
        'Test field' => 'Grfg svryq',
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

$ENV{LANGUAGE} = 'en-US';

# create form w/o locale must work
lives_ok { $form = Test::Form->new } 'create form w/o locale lives';
ok($form, 'create form w/o locale');
is(ref($form->language_handle), 'HTML::FormHandler::I18N::en_us', 'locale en_us');

# ensure we know / don't know the translations
$HTML::FormHandler::I18N::en_us::Lexicon{'You lost, insert coin'} = 'XX Dummy 42';
$HTML::FormHandler::I18N::en_us::Lexicon{'Must insert a [_1] coin'} = 'Want a [_1] coin';
delete $HTML::FormHandler::I18N::en_us::Lexicon{'Test field'};
delete $HTML::FormHandler::I18N::en_us::Lexicon{'You won'};

# translating a known error works
$form->field('test_field')->clear_errors;
$form->field('test_field')->add_error('You lost, insert coin');
is_deeply($form->field('test_field')->errors, ['XX Dummy 42'], 'error is translated into en_us');

# translating a known label
is($form->field('test_field')->label, 'Test field', 'Label w/o translation = ok');

# translating a known error with a positional parameter
$form->field('test_field')->clear_errors;
$form->field('test_field')->add_error('Must insert a [_1] coin', 'cleaned');
is_deeply($form->field('test_field')->errors, ['Want a cleaned coin'], 'error w/parameter is translated into en_us');

# translating an unknown error also works
$form->field('test_field')->clear_errors;
$form->field('test_field')->add_error('You won');
is_deeply($form->field('test_field')->errors, ['You won'], 'error is translated into en_us');

# translating an error with bracket issues
$form->field('test_field')->clear_errors;
dies_ok( sub { $form->field('test_field')->add_error('You are not authorized for this archive. See: [<a href="/help/auth">more information</a>],  [<a href="/need_auth">request authorization</a>]') }, 'dies on maketext error' );

################ Locale xx_xx set via ENV{LANGUAGE_HANDLE}
$ENV{LANGUAGE_HANDLE} = HTML::FormHandler::I18N->get_handle('xx_xx');

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

# translating a known label
is($form->field('test_field')->loc_label, 'Grfg svryq', 'label rot13 to xx_xx');

# remove from environment variable, so we can use builder
delete $ENV{LANGUAGE_HANDLE};
{
    package MyApp::Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    use MyApp::I18N::abc_de;

    sub _build_language_handle { MyApp::I18N::abc_de->new }
    has_field 'foo';
    has_field 'bar';
    sub validate_foo {
        my ( $self, $field ) = @_;
        $field->add_error('You lost, insert coin');
    }
}

$form = MyApp::Test::Form->new;

ok( $form, 'form built' );
$form->process( params => { foo => 'test' } );
is( $form->field('foo')->errors->[0], 'Loser! coin needed', 'right message' );
is( ref $form->language_handle, 'MyApp::I18N::abc_de', 'using right lh');

$ENV{$_} = 'en-US' for @LH_VARS;

done_testing;
