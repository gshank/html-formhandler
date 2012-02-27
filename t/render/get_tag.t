use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package MyApp::Form::MyTags;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+name' => ( default => 'testform' );
    has_field 'foo' => ( tags => { after_element => \&help_text } );
    has_field 'bar';

    sub help_text {
        my $self = shift;
        my $label = $self->label;
        return qq{<span class="help-line">$label is most important></span>};
    }
}

my $form = MyApp::Form::MyTags->new;
$form->process;
my $rendered = $form->field('foo')->render;
my $expected =
'<div>
  <label for="foo">Foo</label>
  <input type="text" name="foo" id="foo" value="" /><span class="help-line">Foo is most important></span>
</div>';
is_html( $rendered, $expected, 'foo field rendered correctly' );

done_testing;
