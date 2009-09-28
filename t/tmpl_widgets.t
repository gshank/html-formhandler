use strict;
use warnings;
use Test::More;

{
    package Widget::Field::Text;

    use Moose::Role;
    use Template::Tiny;

    my $widget = <<'END';
    <input type="text" name="[% html_name %]" id="[% id %]" 
        [% IF size %] size="[% size %]"[% END %] 
        [% IF maxlength %] maxlength="[% maxlength %]"[% END %]
        value="[% fif %]">
END
    has 'template' => ( is => 'ro', isa => 'Template::Tiny', builder => 'build_temlate');
    sub build_template {
        my $self = shift;
        my $tt = Template::Tiny->new;
        $tt->_add_template('text_widget', $widget );
    }
    

    sub render {
        my ( $self, $result ) = @_;

        $result ||= $self->result;
        my $output = $self->template->process('widget', {
                html_name => $self->html_name,
                id => $self->id,
                size => $self->size,
                maxlength => $self->maxlength,
                fif => $result->value,
            });

        return $self->wrap_field( $result, $output );
    }


}

my $field = HTML::FormHandler::Field::Text->new_with_traits( 
    traits => ['Widget::Field::Text'], name => 'test_text' );
ok( $field, 'created field' );


done_testing;
