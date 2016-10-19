package HTML::FormHandler::I18N::ca_es;
# ABSTRACT: Catalan message translations - traducion catalana  dels missatges

use strict;
use warnings;
use base 'HTML::FormHandler::I18N';

use utf8;

# Auto define lexicon
our %Lexicon = (
    '_AUTO' => 1,

    # H::F
    'There were errors in your form'=> q(El formulari te errors),

    # H::F::Field
    'field is invalid' => 'Campo invalido',
    'Wrong value' => 'Valor incorrecte',
    '[_1] does not match' => '[_1] no coincideix',
    '[_1] not allowed' => '[_1] no permès',
    '[_1] field is required' => 'El campo [_1] es requerit',
    'error occurred' => q(hi ha errors),
    'Value must be between [_1] and [_2]' => 'El valor ha de ser entre [_1] i [_2]',
    'Value must be greater than or equal to [_1]' => 'El valor ha de ser major o igual que [_1]',
    'Value must be less than or equal to [_1]'    => 'El valor ha ser minor o igual que [_1]',

    # H::F::Types
    'Must be a positive number' => 'Ha de ser un nombre positivo',
    'Must be a positive integer' => 'Ha de ser un nombre enter positivo',
    'Must be a negative number'  => 'Ha de ser un nombre negativo',
    'Must be a negative integer' => 'Ha de ser un nombre enter negativo',
    'Must be a single digit' => 'Ha de ser un sols dígit',
    'Must be a non-empty single line of no more than 255 chars' => 'Ha de ser una línia text no buit de un màxim de 256 caràcters',
    'Must be made up of letters, digits, and underscores' => 'Nomes poden haver lletres dígits i "_"',
    'Not a valid IP address' => q(L'adreça IP es invalida),
    'Must not be all digits' => 'Hi ha de haver algun caràcter no numèric',
    'Not a valid state' => 'No es un estat valid',
    'Field contains non-printable characters' => 'El campo conte caràcters no imprimibles',
    'Must be between 4 and 255 chars' => 'Ha de ser entre 4 i 255 caràcters',
    'Zip is not valid' => 'codi postal invalid',
    'Must be a single line of no more than 255 chars' => 'Ha de ser una línia text no buit de un màxim de 256 caràcters',
    'Email is not valid' => q(Adreça d'E-mail invalida),
    'Must not contain spaces' => 'No poden haver espais',
    'Field must contain a single word' => 'El campo ha de ser una sola paraula',
    'Must not be empty' => 'No pot ser buit',
    'Must be between 8 and 255 chars, and contain a non-alpha char' => 'hi ha de ser entre 8 i 255 caràcters i no tots lletres',


    # H::F::Field::Date
    'Date is too early' => 'La data ha de ser posterior',
    'Date is too late'  => 'La data ha de ser anterior',
    'Your datetime does not match your pattern.'=>q(El formato de la data no es l'esperat.),

    # H::F::Field::DateTime
    'Not a valid DateTime' => 'No es una DateTime valida',


    # H::F::Field::Duration
    'Invalid value for [_1]: [_2]' => 'Duració invalida per [_1]: [_2]',

    # H::F::Field::Email
    'Email should be of the format [_1]' => 'E-mail ha de ser del següent format [_1]',

    # H::F::Field::Integer
    'Value must be an integer' => 'Ha de ser un enter',

    # H::F::Field::Money
    'Value cannot be converted to money' => 'El valor no es pot convertir a moneda',
    'Value must be a real number' => 'ha de ser un nombre real',

    # H::F::Field::Password
    'Please enter a password in this field' => 'Introdueix el mot de pas en aquest camp',
    'Password must not match [_1]' => 'El mot de pas no pot coincidir amb [_1]',

    # H::F::Field::PasswordConf
    'Please enter a password confirmation' => 'Repeteix el mot de pas per verificar-ho',
    'The password confirmation does not match the password' => 'Els mot de pas no coincideixen',

    # H::F::Field::PosInteger
    'Value must be a positive integer' => 'Ha de ser un enter positiu',

    # H::F::Field::Select
    'This field does not take multiple values' => q(Aquest camp no permet mes d'un valor),
    '\'[_1]\' is not a valid value' => '\'[_1]\' es un valor invalid',

    # H::F::Field::Text
    'Field should not exceed [quant,_1,character]. You entered [_2]' => 'El camp non ha de tenir mes de [quant,_1,caràcter,caràcters]. Hi ha [_2]',
    'Field must be at least [quant,_1,character]. You entered [_2]' => 'El camp ha de tenir almeys [quant,_1,caràcter,caràcters]. Hi ha [_2]',

    # H::F::Field::Upload
    'File uploaded is empty' => 'El fitxer pujat es buit',
    'File is too small (< [_1] bytes)' => 'Fitxer massa petit (< [_1] bytes)',
    'File is too big (> [_1] bytes)' => 'Fitxer massa gran (> [_1] bytes)',
    'File not found for upload field' => q(El fitxer especificat no existeix),

    # H::F::Model
    'Value must be unique in the database' => 'El valor ha de ser únic a la base de dades',
    # H::F::Widget::Theme::BootstrapFormMessages
    'There were errors in your form' => q(Hi ha errors al formulari),
    'Your form was successfully submitted' => q(El formulari s'ha enviat correctament),
  );

1;

__END__
=pod

=head1 NAME

HTML::FormHandler::I18N::ca_es - Catalan message translations

=head1 AUTHOR

FormHandler Contributors - see HTML::FormHandler

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Gerda Shank.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

