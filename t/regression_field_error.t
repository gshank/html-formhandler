use strict;
use Test::More (tests => 3);
use HTML::FormHandler;

my $form = HTML::FormHandler->new(
    field_list => [ foo => { type => 'Text', required => 1 } ]
);

if (! $form->process( params => { bar => 1, } )) {
    # On some versions, the above process() returned false, but
    # error_fields did not return anything. 
    my @fields = $form->error_fields;
    if (is(scalar @fields, 1, "there is an error field")) {
        my @errors = $fields[0]->errors;
        is(scalar @errors, 1, "there is an error");

        is($errors[0], $fields[0]->label . " field is required", "error messages match");
    } else {
        fail("there is an error");
        fail("error messages match");
    }
}
