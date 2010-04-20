package HTML::FormHandler::I18N::hu_hu;
use strict;
use warnings;
use utf8;
use base 'HTML::FormHandler::I18N';

# translator: Csaba Hetényi
# notify before release: cub@cpan.org

# Auto define lexicon
our %Lexicon = (
    '_AUTO' => 1,

    # H::F::Field::Date
    'Date is too early' => 'A dátum túl korai',
    'Date is too late'  => 'A dátum túl késő',

    # H::F::Field::DateTime
    'Not a valid DateTime' => 'Érvénytelen formátum',

    # H::F::Field::Email
    'Email should be of the format [_1]' => 'Az email [_1] formátumú legyen',

    # H::F::Field::Integer
    'Value must be an integer' => 'Az érték egész szám legyen',

    # H::F::Field::Money
    'Value cannot be converted to money' => 'Az érték nem alakítható pénz formátumra',
    'Value must be a real number'        => 'Az érték valós szám kell legyen',

    # H::F::Field::Password
    'Please enter a password in this field' => 'Légyszíves adj meg jelszót ebben a mezőben',

    # H::F::Field::PasswordConf
    'Please enter a password confirmation' => 'Jelszó megerősítése',

    # H::F::Field::PosInteger
    'Value must be a positive integer' => 'Pozitív egész szám szükséges',

    # H::F::Field::Select
    'This field does not take multiple values' => 'Ez a mező csak egy értéket kaphat',

    # H::F::Field::Text
    'Please limit to [quant,_1,character]. You submitted [_2]'        => 'A maximális hossz: [_1] karakter. A tiéd pedig: [_2]',
    'Input must be at least [quant,_1,character]. You submitted [_2]' => 'A minimális hossz: [_1] karakter. A tiéd pedig: [_2]',

    # H:: F:: Field:: Upload
    'File uploaded is empty'          => 'A feltöltött fájl üres',
    'File is too small (<[_1] bytes)' => 'A fájl túl kicsi (<[_1] byte)',
    'File is too big (> [_1] bytes)'  => 'A fájl túl nagy (>[_1] byte)',

    # H:: F:: Field
    'field is invalid' => 'A mező érvénytelen',

    # H:: F:: Model
    'Value must be unique in the database' => 'Az érték egyedi kell legyen az adatbázisban',

    # H:: F:: Types
    'Must be a positive number'                                 => 'Pozitív szám szükséges',
    'Must be a positive integer'                                => 'Pozitív egész szám szükséges',
    'Must be a negative number'                                 => 'Negatív szám szükséges',
    'Must be a negative integer'                                => 'Negatív egész szám szükséges',
    'Must be a single digit'                                    => 'Egy számjegy szükséges',
    'Must be a single line of no more than 255 chars'           => 'Egy sor legyen és ne legyen több 255 karakternél',
    'Must be a non-empty single line of no more than 255 chars' => 'Nem lehet üres sor és nem lehet több 255 karakternél',
    'Must be between 4 and 255 chars'                           => '4 és 255 karakter közt legyen',
    'Not a valid state'                                         => 'Érvénytelen állapot',
    'Email is not valid'                                        => 'Az email cím nem megfelelő',
    'Zip is not valid'                                          => 'Az irányítószám nem megfelelő',
    'Not a valid IP address'                                    => 'Az IP cím nem megfelelő',
    'Cannot contain spaces'                                     => 'Nem tartalmazhat szóközt',
    'Must be made up of letters, digits, and underscores'       => 'Csak betűket, számokat és alulvonást tartalmazhat',
    'Must not be all digits'                                    => 'Nem csak számok szükségesek',
    'Field contains non-printable characters'                   => 'A mező nem nyomtatható karaktert tartalmaz',
    'Field must contain a single word'                          => 'A mező csak egy szót tartalmazhat',

    # H:: F:: Validate:: Actions
    'Wrong value' => 'Rossz érték',
    # # # Not translatable: ' "$ value" does not match' =>'',
    # # # Not translatable: ' "$ value" not allowed' =>'',

    # H:: F:: Validate
    'value must be between [_1] and [_2]'         => 'az érték [_1] és [_2] között legyen',
    'value must be greater than or equal to [_1]' => 'az érték nagyobb vagy egyenlő legyen: [_1]',
    'value must be less than or equal to [_1]'    => 'az érték kisebb vagy egyenlő legyen: [_1]',
    '[_1] field is required'                      => 'A [_1] mező szükséges',

    # Other
    'Your datetime does not match your pattern.' => 'A datetime érték nem illeszkedik a mintára.',
);

1;

