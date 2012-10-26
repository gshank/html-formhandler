use strict;
use warnings;
use Test::More;

{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo';

    with 'MyApp::Form::Role::Factors';

    has_field '+bar_one' => ( accessor => 'dimension_value_ids' );
    has_field '+bar_two' => ( accessor => 'factor_value_ids' );
}


{
    package MyApp::Form::Role::Factors;

    use HTML::FormHandler::Moose::Role;

    has_field bar_one => ( type => 'Repeatable', required => 0 );
    has_field 'bar_one.contains' => ( type => 'Integer' );
    has_field bar_two => ( type => 'Repeatable', required => 0 );
    has_field 'bar_two.contains' => ( type => 'Integer' );
}

my $form = MyApp::Form::Test->new;
ok( $form );

done_testing;
