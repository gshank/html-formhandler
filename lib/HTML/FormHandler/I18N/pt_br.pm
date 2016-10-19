package HTML::FormHandler::I18N::pt_br;
# ABSTRACT: Brazilian Portuguese message file

use strict;
use warnings;
use utf8;
use base 'HTML::FormHandler::I18N';

# translator: Daniel Nicoletti
# notify before release: dantti12@gmail.com

# Auto define lexicon
our %Lexicon = (
    '_AUTO' => 1,

    # H:: F:: Field
    'field is invalid'                            => 'campo esta inválido',
    'Wrong value'                                 => 'Valor errado',
    '[_1] does not match'                         => '[_1] não coincide',
    '[_1] not allowed'                            => '[_1] não permitido',
    'Value must be between [_1] and [_2]'         => 'Valor deve estar entre [_1] e [_2]',
    'Value must be greater than or equal to [_1]' => 'Valor deve ser maior ou igual a [_1]',
    'Value must be less than or equal to [_1]'    => 'Valor deve ser menor ou igual a [_1]',
    '[_1] field is required'                      => '[_1] é obrigatório',
    'error occurred'                              => 'ocorreu um erro',

    # H:: F:: Types
    'Must be a positive number'                                     => 'Deve ser um número positivo',
    'Must be a positive integer'                                    => 'Deve ser um número inteiro positivo',
    'Must be a negative number'                                     => 'Deve ser um número negativo',
    'Must be a negative integer'                                    => 'Deve ser um número inteiro negativo',
    'Must be a single digit'                                        => 'Deve ser um único digito',
    'Must be a single line of no more than 255 chars'               => 'Deve ser uma única linha com não mais do que 255 caracteres',
    'Must be a non-empty single line of no more than 255 chars'     => 'Deve ser uma única linha não nula com não mais do que 255 caracteres',
    'Must be between 4 and 255 chars'                               => 'Deve ser entre 4 e 255 caracteres',
    'Not a valid state'                                             => 'Não é um estado válido',
    'Email is not valid'                                            => 'Email inválido',
    'Zip is not valid'                                              => 'CEP inválido',
    'Not a valid IP address'                                        => 'Endereço IP inválido',
    'Must not contain spaces'                                       => 'Não deve conter espaços',
    'Must be made up of letters, digits, and underscores'           => 'Deve conter letras, digitos e underscores',
    'Must not be all digits'                                        => 'Não pode ter todos os digitos',
    'Field contains non-printable characters'                       => 'Campo contém caracteres inválidos',
    'Field must contain a single word'                              => 'Campo deve conter uma única palavra',
    'Must not be empty'                                             => 'Não pode estar vazio',
    'Must be between 8 and 255 chars, and contain a non-alpha char' => 'Deve ser entre 8 e 255 caracteres, e conter um caractere não alfa numérico',

    # H::F::Field::Date
    'Date is too early' => 'A data é muito cedo',
    'Date is too late'  => 'A data é muito tarde',

    # H::F::Field::DateTime
    'Not a valid DateTime' => 'Data e hora inválidos',

    # H::F::Field::Duration
    'Invalid value for [_1]: [_2]' => 'Valor inválido para [_1]: [_2]',

    # H::F::Field::Email
    'Email should be of the format [_1]' => 'Email deve estar no formato [_1]',

    # H::F::Field::Integer
    'Value must be an integer' => 'Valor deve ser um inteiro',

    # H::F::Field::Money
    'Value cannot be converted to money' => 'Valor não pode ser convertido a dinheiro',
    'Value must be a real number'        => 'Valor deve ser um número real',

    # H::F::Field::Password
    'Please enter a password in this field' => 'Por favor coloque uma senha neste campo',
    'Password must not match [_1]'          => 'Senha não pode coincidir com [_1]',

    # H::F::Field::PasswordConf
    'Please enter a password confirmation'                  => 'Por favor confirme a senha',
    'The password confirmation does not match the password' => 'A confirmação da senha não coincide',

    # H::F::Field::PosInteger
    'Value must be a positive integer' => 'Valor deve ser um inteiro positivo',

    # H::F::Field::Select
    'This field does not take multiple values' => 'Este campo não recebe valores múltiplos',
    '\'[_1]\' is not a valid value'            => '\'[_1]\' é um valor inválido',

    # H::F::Field::Text
    'Field should not exceed [quant,_1,character]. You entered [_2]' => 'Campo não deve exceder [_1]. Você colocou: [_2]',
    'Field must be at least [quant,_1,character]. You entered [_2]'  => 'Campo deve ser ao menos [_1]. Você colocou: [_2]',

    # H:: F:: Field:: Upload
    'File uploaded is empty'           => 'Arquivo enviado está vazio',
    'File is too small (< [_1] bytes)' => 'Arquivo é muito pequeno (menor que [_1] bytes)',
    'File is too big (> [_1] bytes)'   => 'Arquivo é muito grande (maior que [_1] bytes)',
    'File not found for upload field'  => 'Arquivo não encontrado no campo de envio',

    # H:: F:: Model
    'Value must be unique in the database' => 'Valor deve ser único no banco de dados',

    # Other
    'Your datetime does not match your pattern.' => 'A sua data/hora náo coincide com o padrão.',
);

1;


__END__
=pod

=head1 NAME

HTML::FormHandler::I18N::pt_br - Brazilian Portuguese message file

=head1 AUTHOR

FormHandler Contributors - see HTML::FormHandler

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Gerda Shank.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

