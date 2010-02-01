use strict;
use warnings;
use Test::More;
use IO::All;

use HTML::FormHandler;

my @select_options = ( {value => 1, label => 'One'}, {value => 2, label => 'Two'}, {value => 3, label => 'Three'} );
my $args =  {
    name       => 'test',
    field_list => [
        'username' => {
            type  => 'Text',
            apply => [ { check => qr/^[0-9a-z]*/, message => 'Contains invalid characters' } ],
        },
        'password' => {
            type => 'Password',
        },
        'a_number' => {
            type      => 'IntRange',
            range_min => 12,
            range_max => 291,
        },
        'on_off' => {
            type           => 'Checkbox',
            checkbox_value => 'yes',
            input_without_param => 'no'
        },
        'long_text' => {
            type => 'TextArea',
        },
        'hidden_text' => {
            type    => 'Hidden',
            default => 'bob',
        },
        'upload_file' => {
            type => 'Upload',
            # valid_extensions => [ "jpg", "gif", "png" ],
            max_size => 262144,
        },
        'a_select' => {
            type    => 'Select',
            options => \@select_options,
        },
        'b_select' => {
            type     => 'Select',
            options  => \@select_options,
            multiple => 1,
            size     => 4,
        },
        'c_select' => {
            type    => 'Select',
            options => \@select_options,
            widget  => 'radio_group',
        },
        'd_select' => {
            type     => 'Select',
            options  => \@select_options,
            multiple => 1,
            widget   => 'checkbox_group'
        },
        'sub' => {
            type => 'Compound',
        },
        'sub.user' => {
            type  => 'Text',
            apply => [ { check => qr/^[0-9a-z]*/, message => 'Not a valid user' } ],
        },
        'sub.name' => {
            type  => 'Text',
            apply => [ { check => qr/^[0-9a-z]*/, message => 'Not a valid name' } ],
        },
        'reset' => {
            type => 'Reset',
        },
        'submit' => {
            type => 'Submit',
        },
        'a_link' => {
            type => 'Display',
            html => '<a href="http://google.com/">get me out of here</>',
        },
    ]
};
my $form = HTML::FormHandler->new( %$args );

ok( $form, 'form builds ok' );

my $renderedform = $form->render;
ok( $renderedform, 'form renders' );
like( $renderedform, qr/Reset/, 'reset rendered' );

done_testing;
