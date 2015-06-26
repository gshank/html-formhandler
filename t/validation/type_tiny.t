use strict;
use warnings;
use Test::More;
use Test::Exception;

use HTML::FormHandler::Types (':all');

use HTML::FormHandler::I18N;
$ENV{LANGUAGE_HANDLE} = 'en_en';

BEGIN {
    plan skip_all => 'Type::Tiny or Type::Tiny::Enum not installed'
       unless eval { require Type::Tiny; require Type::Tiny::Enum; };
}


{
    package Test::Form::Type::Tiny;

    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    use Type::Tiny::Enum;
    my $ENUM = Type::Tiny::Enum->new(
        name    => "Meta",
        values  => [qw( foo bar )],
        message => sub { "$_ ain't meta" },
    );

    my $NUM = Type::Tiny->new(
        name       => "Number",
        constraint => sub { $_ =~ /^\d+$/ },
        message    => sub { "$_ ain't a number" },
    );

    has_field 'test_a' => ( apply => [ $NUM ] );
    has_field 'test_b' => ( apply => [ { type => $NUM } ] );
    has_field 'test_c' => ( apply => [ $ENUM ] );
    has_field 'test_d' => ( apply => [ { type => $ENUM } ] );
}

my $form = Test::Form::Type::Tiny->new;

ok($form, 'get form');

my $params = {
    test_a => 'str1',
    test_b => 'str2',
    test_c => 'str3',
    test_d => 'str4',
};
$form->process($params);
ok( !$form->validated, 'form did not validate' );
ok( $form->field('test_a')->has_errors, 'errors on Type::Tiny type');
ok( $form->field('test_b')->has_errors, 'errors on Type::Tiny type');
ok( $form->field('test_c')->has_errors, 'errors on Type::Tiny::Enum type');
ok( $form->field('test_d')->has_errors, 'errors on Type::Tiny::Enum type');
is( $form->field('test_a')->errors->[0], "str1 ain't a number", 'error from Type::Tiny' );
is( $form->field('test_b')->errors->[0], "str2 ain't a number", 'error from Type::Tiny' );
is( $form->field('test_c')->errors->[0], "str3 ain't meta", 'error from Type::Tiny::Enum' );
is( $form->field('test_d')->errors->[0], "str4 ain't meta", 'error from Type::Tiny::Enum' );

$params = {
    test_a => '123',
    test_b => '456',
    test_c => 'foo',
    test_d => 'bar',
};
$form->process($params);
ok( $form->validated, 'form validated' );
ok( !$form->field('test_a')->has_errors, 'no errors on Type::Tiny type');
ok( !$form->field('test_b')->has_errors, 'no errors on Type::Tiny type');
ok( !$form->field('test_c')->has_errors, 'no errors on Type::Tiny::Enum type');
ok( !$form->field('test_d')->has_errors, 'no errors on Type::Tiny::Enum type');

done_testing;
