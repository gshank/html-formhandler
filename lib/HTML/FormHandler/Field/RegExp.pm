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

    # Check for qr operator first, because we will eval this
    unless ($value =~ /^qr\// and $value =~ /\/[imsxadlup]*$/) {
        $field->add_error( $field->get_message('regex_format'), 'qr/.+?/i');
        return 1;
    }

    # Check that there is something inside the qr.
    unless ($value =~ /^qr\/.+\/[imsxadlup]*$/) {
        $field->add_error( $field->get_message('regex_empty'), 'qr/.+?/i');
        return 1;
    }

    # Evaluate the regex.
    my $validated;
    try {
        $validated = eval($value);
    } catch {
        $field->add_error($field->get_message('evaluation_error'), $_);
    };
    unless (ref($validated) eq 'Regexp') {
        $field->add_error( $field->get_message('regex_format'), 'qr/.+?/i');
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
