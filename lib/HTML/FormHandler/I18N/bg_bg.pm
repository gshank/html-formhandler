package HTML::FormHandler::I18N::bg_bg;
# ABSTRACT: Bulgarian message file

use strict;
use warnings;
use utf8;
use base 'HTML::FormHandler::I18N';

# translator: Dimitar Petrov

# Auto define lexicon
our %Lexicon = (
    '_AUTO' => 1,

    # H::F::Field
    'field is invalid'                            => 'Полето не е валидно',
    'Wrong value'                                 => 'Грешна стойност',
    '[_1] does not match'                         => '[_1] не съвпада',
    '[_1] not allowed'                            => '[_1] не разрешено',
    'Value must be between [_1] and [_2]'         => 'стойността трябва да бъде между [_1] и [_2]',
    'Value must be greater than or equal to [_1]' => 'стойността трябва да бъде по-голяма или равна на [_1]',
    'Value must be less than or equal to [_1]'    => 'стойността трябва да бъде по-малка или равна на [_1]',
    '[_1] field is required'                      => 'полето [_1] е задължително',
    'error occurred'                              => 'възникна грешка',

    # H::F::Types
    'Must be a positive number'                                     => 'Трябва да бъде положително число',
    'Must be a positive integer'                                    => 'Трябва да бъде положително цяло число',
    'Must be a negative number'                                     => 'Трябва да бъде отрицателно число',
    'Must be a negative integer'                                    => 'Трябва да бъде отрицателно цяло число',
    'Must be a single digit'                                        => 'Трябва да бъде една цифра',
    'Must be a single line of no more than 255 chars'               => 'Трябва да бъде стойност с дължина не по-голяма от 255 символа',
    'Must be a non-empty single line of no more than 255 chars'     => 'Трябва да бъде непразна стойност с дължина не по-голяма от 255 символа',
    'Must be between 4 and 255 chars'                               => 'Трябва да бъде между 4 и 255 символа',
    'Not a valid state'                                             => 'Невалидно състояние',
    'Email is not valid'                                            => 'Невалидна електронна поща',
    'Zip is not valid'                                              => 'Невалиден пощенски код',
    'Not a valid IP address'                                        => 'Невалиден IP адрес',
    'Must not contain spaces'                                       => 'Не трябва да съдържа интервал',
    'Must be made up of letters, digits, and underscores'           => 'Трябва да се състои от букви, цифри и подчертавки',
    'Must not be all digits'                                        => 'Не трябва да съдържа само цифри',
    'Field contains non-printable characters'                       => 'Полето съдържа символи, които не могат да бъдат разпечатани',
    'Field must contain a single word'                              => 'Полето трябва да съдържа една дума',
    'Must not be empty'                                             => 'Не трябва да бъде празно',
    'Must be between 8 and 255 chars, and contain a non-alpha char' => 'Трябва да бъде между 8 и 255 символа и да съдържа поне един не-буквен символ',

    # H::F::Field::Date
    'Date is too early' => 'Датата е прекалено рано',
    'Date is too late'  => 'Датата е прекалено късно',

    # H::F::Field::DateTime
    'Not a valid DateTime' => 'Невалидна дата/време',

    # H::F::Field::Duration
    'Invalid value for [_1]: [_2]' => 'Невалидна стойност за [_1]: [_2]',

    # H::F::Field::Email
    'Email should be of the format [_1]' => 'Електронната поща трябва да бъде във формат [_1]',

    # H::F::Field::Integer
    'Value must be an integer' => 'Стойността трябва да бъде цяло число',

    # H::F::Field::Money
    'Value cannot be converted to money' => 'Стойността не може да бъде конвертирана към пари',
    'Value must be a real number'        => 'Стойнноста трябва да бъде естествено число',

    # H::F::Field::Password
    'Please enter a password in this field' => 'Моля въведете парола',
    'Password must not match [_1]'          => 'Паролата не съвпада с [_1]',

    # H::F::Field::PasswordConf
    'Please enter a password confirmation'                  => 'Моля, въведете парола за потвърждение',
    'The password confirmation does not match the password' => 'Въведената парола за потвърждение не съвпада с паролата',

    # H::F::Field::PosInteger
    'Value must be a positive integer' => 'Стойността трябва да бъде положително цяло число',

    # H::F::Field::Select
    'This field does not take multiple values' => 'Това поле не приема няколко стойности',
    '\'[_1]\' is not a valid value'            => '\'[_1]\' не е валидна стойност',

    # H::F::Field::Text
    'Field should not exceed [quant,_1,character]. You entered [_2]' => 'Стойността не трябва да надминава [_1]. Въвели сте: [_2]',
    'Field must be at least [quant,_1,character]. You entered [_2]'  => 'Стойността трябва да бъде поне [_1]. Въвели сте: [_2]',

    # H::F::Field::Upload
    'File uploaded is empty'           => 'Каченият файл е празен',
    'File is too small (< [_1] bytes)' => 'Файла е прекалено малък (< [_1] байта)',
    'File is too big (> [_1] bytes)'   => 'Файла е прекалено голям (> [_1] байта)',
    'File not found for upload field'  => 'Не е намерен файл файл за качване',

    # H::F::Model
    'Value must be unique in the database' => 'Стойността трябва да е уникална в базата от данни',

    # Other
    'Your datetime does not match your pattern.' => 'Въведената дата/време не съвпада с вашия шаблон.',
);

1;


__END__
=pod

=head1 NAME

HTML::FormHandler::I18N::bg_bg - Bulgarian message file

=head1 AUTHOR

FormHandler Contributors - see HTML::FormHandler

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Gerda Shank.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
