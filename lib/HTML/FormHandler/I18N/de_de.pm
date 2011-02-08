package HTML::FormHandler::I18N::de_de;
# ABSTRACT: German message translations

use strict;
use warnings;
use base 'HTML::FormHandler::I18N';

use utf8;

# Auto define lexicon
our %Lexicon = (
    '_AUTO' => 1,

    # H::F::Field
    'field is invalid' => 'Feld ist ungültig',
    'Wrong value' => 'Ungültiger Wert',
    '[_1] does not match' => '[_1] ist kein gültiger Wert',
    '[_1] not allowed' => '[_1] ist nicht erlaubt',
    '[_1] field is required' => '...',
    'error occurred' => 'Fehler aufgetreten',
    'Value must be between [_1] and [_2]' => 'Wert muss zwischen [_1] und [_2] liegen',
    'Value must be greater than or equal to [_1]' => 'Wert muss größer oder gleich [_1] sein',
    'Value must be less than or equal to [_1]' => 'Wert muss kleiner oder gleich [_1] sein',

    # H::F::Types
    'Must be a positive number' => 'Muss eine positive Zahl sein',
    'Must be a positive integer' => 'Muss eine positive ganze Zahl sein',
    'Must be a negative number'  => 'Muss eine negative Zahl sein',
    'Must be a negative integer' => 'Muss eine negative ganze Zahl sein',
    'Must be a single digit' => 'Muss eine einzelne Ziffer sein',
    'Must be a non-empty single line of no more than 255 chars' => 'Muss eine nicht leere Zeile (max. 255 Zeichen) sein',
    'Must be made up of letters, digits, and underscores' => 'Darf nur Buchstaben, Ziffern oder "_" enthalten',
    'Not a valid IP address' => 'IP Adresse ungültig',
    'Must not be all digits' => 'Darf nicht nur Ziffern enthalten',
    'Not a valid state' => 'Kein gültiger Bundesstaat',
    'Field contains non-printable characters' => 'Feld enthält nicht druckbare Zeichen',
    'Must be between 4 and 255 chars' => '4 bis 255 Zeichen erforderlich',
    'Zip is not valid' => 'PLZ ungültig',
    'Must be a single line of no more than 255 chars' => 'Muss eine einzelne Zeile (max. 255 Zeichen) sein',
    'Email is not valid' => 'E-Mail ist nicht gültig',
    'Must not contain spaces' => 'Darf keine Leerzeichen enthalten',
    'Field must contain a single word' => 'Feld muss ein einzelnes Wort enthalten',
    'Must not be empty' => '...',
    'Must be between 8 and 255 chars, and contain a non-alpha char' => '...',


    # H::F::Field::Date
    'Date is too early' => 'Datum ist zu früh',
    'Date is too late'  => 'Datum ist zu spät',

    # H::F::Field::DateTime
    'Not a valid DateTime' => 'Ungültige Datums-/Zeitangabe',

    # H::F::Field::Duration
    'Invalid value for [_1]: [_2]' => '.....',

    # H::F::Field::Email
    'Email should be of the format [_1]' => 'E-Mail sollte die Form [_1] haben',

    # H::F::Field::Integer
    'Value must be an integer' => 'Muss eine positive ganze Zahl sein',

    # H::F::Field::Money
    'Value cannot be converted to money' => 'Wert kann nicht in Betrag konvertiert werden',
    'Value must be a real number' => 'Muss eine Dezimalzahl sein',

    # H::F::Field::Password
    'Please enter a password in this field' => 'Bitte ein Passwort eingeben',
    'Password must not match [_1]' => '....',

    # H::F::Field::PasswordConf
    'Please enter a password confirmation' => 'Bitte das Passwort bestätigen',
    'The password confirmation does not match the password' => '...',

    # H::F::Field::PosInteger
    'Value must be a positive integer' => 'Muss eine positive ganze Zahl sein',

    # H::F::Field::Select
    'This field does not take multiple values' => 'Mehrfachauswahl nicht erlaubt',
    '\'[_1]\' is not a valid value' => '...',

    # H::F::Field::Text
    'Field should not exceed [quant,_1,character]. You entered [_2]' => 'Bitte auf [_1] Zeichen beschränken. Sie haben [_2] eingegeben',
    'Field must be at least [quant,_1,character]. You entered [_2]' => 'Eingabe muss mindestens [_1] Zeichen lang sein. Sie haben nur [_2] eingegeben',

    # H::F::Field::Upload
    'File uploaded is empty' => 'Hochgeladene Datei ist leer',
    'File is too small (< [_1] bytes)' => 'Datei ist zu klein (< [_1] bytes)',
    'File is too big (> [_1] bytes)' => 'Datei ist zu groß (> [_1] bytes)',
    'File not found for upload field' => '...',

    # H::F::Model
    'Value must be unique in the database' => 'Wert existiert bereits in der Datenbank',

  );

1;




