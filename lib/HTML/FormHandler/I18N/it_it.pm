package HTML::FormHandler::I18N::it_it;
# ABSTRACT: Italian message translations - traduzione italiana dei messaggi

use strict;
use warnings;
use base 'HTML::FormHandler::I18N';

use utf8;

# Auto define lexicon
our %Lexicon = (
    '_AUTO' => 1,

    # H::F
    'There were errors in your form'=> q(Alcuni dati sono sbagliati),

    # H::F::Field
    'field is invalid' => 'Campo non valido',
    'Wrong value' => 'Valore errato',
    '[_1] does not match' => '[_1] non combacia',
    '[_1] not allowed' => '[_1] non permesso',
    '[_1] field is required' => 'Il campo [_1] è obbligatorio',
    'error occurred' => q(C'è un errore),
    'Value must be between [_1] and [_2]' => 'Il valore deve essere compreso tra [_1] e [_2]',
    'Value must be greater than or equal to [_1]' => 'Il valore deve essere maggiore o eguale a [_1]',
    'Value must be less than or equal to [_1]'    => 'Il valore deve essere minore o eguale a [_1]',

    # H::F::Types
    'Must be a positive number' => 'Deve essere un numero positivo',
    'Must be a positive integer' => 'Deve essere un numero intero positivo',
    'Must be a negative number'  => 'Deve essere un numero negativo',
    'Must be a negative integer' => 'Deve essere un numero intero negativo',
    'Must be a single digit' => 'Deve essere di una singola cifra',
    'Must be a non-empty single line of no more than 255 chars' => 'Deve essere un testo di una riga, non vuoto e con un massimo di 255 caratteri',
    'Must be made up of letters, digits, and underscores' => 'Può essere composto da lettere, cifre e "_"',
    'Not a valid IP address' => q(L'indirizzo IP non è valido),
    'Must not be all digits' => 'Non devono essere solo cifre',
    'Not a valid state' => 'Non è uno stato valido',
    'Field contains non-printable characters' => 'Il campo contiene caratteri non stampabili',
    'Must be between 4 and 255 chars' => 'Deve essere tra 4 e 255 caratteri',
    'Zip is not valid' => 'il CAP non è valido',
    'Must be a single line of no more than 255 chars' => 'Deve essere una sola riga di testo con un massimo di 255 caratteri',
    'Email is not valid' => 'Non è un indirizzo E-mail',
    'Must not contain spaces' => 'Non deve contenere spazi',
    'Field must contain a single word' => 'Il campo deve contenere una sola parola',
    'Must not be empty' => 'Non può essere vuoto',
    'Must be between 8 and 255 chars, and contain a non-alpha char' => 'Deve essere tra 8 e 255 caratteri, e contenere non solo lettere',


    # H::F::Field::Date
    'Date is too early' => 'La data è troppo remota',
    'Date is too late'  => 'La data è troppo avanti',
    'Your datetime does not match your pattern.'=>q(Il formato della data non coincide con quello richiesto.),

    # H::F::Field::DateTime
    'Not a valid DateTime' => 'Non è un DateTime valido',


    # H::F::Field::Duration
    'Invalid value for [_1]: [_2]' => 'Durata non valida per [_1]: [_2]',

    # H::F::Field::Email
    'Email should be of the format [_1]' => 'E-mail deve essere nel formato [_1]',

    # H::F::Field::Integer
    'Value must be an integer' => 'Deve essere un numero intero',

    # H::F::Field::Money
    'Value cannot be converted to money' => 'Il valore non può essere converito in moneta',
    'Value must be a real number' => 'Deve essere un numero reale',

    # H::F::Field::Password
    'Please enter a password in this field' => 'Inserisci la password in questo campo',
    'Password must not match [_1]' => 'La password non deve coincidere con [_1]',

    # H::F::Field::PasswordConf
    'Please enter a password confirmation' => 'Ripeti la password quale verifica',
    'The password confirmation does not match the password' => 'La password di verifica non coincide',

    # H::F::Field::PosInteger
    'Value must be a positive integer' => 'Deve essere un intero positivo',

    # H::F::Field::Select
    'This field does not take multiple values' => 'Questo campo non accetta più di un valore',
    '\'[_1]\' is not a valid value' => '\'[_1]\' non è un valore valido',

    # H::F::Field::Text
    'Field should not exceed [quant,_1,character]. You entered [_2]' => 'Il campo non deve eccedere [quant,_1,carattere,caratteri]. Tu ne hai inseriti [_2]',
    'Field must be at least [quant,_1,character]. You entered [_2]' => 'Il campo deve essere di almeno [quant,_1,carattere,caratteri].  Tu ne hai inseriti [_2]',

    # H::F::Field::Upload
    'File uploaded is empty' => 'Il file inserito è vuoto',
    'File is too small (< [_1] bytes)' => 'Il file è troppo piccolo (< [_1] bytes)',
    'File is too big (> [_1] bytes)' => 'Il file è troppo grande (> [_1] bytes)',
    'File not found for upload field' => q(Il file nel campo di upload non esiste),

    # H::F::Model
    'Value must be unique in the database' => 'Il valore deve essere unico nella base dati',
    # H::F::Widget::Theme::BootstrapFormMessages
    'There were errors in your form' => q(Alcuni valori nel modulo sono sbagliati),
    'Your form was successfully submitted' => q(I valori sono stati inviati al server correttamente),
  );

1;

__END__
=pod

=head1 NAME

HTML::FormHandler::I18N::it_it - Italian message translations

=head1 AUTHOR

FormHandler Contributors - see HTML::FormHandler

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Gerda Shank.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

