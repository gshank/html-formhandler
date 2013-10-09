package HTML::FormHandler::Field::RegExp;

use HTML::FormHandler::Moose;
use Try::Tiny;
extends 'HTML::FormHandler::Field::Text';

our $class_messages = {
    'regex_format' => 'RegExp should be of the format [_1]',
    'evaluation_error' => 'Unknown error in eval: [_1]',
    'regex_empty' => 'RegExp is empty',
};

sub get_class_messages  {
    my $self = shift;
    return {
        %{ $self->next::method },
        %$class_messages,
    }
}

sub validate {
    my $field = shift;
    my $value = $field->value;

    unless ($value =~ /^qr\// and $value =~ /\/$/) {
        $field->add_error( $field->get_message('regex_format'), 'qr/.+?/');
        return 1;
    }
    unless ($value =~ /^qr\/.+\/$/) {
        $field->add_error( $field->get_message('regex_empty'), 'qr/.+?/');
        return 1;
    }
    my $validated;
    try {
        $validated = eval($value);
    } catch {
        $field->add_error($field->get_message('evaluation_error'), $_);
    };
    unless (ref($validated) eq 'Regexp') {
        $field->add_error( $field->get_message('regex_format'), 'qr/.+?/');
        return 1;
    }
    return 1;
}

=head1 DESCRIPTION

Validates that the input looks like a regexp using a combination of... (1) a regex!
And (2) eval-ing the string and checking the reftype of the result.

Widget type is 'text'.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
