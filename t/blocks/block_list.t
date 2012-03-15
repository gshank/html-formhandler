use strict;
use warnings;
use Test::More;

{
    package MyApp::Test::Blist;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

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

done_testing;
