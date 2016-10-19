package HTML::FormHandler::I18N::cs_cz;
# ABSTRACT: Czech message translations

use strict;
use warnings;
use base 'HTML::FormHandler::I18N';

use utf8;

# Auto define lexicon
our %Lexicon = (
    '_AUTO' => 1,

    # H::F::Field
    'field is invalid' => 'pole je neplatné',
    'Wrong value' => 'Špatná hodnota',
    '[_1] does not match' => '[_1] neodpovídá',
    '[_1] not allowed' => '[_1] není povoleno',
    '[_1] field is required' => 'Pole [_1] je povinné',
    'error occurred' => 'došlo k chybě',
    'Value must be between [_1] and [_2]' => 'Hodnota musí být mezi [_1] a [_2]',
    'Value must be greater than or equal to [_1]' => 'Hodnota musí být větší než nebo rovna [_1]',
    'Value must be less than or equal to [_1]' => 'Hodnota musí být menší než nebo rovnající se [_1]',

    # H::F::Types
    'Must be a positive number' => 'Musí být kladné číslo',
    'Must be a positive integer' => 'Musí být kladné celé číslo',
    'Must be a negative number'  => 'Musí být záporné číslo"',
    'Must be a negative integer' => 'Musí být záporné celé číslo',
    'Must be a single digit' => 'Musí to být jedna číslice',
    'Must be a non-empty single line of no more than 255 chars' => 'Musí to být jediný řádek nejvýše 255 znaků',
    'Must be made up of letters, digits, and underscores' => 'Musí být pouze z písmen, číslic a podtržítek',
    'Not a valid IP address' => 'Neplatná IP adresa',
    'Must not be all digits' => 'Nesmí obsahovat pouze číslice',
    'Not a valid state' => 'Není platný stát',
    'Field contains non-printable characters' => 'Pole obsahuje netisknutelné znaky',
    'Must be between 4 and 255 chars' => 'Musí být mezi 4 a 255 znaků',
    'Zip is not valid' => 'PSČ není platné',
    'Must be a single line of no more than 255 chars' => 'Musí být jediný řádek s nejvýše 255 znaky',
    'Email is not valid' => 'Neplatný email',
    'Must not contain spaces' => 'Nesmí obsahovat mezery',
    'Field must contain a single word' => 'Pole musí obsahovat jedno slovo',
    'Must not be empty' => 'Nesmí být prázdný',
    'Must be between 8 and 255 chars, and contain a non-alpha char' => 'Musí být mezi 8 a 255 znaků, a musí obsahovat ne-alfa znak',


    # H::F::Field::Date
    'Date is too early' => 'Datum je příliš brzy',
    'Date is too late'  => 'Datum je příliš pozdě',

    # H::F::Field::DateTime
    'Not a valid DateTime' => 'Neplatné datum a čas',

    # H::F::Field::Duration
    'Invalid value for [_1]: [_2]' => 'Neplatná hodnota pro [_1]: [_2]',

    # H::F::Field::Email
    'Email should be of the format [_1]' => 'E-mail by měl být ve formátu [_1]',

    # H::F::Field::Integer
    'Value must be an integer' => 'Hodnota musí být celé číslo',

    # H::F::Field::Money
    'Value cannot be converted to money' => 'Hodnota nelze převést na peníze',
    'Value must be a real number' => 'Hodnota musí být reálné číslo',

    # H::F::Field::Password
    'Please enter a password in this field' => 'Zadejte heslo do tohoto pole',
    'Password must not match [_1]' => 'Heslo se nesmí shodovat [_1]',

    # H::F::Field::PasswordConf
    'Please enter a password confirmation' => 'Zadejte prosím potvrzení hesla',
    'The password confirmation does not match the password' => 'Potvrzovací heslo se neshoduje s heslem',

    # H::F::Field::PosInteger
    'Value must be a positive integer' => 'Hodnota musí být celé kladné číslo',

    # H::F::Field::Select
    'This field does not take multiple values' => 'Toto pole nepřijme více hodnot',
    '\'[_1]\' is not a valid value' => '\'[_1]\' je neplatná hodnota',

    # H::F::Field::Text
    'Field should not exceed [quant,_1,character]. You entered [_2]' => 'Pole nesmí být delší než [_1] znaků. Zadal jste [_2]',
    'Field must be at least [quant,_1,character]. You entered [_2]' => 'Pole musí obsahovat alespoň [_1] znaků. Zadal jste [_2]',

    # H::F::Field::Upload
    'File uploaded is empty' => 'Nahraný soubor je prázdný',
    'File is too small (< [_1] bytes)' => 'Soubor je příliš malý (< [_1] bajtů)',
    'File is too big (> [_1] bytes)' => 'Soubor je příliš velký (< [_1] bajtů)',
    'File not found for upload field' => 'Soubor pro upload nenalezen',

    # H::F::Model
    'Value must be unique in the database' => 'Hodnota musí být v databázi jedinečná',

  );

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

HTML::FormHandler::I18N::cs_cz - Czech message translations

=head1 AUTHOR

FormHandler Contributors - see HTML::FormHandler

Czech translation: Tomas Valousek tv@petamem.com

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Gerda Shank.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
