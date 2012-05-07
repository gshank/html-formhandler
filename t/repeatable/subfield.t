use strict;
use warnings;
use Test::More;

# this tests accessing a field in a custom compound field
# plus that widget => 'None' allows rendering from the field
{
    package MyApp::Field::Comp;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Field::Compound';

    has_field 'category' => ( type => 'Select' );
    has_field 'media' => ( type => 'Compound' );
    has_field 'media.caption' => ( label => 'Caption' );
    has_field 'media.alt_text' => ( label => 'Alt Text' );

    sub render {
        my $self = shift;
        my $output = $self->subfield('media.caption')->render;
        $output .= $self->subfield('media.alt_text')->render;
        $output .= $self->subfield('category')->render;
        return $output;
    }
}

{
    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field 'customer';
    has_field 'active_media' => ( type => 'Repeatable' );
    has_field 'active_media.contains' => ( type => '+MyApp::Field::Comp',
        widget => 'None', widget_wrapper => 'None' );

}

my $form = MyApp::Form::Test->new;
ok( $form );

my $rendered = $form->render;
ok( $rendered, 'rendered' );
like( $rendered, qr/\<input type="text" name="active_media.0.media.caption" id="active_media.0.media.caption" value="" \/\>/, 'rendered ok' );

done_testing;
