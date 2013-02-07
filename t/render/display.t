use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package Test::Field::Rendering;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'my_html' => ( type => 'Display', html => '<h2>You got here!</h2>' );
    has_field 'explanation' => ( type => 'Display' );
    has_field 'between' => ( type => 'Display', set_html => 'between_html' );
    has_field 'nolabel' => ( type => 'Text', do_label => 0 );

    sub html_explanation {
       my ( $self, $field ) = @_;
       return "<p>I have an explanation somewhere around here...</p>";
    }

    sub between_html {
        my ( $self, $field ) = @_;
        return "<div>Somewhere, over the rainbow...</div>";
    }

}

my $form = Test::Field::Rendering->new;
is_html( $form->field('my_html')->render, '<h2>You got here!</h2>', 'display field renders with html attribute' );
is_html( $form->field('explanation')->render, '<p>I have an explanation somewhere around here...</p>',
    'display field renders with form method' );
is_html( $form->field('between')->render, '<div>Somewhere, over the rainbow...</div>',
    'set_html field renders' );
is_html( $form->field('nolabel')->render, '
<div><input type="text" name="nolabel" id="nolabel" value="" />
</div>', 'do_label => 0 works');

# test render_method
{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'foo';
    has_field 'bar' => (
        type => 'Display',
        render_method => \&render_bar,
    );
    sub render_bar {
        my $self = shift; # $self is field
        my $name = $self->name;
        return "<p>This is field $name!</p>";
    }
    has_field 'moy' => (
        type => 'Display',
        html => '<p>From the html attribute...</p>',
    );

}

$form = MyApp::Form::Test->new;

my $rendered = $form->render;
ok( $rendered, 'it rendered' );
like( $rendered, qr/This is field bar/, 'rendered from render_method' );
like( $rendered, qr/From the html attribute/, 'rendered from html attribute' );

done_testing;
