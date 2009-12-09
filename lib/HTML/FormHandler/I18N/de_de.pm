package HTML::FormHandler::I18N::de_de;
use strict;
use warnings;
use base 'HTML::FormHandler::I18N';

use utf8;

# Auto define lexicon
our %Lexicon = (
    '_AUTO' => 1,
    
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
    
    # H::F::Field
    'field is invalid' => 'Feld ist ungültig',
    
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
    'Password cannot contain spaces' => 'Passwort darf keine Leerzeichen enthalten',
    'Password must be made up of letters, digits, and underscores' => 'Passwort darf nur Buchstaben, Ziffern oder "_" enthalten',
    'Password must not be all digits' => 'Passwort darf nicht nur Ziffern enthalten',
    'Field contains non-printable characters' => 'Enthält nicht druckbare Zeichen',
    'Field must contain a single word' => 'Muss ein einzelnes Wort sein',
    
    # H::F::Validate::Actions
    'Wrong value' => 'Ungültiger Wert',
    ### not translatable: '"$value" does not match' => '',
    ### not translatable: '"$value" not allowed' => '',
  );

1;




