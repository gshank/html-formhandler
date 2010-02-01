package HTML::FormHandler::Types;

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

use MooseX::Types::Moose ( 'Str', 'Num', 'Int' );

=head1 NAME

HTML::FormHandler::Types

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
    message { "Must be a single line of no more than 255 chars" };

subtype NonEmptySimpleStr,
    as SimpleStr,
    where { length($_) > 0 },
    message { "Must be a non-empty single line of no more than 255 chars" };

subtype Password,
    as NonEmptySimpleStr,
    where { length($_) >= 4 && length($_) <= 255 },
    message { "Must be between 4 and 255 chars" };

subtype StrongPassword,
    as Password,
    where { ( length($_) >= 8 ) && length($_) <= 255 && (m/[^a-zA-Z]/) },
    message { "Must be between 8 and 255 chars, and contain a non-alpha char" };

subtype NonEmptyStr, as Str, where { length($_) > 0 }, message { "Must not be empty" };

subtype State, as Str, where {
    my $value = $_;
    my $state = <<EOF;
AL AK AZ AR CA CO CT DE FL GA HI ID IL IN IA KS KY LA ME MD
MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA PR RI
SC SD TN TX UT VT VA WA WV WI WY DC AP FP FPO APO GU VI
EOF
    return ( $state =~ /\b($value)\b/i );
}, message { "Not a valid state" };

subtype Email, as Str, where {
    my $value = shift;
    require Email::Valid;
    my $valid;
    return ( $valid = Email::Valid->address($value) ) &&
        ( $valid eq $value );
}, message { "Email is not valid" };

subtype Zip,
    as Str,
    where { /^(\s*\d{5}(?:[-]\d{4})?\s*)$/ },
    message { "Zip is not valid" };

subtype IPAddress, as Str, where {
    /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
}, message { "Not a valid IP address" };

subtype NoSpaces,
    as Str,
    where { ! /\s/ },
    message { 'Must not contain spaces' };

subtype WordChars,
    as Str,
    where { ! /\W/ },
    message { 'Must be made up of letters, digits, and underscores' };

subtype NotAllDigits,
    as Str,
    where { ! /^\d+$/ },
    message { 'Must not be all digits' };

subtype Printable,
    as Str,
    where { /^\p{IsPrint}*\z/ },
    message { 'Field contains non-printable characters' };

subtype SingleWord,
    as Str,
    where { /^\w*\z/ },
    message { 'Field must contain a single word' };

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

=head1 AUTHORS

  HTML::FormHandler Contributors; see HTML::FormHandler

=head1 COPYRIGHT

  This library is free software, you can redistribute it and/or modify it under
  the same terms as Perl itself.

=cut

1;

