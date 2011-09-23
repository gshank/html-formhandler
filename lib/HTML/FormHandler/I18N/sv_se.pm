package HTML::FormHandler::I18N::sv_se;
# ABSTRACT: Swedish message translations

use strict;
use warnings;
use base 'HTML::FormHandler::I18N';

use utf8;

# Auto define lexicon
our %Lexicon = (
    '_AUTO' => 1,

    # H::F::Field
    'field is invalid' => 'Fältet är ogiltigt.',
    'Wrong value' => 'Ogiltigt värde.',
    '[_1] does not match' => '[_1] matchar inte.',
    '[_1] not allowed' => '[_1] är inte tillåtet.',
    '[_1] field is required' => 'Fältet får inte vara tomt.',
    'error occurred' => 'Ett fel har uppstått.',
    'Value must be between [_1] and [_2]' => 'Värdet ska ligga mellan [_1] och [_2].',
    'Value must be greater than or equal to [_1]' => 'Värdet ska vara minst [_1].',
    'Value must be less than or equal to [_1]' => 'Värdet får vara högst [_1].',

    # H::F::Types
    'Must be a positive number' => 'Ska vara ett positivt tal.',
    'Must be a positive integer' => 'Ska vara ett positivt heltal.',
    'Must be a negative number'  => 'Ska vara ett negativt tal.',
    'Must be a negative integer' => 'Ska vara ett negativt heltal.',
    'Must be a single digit' => 'Ska vara ett ensiffrigt tal.',
    'Must be a non-empty single line of no more than 255 chars' => 'Ska vara en enda rad med minst ett och högst 255 tecken.',
    'Must be made up of letters, digits, and underscores' => 'Får bara innehålla bokstäver, siffror och understreck.',
    'Not a valid IP address' => 'Ogiltig IP-adress.',
    'Must not be all digits' => 'Får inte vara enbart siffror.',
    'Not a valid state' => 'Ogiltig delstat.',
    'Field contains non-printable characters' => 'Fältet innehåller tecken som inte går att skriva ut.',
    'Must be between 4 and 255 chars' => 'Ska vara mellan 4 och 255 tecken.',
    'Zip is not valid' => 'Ogiltigt postnummer.',
    'Must be a single line of no more than 255 chars' => 'Ska vara en enda rad med högst 255 tecken.',
    'Email is not valid' => 'Ogiltig e-postadress.',
    'Must not contain spaces' => 'Får inte innehålla mellanslag.',
    'Field must contain a single word' => 'Ska vara ett enda ord.',
    'Must not be empty' => 'Ska inte vara tom.',
    'Must be between 8 and 255 chars, and contain a non-alpha char' => 'Ska vara mellan 8 och 255 tecken, och innehålla ett tecken som inte är en bokstav.',


    # H::F::Field::Date
    'Date is too early' => 'Datumet är för tidigt.',
    'Date is too late'  => 'Datumet är för sent.',

    # H::F::Field::DateTime
    'Not a valid DateTime' => 'Ogiltig datum- eller tidsangivelse.',

    # H::F::Field::Duration
    'Invalid value for [_1]: [_2]' => 'Ogiltigt värde för [_1]: [_2].',

    # H::F::Field::Email
    'Email should be of the format [_1]' => 'E-postadressen måste ha formatet [_1].',

    # H::F::Field::Integer
    'Value must be an integer' => 'Ska vara ett heltal.',

    # H::F::Field::Money
    'Value cannot be converted to money' => 'Kan inte läsas som en summa pengar.',
    'Value must be a real number' => 'Ska vara ett decimaltal.',

    # H::F::Field::Password
    'Please enter a password in this field' => 'Skriv ett lösenord i detta fält.',
    'Password must not match [_1]' => 'Lösenordet stämmer inte med [_1].',

    # H::F::Field::PasswordConf
    'Please enter a password confirmation' => 'Skriv lösenordet en gång till.',
    'The password confirmation does not match the password' => 'Lösenorden stämmer inte överens.',

    # H::F::Field::PosInteger
    'Value must be a positive integer' => 'Ska vara ett positivt heltal.',

    # H::F::Field::Select
    'This field does not take multiple values' => 'Välj inte mer än ett värde här.',
    '\'[_1]\' is not a valid value' => '\'[_1]\' är inte ett giltigt värde.',

    # H::F::Field::Text
    'Field should not exceed [quant,_1,character]. You entered [_2]' => 'Ska inte vara längre än [_1] tecken. Du har skrivit [_2].',
    'Field must be at least [quant,_1,character]. You entered [_2]' => 'Ska vara minst [_1] tecken. Du har skrivit [_2].',

    # H::F::Field::Upload
    'File uploaded is empty' => 'Fick ingen fil.',
    'File is too small (< [_1] bytes)' => 'Filen är för liten. (Mindre än [_1] bytes).',
    'File is too big (> [_1] bytes)' => 'Filen är för stor (Större än [_1] bytes).',
    'File not found for upload field' => 'Filen hittades inte.',

    # H::F::Model
    'Value must be unique in the database' => 'Värdet finns redan registrerat.',

  );

1;


