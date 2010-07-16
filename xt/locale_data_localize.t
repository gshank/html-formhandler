use strict;
use warnings;
use Test::More;
use Test::Exception;
use HTML::FormHandler::Field::Text;

BEGIN {
    eval "use Data::Localize";
    if ($@) {
        plan skip_all => "Data::Localize is not installed";
    }
}

{
    package MyApp::Test::I18N::en_US;
    our %Lexicon = (
        'You lost, insert coin' => 'Not won, coin needed',
        'Test field' => 'Grfg svryq',
    );
}

{
    package MyApp::Test::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    sub _build_language_handle { 
        my $class = Moose::Meta::Class->create_anon_class(
            superclasses => [ 'Data::Localize' ],
            methods => {
                maketext => sub { shift->localize(@_) }
            }
        );
        my $loc = $class->new_object();
        $loc->set_languages('en_US');
        $loc->add_localizer(
            class => "Namespace",
            namespaces => [ "MyApp::Test::I18N" ],
        );
        return $loc;
    }

    has_field 'foo';
    has_field 'bar';
    sub validate_foo {
        my ( $self, $field ) = @_;
        $field->add_error('You lost, insert coin');
    }
}

my $form = MyApp::Test::Form->new;
ok( $form, 'form built' );
$form->process( params => { foo => 'test' } );
is( $form->field('foo')->errors->[0], 'Not won, coin needed', 'right message' );

done_testing;