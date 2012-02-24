use strict;
use warnings;
use Test::More;

# this tests that the 'widget_tags' from pre-0.40 versions
# works when set on a Form and Field.
{
    package MyApp::Old::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+widget_tags' => ( default => sub {
            {  my_tag => 1,
               some_tag => '<p>Testing, testing...</p>',
            }
       }
    );

    has_field 'foo';
    has_field 'bar' => ( widget_tags => { field_tag => 1 } );
}

my $form = MyApp::Old::Form->new;
ok( $form );
my $exp_widget_tags = { my_tag => 1, some_tag => '<p>Testing, testing...</p>' };
is_deeply( $form->widget_tags, $exp_widget_tags, 'got expected widget tags' );

is( $form->field('foo')->get_tag('my_tag'), 1, 'got widget tag from field' );
my $tags = $form->field('bar')->tags;
my $exp_tags = {
   'field_tag' => 1,
   'my_tag' => 1,
   'some_tag' => '<p>Testing, testing...</p>',
};
is_deeply( $tags, $exp_tags, 'field has expected tags' );

done_testing;
