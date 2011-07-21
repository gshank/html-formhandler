package HTML::FormHandler::Types;
# ABSTRACT: Moose type constraints

use strict;
use warnings;

our $VERSION = '0.01';

use MooseX::Types -declare => [
    'PositiveNum',    'PositiveInt', 'NegativeNum',       'NegativeInt',
    'SingleDigit',    'SimpleStr',   'NonEmptySimpleStr', 'Password',
    'StrongPassword', 'NonEmptyStr', 'Email',             'State',
    'Zip',            'IPAddress',   'NoSpaces',          'WordChars',
    'NotAllDigits',   'Printable',   'SingleWord',
    'Collapse',       'Upper',       'Lower',             'Trim',
];

our $class_messages = {
    PositiveNum => "Must be a positive number",
    PositiveInt => "Must be a positive integer",
    NegativeNum => "Must be a negative number",
    NegativeInt => "Must be a negative integer",
    SingleDigit => "Must be a single digit",
    SimpleStr => 'Must be a single line of no more than 255 chars',
    NonEmptySimpleStr => "Must be a non-empty single line of no more than 255 chars",
    Password => "Must be between 4 and 255 chars",
    StrongPassword =>"Must be between 8 and 255 chars, and contain a non-alpha char",
    NonEmptyStr => "Must not be empty",
    State => "Not a valid state",
    Email => "Email is not valid",
    Zip => "Zip is not valid",
    IPAddress => "Not a valid IP address",
    NoSpaces =>'Must not contain spaces',
    WordChars => 'Must be made up of letters, digits, and underscores',
    NotAllDigits => 'Must not be all digits',
    Printable => 'Field contains non-printable characters',
    SingleWord => 'Field must contain a single word',
};

use MooseX::Types::Moose ( 'Str', 'Num', 'Int' );

=head1 SYNOPSIS

These types are provided by MooseX::Types. These types must not be quoted
when they are used:

  has 'posint' => ( is => 'rw', isa => PositiveInt);
  has_field 'email' => ( apply => [ Email ] );

Types declared using Moose::Util::TypeConstraints, on the other hand,
must be quoted:

  has_field 'text_both' => ( apply => [ PositiveInt, 'GreaterThan10' ] );

To import these types into your forms, you must either specify (':all')
or list the types you want to use:

   use HTML::FormHandler::Types (':all');

or:

   use HTML::FormHandler::Types ('Email', 'PositiveInt');

=head1 DESCRIPTION


It would be possible to import the MooseX types (Common, etc), but for now
we'll just re-implement them here in order to be able to change the
messages and keep control of what types we provide.

From MooseX::Types::Common:

  'PositiveNum', 'PositiveInt', 'NegativeNum', 'NegativeInt', 'SingleDigit',
  'SimpleStr', 'NonEmptySimpleStr', 'Password', 'StrongPassword', 'NonEmptyStr',


=head1 Type Constraints

These types check the value and issue an error message.

=over

=item Email

Uses Email::Valid

=item State

Checks that the state is in a list of two uppercase letters.

=item Zip

=item IPAddress

Must be a valid IPv4 address.

=item NoSpaces

No spaces in string allowed.

=item WordChars

Must be made up of letters, digits, and underscores.

=item NotAllDigits

Might be useful for passwords.

=item Printable

Must not contain non-printable characters.

=item SingleWord

Contains a single word.

=back

=head2 Type Coercions

These types will transform the value without an error message;

=over

=item Collapse

Replaces multiple spaces with a single space

=item Upper

Makes the string all upper case

=item Lower

Makes the string all lower case

=item Trim

Trims the string of starting and ending spaces

=back

=cut

subtype PositiveNum, as Num, where { $_ >= 0 }, message { "Must be a positive number" };

subtype PositiveInt, as Int, where { $_ >= 0 }, message { "Must be a positive integer" };

subtype NegativeNum, as Num, where { $_ <= 0 }, message { "Must be a negative number" };

subtype NegativeInt, as Int, where { $_ <= 0 }, message { "Must be a negative integer" };

subtype SingleDigit, as PositiveInt, where { $_ <= 9 }, message { "Must be a single digit" };

subtype SimpleStr,
    as Str,
    where { ( length($_) <= 255 ) && ( $_ !~ m/\n/ ) },
    message { $class_messages->{SimpleStr} };

subtype NonEmptySimpleStr,
    as SimpleStr,
    where { length($_) > 0 },
    message { $class_messages->{NonEmptySimpleStr} };

subtype Password,
    as NonEmptySimpleStr,
    where { length($_) >= 4 && length($_) <= 255 },
    message { $class_messages->{Password} };

subtype StrongPassword,
    as Password,
    where { ( length($_) >= 8 ) && length($_) <= 255 && (m/[^a-zA-Z]/) },
    message { $class_messages->{StrongPassword} };

subtype NonEmptyStr, as Str, where { length($_) > 0 }, message { $class_messages->{NonEmptyStr} };

subtype State, as Str, where {
    my $value = $_;
    my $state = <<EOF;
AL AK AZ AR CA CO CT DE FL GA HI ID IL IN IA KS KY LA ME MD
MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA PR RI
SC SD TN TX UT VT VA WA WV WI WY DC AP FP FPO APO GU VI
EOF
    return ( $state =~ /\b($value)\b/i );
}, message { $class_messages->{State} };

subtype Email, as Str, where {
    my $value = shift;
    require Email::Valid;
    my $valid;
    return ( $valid = Email::Valid->address($value) ) &&
        ( $valid eq $value );
}, message { $class_messages->{Email} };

subtype Zip,
    as Str,
    where { /^(\s*\d{5}(?:[-]\d{4})?\s*)$/ },
    message { $class_messages->{Zip} };

subtype IPAddress, as Str, where {
    /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
}, message { $class_messages->{IPAddress} };

subtype NoSpaces,
    as Str,
    where { ! /\s/ },
    message { $class_messages->{NoSpaces} };

subtype WordChars,
    as Str,
    where { ! /\W/ },
    message { $class_messages->{WordChars} };

subtype NotAllDigits,
    as Str,
    where { ! /^\d+$/ },
    message { $class_messages->{NotAllDigits} };

subtype Printable,
    as Str,
    where { /^\p{IsPrint}*\z/ },
    message { $class_messages->{Printable} };

subtype SingleWord,
    as Str,
    where { /^\w*\z/ },
    message { $class_messages->{SingleWord} };

subtype Collapse,
   as Str,
   where{ ! /\s{2,}/ };

coerce Collapse,
   from Str,
   via { s/\s+/ /g; return $_; };

subtype Lower,
   as Str,
   where { ! /[[:upper:]]/  };

coerce Lower,
   from Str,
   via { lc };

subtype Upper,
   as Str,
   where { ! /[[:lower:]]/ };

coerce Upper,
   from Str,
   via { uc };

subtype Trim,
   as Str,
   where  { ! /^\s+/ &&
            ! /\s+$/ };

coerce Trim,
   from Str,
   via { s/^\s+// &&
         s/\s+$//;
         return $_;  };

1;

