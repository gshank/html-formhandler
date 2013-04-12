use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

# test building block_list in a form
{
    package MyApp::Test::Blist;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+name' => ( default => 'test_form' );
    has_field 'foo';
    has_field 'bar';
    has_field 'mix';
    has_field 'submit_btn' => ( type => 'Submit' );

    sub build_render_list { ['block1', 'block2', 'block3'] }
    sub build_block_list {
        return [
            { name => 'block1', render_list => ['foo', 'bar'] },
            { name => 'block2', render_list => ['mix'] },
            { name => 'block3', render_list => ['submit_btn'] },
        ];
    }
}
my $form = MyApp::Test::Blist->new;
ok( $form, 'form built' );
is( $form->has_blocks, 3, 'right number of blocks' );

my $rendered = $form->render;

# test building block_list on the fly
my $dyn_form = HTML::FormHandler->new(
    name => 'test_form',
    block_list => [
        { name => 'block1', render_list => ['foo', 'bar'] },
        { name => 'block2', render_list => ['mix'] },
        { name => 'block3', render_list => ['submit_btn'] },
    ],
    render_list => ['block1', 'block2', 'block3'],
    field_list => [
        { type => 'Text', name => 'foo' },
        { type => 'Text', name => 'bar' },
        { type => 'Text', name => 'mix' },
        { type => 'Submit', name => 'submit_btn' },
    ],
);
ok( $dyn_form, 'dynamic form built' );
is( $dyn_form->has_blocks, 3, 'right number of blocks' );

my $dyn_rendered = $dyn_form->render;
is_html( $dyn_rendered, $rendered, 'both forms render the same');

done_testing;
