package HTML::FormHandler::I18N::es_es;
# ABSTRACT: Spanish message translations - traduccion al español de los mensages

use strict;
use warnings;
use base 'HTML::FormHandler::I18N';

use utf8;
our $VERSION = '0.02';

# Auto define lexicon
our %Lexicon = (
    '_AUTO' => 1,

    # H::F
    'There were errors in your form'=> q(Hay errores en el formulario),

    # H::F::Field
    'field is invalid' => 'Campo invalido',
    'Wrong value' => 'Valor erróneo',
    '[_1] does not match' => '[_1] no concuerda',
    '[_1] not allowed' => '[_1] no permitido',
    '[_1] field is required' => 'El campo [_1] es obligatorio',
    'error occurred' => q(aparecio un error),
    'Value must be between [_1] and [_2]' => 'El valor ha de estar entre [_1] y [_2]',
    'Value must be greater than or equal to [_1]' => 'El valor ha de ser mayor o igual a[_1]',
    'Value must be less than or equal to [_1]'    => 'El valor ha de ser menor o igual a [_1]',

    # H::F::Types
    'Must be a positive number' => 'Ha de ser un numero positivo',
    'Must be a positive integer' => 'Ha de ser un entero positivo',
    'Must be a negative number'  => 'Ha de ser un numero negativo',
    'Must be a negative integer' => 'Ha de ser un entero negativo',
    'Must be a single digit' => 'Ha de ser de un solo dígito',
    'Must be a non-empty single line of no more than 255 chars' => 'Ha de ser una linea no vacía con 255 caracteres como maximo',
    'Must be made up of letters, digits, and underscores' => 'Solo se permiten letras, dígitos y "_"',
    'Not a valid IP address' => q(Dirección IP invalida),
    'Must not be all digits' => 'No pueden ser todo digitos',
    'Not a valid state' => 'No es un estado valido',
    'Field contains non-printable characters' => 'El campo contiene caracteres no imprimibles',
    'Must be between 4 and 255 chars' => 'Han de ser entre 4 y 255 caracteres',
    'Zip is not valid' => 'il CAP non è valido',
    'Must be a single line of no more than 255 chars' => 'Ha de ser una linea con 255 caracteres como maximo',
    'Email is not valid' => 'No es un E-mail valido',
    'Must not contain spaces' => 'No debe tener espacios',
    'Field must contain a single word' => 'El contenido ha de ser una sola palabra',
    'Must not be empty' => 'No puede estar vacio',
    'Must be between 8 and 255 chars, and contain a non-alpha char' => 'A de contener entre 8 y 255 caracteres y al menos uno no alfabético',


    # H::F::Field::Date
    'Date is too early' => 'La fecha es muy temprana',
    'Date is too late'  => 'La fecha es muy tardia',
    'Your datetime does not match your pattern.'=>q(El formato de la fecha no coincide con el patrón.),

    # H::F::Field::DateTime
    'Not a valid DateTime' => 'No es un DateTime valido',


    # H::F::Field::Duration
    'Invalid value for [_1]: [_2]' => 'Valor invalido para [_1]: [_2]',

    # H::F::Field::Email
    'Email should be of the format [_1]' => 'E-mail tiene que tener el formato [_1]',

    # H::F::Field::Integer
    'Value must be an integer' => 'Ha de ser un numero entero',

    # H::F::Field::Money
    'Value cannot be converted to money' => 'El valor no se puede transformar en moneda',
    'Value must be a real number' => 'Ha de ser un real',

    # H::F::Field::Password
    'Please enter a password in this field' => 'Teclea la contraseña aqui',
    'Password must not match [_1]' => 'La contraseña no ha de concordar con [_1]',

    # H::F::Field::PasswordConf
    'Please enter a password confirmation' => 'Repite la contraseña para confirmarla',
    'The password confirmation does not match the password' => 'La contraseña y la confirmación no coinciden',

    # H::F::Field::PosInteger
    'Value must be a positive integer' => 'Ha de ser un entero positivo',

    # H::F::Field::Select
    'This field does not take multiple values' => 'Este campo no admite valores multiples',
    '\'[_1]\' is not a valid value' => '\'[_1]\' es un valor invalido',

    # H::F::Field::Text
    'Field should not exceed [quant,_1,character]. You entered [_2]' => 'El campo no puede exceder de [quant,_1,carácter,caracteres]. Ahora hay [_2]',
    'Field must be at least [quant,_1,character]. You entered [_2]' => 'El campo ha de tener [quant,_1,carácter,caracteres] como minimo. Ahora hay [_2]',

    # H::F::Field::Upload
    'File uploaded is empty' => 'El fichero subido esta vacio',
    'File is too small (< [_1] bytes)' => 'Fichero demasiado pequeño (< [_1] bytes)',
    'File is too big (> [_1] bytes)' => 'Fichero demasiado grande (> [_1] bytes)',
    'File not found for upload field' => q(No se ha encontrado el fichero especificado),

    # H::F::Model
    'Value must be unique in the database' => 'El valor ha de ser único en la base de datos',
    # H::F::Widget::Theme::BootstrapFormMessages
    'There were errors in your form' => q(Hay errores en el formulario),
    'Your form was successfully submitted' => q(El formulario se envio correctamente),
  );

1;

__END__
=pod

=head1 NAME

HTML::FormHandler::I18N::es_es - Spanish message translations

=head1 VERSION

version 0.40025

=head1 AUTHOR

FormHandler Contributors - see HTML::FormHandler

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Gerda Shank.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


