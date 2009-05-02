package HTML::FormHandler::Types; 

use strict;
use warnings;

our $VERSION = '0.001000';

use MooseX::Types -declare => [
  'PositiveNum', 'PositiveInt', 'NegativeNum', 'NegativeInt', 'SingleDigit',
  'SimpleStr', 'NonEmptySimpleStr', 'Password', 'StrongPassword', 'NonEmptyStr'
];

use MooseX::Types::Moose ('Str', 'Num', 'Int');

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

