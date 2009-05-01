package HTML::FormHandler::Types;

use MooseX::Types
   -declare => [ 
      'Email',
      'State',
      'StateOrProvince',
      'Province', 
      'Zip',
      'PostCode',
      'ZipOrPostCode',
      'Phone',
      'AmericanPhone',
      'CCNumber',
      'CCExp',
      'CCType',
      'IPAddress',
      'DateTime',
      'Word',
   ];

# import building types
use MooseX::Types::Moose ':all';
use MooseX::Types::Common::String (
   'SimpleStr',
   'NonEmptySimpleStr',
   'Password',
   'StrongPassword',
   'NonEmptyStr',
);
use MooseX::Types::Common::Numeric (
   'PositiveNum',
   'PositiveInt',
   'NegativeNum',
   'NegativeInt',
   'SingleDigit',
);
use MooseX::Types::DateTime (
   'DateTime',
   'Duration',
   'TimeZone',
   'Locale',
);

=head1 NAME

HTML::FormHandler::Types

=head1 SYNOPSIS

=head1 DESCRIPTION


Types imported from L<MooseX::Types::Common>:

    SimpleStr 
    NonEmptySimpleStr
    Password
    StrongPassword
    NonEmptyStr
    PositiveNum
    PositiveInt
    NegativeNum
    NegativeInt
    SingleDigit

Types imported from L<MooseX::Types::DateTime>

    DateTime
    Duration
    TimeZone
    Locale

   
=head1 FormHandler TYPES

=head2 Email

=cut

subtype Email,
   as Str,
   where { },
   message { "not a valid email" };

=head2 State

=cut

subtype State,
   as Str,
   where { },
   message { "not a valid state" };

=head2 Province

=cut

subtype Province,
   as Str,
   where { },
   message { "not a valid province" };

=head2 StateOrProvince

=cut

subtype StateOrProvince,
  as State|Province;

=head2 Zip

=cut

subtype Zip,
   as Str,
   where { },
   message { "not a valid zip" };

=head2 PostCode

=cut

subtype PostCode,
   as Str,
   where { },
   message { "not a valid postcode" };

=head2 ZipOrPostCode

=cut

subtype ZipOrPostCode,
   as Zip|PostCode;

=head2 Phone

=cut

subtype Phone,
   as Str,
   where { },
   message { "not a valid phone number" };

=head2 AmericanPhone

=cut

subtype AmericanPhone,
   as Str,
   where { },
   message { "not a valid phone number" };

=head2 CCNumber

=cut

subtype CCNumber,
   as Str,
   where { },
   message { "not a valid credit card number" };

=head2 CCExp

=cut

subtype CCExp,
   as Str,
   where { },
   message { "not a valid credit card expiration" };

=head2 CCType

=cut

subtype CCType,
   as Str,
   where { },
   message { "not a valid credit card type" };

=head2 IPAddress

=cut

subtype IPAddress,
   as Str,
   where { },
   message { "not a valid IP address" };

=head2 Word

=cut

subtype Word,
  as Str,
  where { },
  message { "only words allowed" };

1;
