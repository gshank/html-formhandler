package HTML::FormHandler::I18N::de_de;
use strict;
use warnings;
use base 'HTML::FormHandler::I18N';

use utf8;

# Auto define lexicon
our %Lexicon = (
    '_AUTO' => 1,

    # H::F::Field::Date
    'Date is too early' => 'Datum ist zu früh',
    'Date is too late'  => 'Datum ist zu spät',

    # H::F::Field::DateTime
    'Not a valid DateTime' => 'Ungültige Datums-/Zeitangabe',

    # H::F::Field::Email
    'Email should be of the format [_1]' => 'E-Mail sollte die Form [_1] haben',

    # H::F::Field::Integer
    'Value must be an integer' => 'Muss eine positive ganze Zahl sein',

    # H::F::Field::Money
    'Value cannot be converted to money' => 'Wert kann nicht in Betrag konvertiert werden',
    'Value must be a real number' => 'Muss eine Dezimalzahl sein',

    # H::F::Field::Password
    'Please enter a password in this field' => 'Bitte ein Passwort eingeben',

    # H::F::Field::PasswordConf
    'Please enter a password confirmation' => 'Bitte das Passwort bestätigen',

    # H::F::Field::PosInteger
    'Value must be a positive integer' => 'Muss eine positive ganze Zahl sein',

    # H::F::Field::Select
    'This field does not take multiple values' => 'Mehrfachauswahl nicht erlaubt',

    # H::F::Field::Text
    'Please limit to [quant,_1,character]. You submitted [_2]' => 'Bitte auf [_1] Zeichen beschränken. Sie haben [_2] eingegeben',
    'Input must be at least [quant,_1,character]. You submitted [_2]' => 'Eingabe muss mindestens [_1] Zeichen lang sein. Sie haben nur [_2] eingegeben',

    # H::F::Field::Upload
    'File uploaded is empty' => 'Hochgeladene Datei ist leer',
    'File is too small (< [_1] bytes)' => 'Datei ist zu klein (< [_1] bytes)',
    'File is too big (> [_1] bytes)' => 'Datei ist zu groß (> [_1] bytes)',

    # H::F::Field
    'field is invalid' => 'Feld ist ungültig',
    
    # H::F::Model
    'Value must be unique in the database' => 'Wert existiert bereits in der Datenbank',

    # H::F::Types
    'Must be a positive number' => 'Muss eine positive Zahl sein',
    'Must be a positive integer' => 'Muss eine positive ganze Zahl sein',
    'Must be a negative number'  => 'Muss eine negative Zahl sein',
    'Must be a negative integer' => 'Muss eine negative ganze Zahl sein',
    'Must be a single digit' => 'Muss eine einzelne Ziffer sein',
    'Must be a single line of no more than 255 chars' => 'Muss eine einzelne Zeile (max. 255 Zeichen) sein',
    'Must be a non-empty single line of no more than 255 chars' => 'Muss eine nicht leere Zeile (max. 255 Zeichen) sein',
    'Must be between 4 and 255 chars' => '4 bis 255 Zeichen erforderlich',
    'Not a valid state' => 'Kein gültiger Bundesstaat',
    'Email is not valid' => 'E-Mail ist nicht gültig',
    'Zip is not valid' => 'PLZ ungültig',
    'Not a valid IP address' => 'IP Adresse ungültig',
    'Cannot contain spaces' => 'Darf keine Leerzeichen enthalten',
    'Must be made up of letters, digits, and underscores' => 'Darf nur Buchstaben, Ziffern oder "_" enthalten',
    'Must not be all digits' => 'Darf nicht nur Ziffern enthalten',
    'Field contains non-printable characters' => 'Feld enthält nicht druckbare Zeichen',
    'Field must contain a single word' => 'Feld muss ein einzelnes Wort enthalten',
    
    # H::F::Validate::Actions
    'Wrong value' => 'Ungültiger Wert',
    '[_1] does not match' => '[_1] ist kein gültiger Wert',
    '[_1] not allowed' => '[_1] ist nicht erlaubt',
    'error occurred' => 'Fehler aufgetreten',

    # H::F::Validate
    'value must be between [_1] and [_2]' => 'Wert muss zwischen [_1] und [_2] liegen',
    'value must be greater than or equal to [_1]' => 'Wert muss größer oder gleich [_1] sein',
    'value must be less than or equal to [_1]' => 'Wert muss kleiner oder gleich [_1] sein',

  );

1;




