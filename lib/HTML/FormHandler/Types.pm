package HTML::FormHandler::Types; 

use strict;
use warnings;

our $VERSION = '0.001000';

use MooseX::Types -declare => [
  'PositiveNum', 'PositiveInt', 'NegativeNum', 'NegativeInt', 'SingleDigit',
  'SimpleStr', 'NonEmptySimpleStr', 'Password', 'StrongPassword', 'NonEmptyStr'
  'Trim', 'Email', 'State', 'StateOrProvince', 'Province', 'Zip', 'PostCode',
  'ZipOrPostCode', 'Phone', 'AmericanPhone', 'CCNumber', 'CCExp', 'CCType',
  'IPAddress', 'DateTime', 'Word',
];

use MooseX::Types::Moose ('Str', 'Num', 'Int');

=head1 NAME

HTML::FormHandler::Types

=head1 SYNOPSIS

These types are provided by MooseX::Types. These types must not be quoted
when they are used:

  has 'posint' => ( is => 'rw', isa => PositiveInt);

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

=head1 TYPES

=head2 Email

=cut

subtype PositiveNum,
  as Num,
  where { $_ >= 0 },
  message { "Must be a positive number" };

subtype PositiveInt,
  as Int,
  where { $_ >= 0 },
  message { "Must be a positive integer" };

subtype NegativeNum,
  as Num,
  where { $_ <= 0 },
  message { "Must be a negative number" };

subtype NegativeInt,
  as Int,
  where { $_ <= 0 },
  message { "Must be a negative integer" };

subtype SingleDigit,
  as PositiveInt,
  where { $_ <= 9 },
  message { "Must be a single digit" };

subtype SimpleStr,
  as Str,
  where { (length($_) <= 255) && ($_ !~ m/\n/) },
  message { "Must be a single line of no more than 255 chars" };

subtype NonEmptySimpleStr,
  as SimpleStr,
  where { length($_) > 0 },
  message { "Must be a non-empty single line of no more than 255 chars" };

subtype Password,
  as NonEmptySimpleStr,
  where { length($_) > 3 },
  message { "Must be between 4 and 255 chars" };

subtype StrongPassword,
  as Password,
  where { (length($_) > 7) && (m/[^a-zA-Z]/) },
  message {"Must be between 8 and 255 chars, and contain a non-alpha char" };

subtype NonEmptyStr,
  as Str,
  where { length($_) > 0 },
  message { "Must not be empty" };


1;

