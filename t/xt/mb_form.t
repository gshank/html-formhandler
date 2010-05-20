use strict;
use warnings;
use Test::More;

{
    package Hello::Form::Page;
    use HTML::FormHandler::Moose;

    extends 'HTML::FormHandler';

    has '+html_prefix' => ( default => 0 );

    has_field 'wizard_session_id' => ( type => 'Hidden' );
    has_field 'cancel' => ( type => 'Submit', value => "Cancel"  );
    has_field 'prev' => ( type => 'Submit', value => "Prev"  );
    has_field 'next' => ( type => 'Submit', value => "Next"  );
}

{
    package Hello::Form::Page2;
    use HTML::FormHandler::Moose;

    extends 'Hello::Form::Page';

    has_field 'organization'  => ( type => 'Text'    );

    has_field 'mediums' => ( type => 'Repeatable', num_when_empty => 0 );
    has_field 'mediums.id' => ( type => 'Integer' );
    has_field 'mediums.tracklist' => ( type => 'Compound' );
    has_field 'mediums.tracklist.id' => ( type => 'Integer' );
    has_field 'mediums.tracklist.tracks' => ( type => 'Repeatable',  num_when_empty => 0 );
    has_field 'mediums.tracklist.tracks.id' => ( type => 'Integer' );
}

my $form = Hello::Form::Page2->new;
ok( $form, 'form builds ok' );
diag( $form->peek );
diag( $form->result->peek );

my $init_obj = {
    mediums => [
        {
            id => 1,
            tracklist => {
                id => 10,
                tracks => [
                   { id => 100 },
                   { id => 200 },
                ],
            },
        },
        {
            id => 2,
            tracklist => {
                id => 20,
                tracks => [
                   {  id => 300 },
                   {  id => 400 },
                ],
            },
        },
    ]
};

my $extra_values = {
    'next' => 'Next',
    cancel => 'Cancel',
    organization => undef,
    prev => 'Prev',
    wizard_session_id => undef,
};


$form->process( init_object => $init_obj );
diag( $form->peek );
diag( $form->result->peek );
my $value = $form->value;
is_deeply( $value, { %$init_obj, %$extra_values}, 'right values' );

my $good_fif = {
    'mediums.0.id' => 1,
    'mediums.0.tracklist.id' => 10,
    'mediums.0.tracklist.tracks.0.id' => 100,
    'mediums.0.tracklist.tracks.1.id' => 200,
    'mediums.1.id' => 2,
    'mediums.1.tracklist.id' => 20,
    'mediums.1.tracklist.tracks.0.id' => 300,
    'mediums.1.tracklist.tracks.1.id' => 400,
    'organization' => '',
    'wizard_session_id' => '',
};
my $fif = $form->fif;
is_deeply( $fif, $good_fif, 'fif is right' );
$form->process( $fif );

done_testing;
