package HTML::FormHandler::I18N::ru_ru;
# ABSTRACT: Russian message file

use strict;
use warnings;
use utf8;
use base 'HTML::FormHandler::I18N';

# translator: Oleg Kostyuk
# notify before release: cub@cpan.org

# Auto define lexicon
our %Lexicon = (
    '_AUTO' => 1,

    # H::F::Field
    'field is invalid'                            => 'Поле неверно',
    'Wrong value'                                 => 'Неверное значение',
    '[_1] does not match'                         => 'не совпадает с [_1]',
    '[_1] not allowed'                            => '[_1] не разрешено',
    'Value must be between [_1] and [_2]'         => 'значение должно быть между [_1] и [_2]',
    'Value must be greater than or equal to [_1]' => 'значение должно быть больше или равно [_1]',
    'Value must be less than or equal to [_1]'    => 'значение должно быть меньше или равно [_1]',
    '[_1] field is required'                      => 'поле [_1] является обязательным',
    'error occurred'                              => 'произошла ошибка',

    # H::F::Types
    'Must be a positive number'                                     => 'Должно быть положительным числом',
    'Must be a positive integer'                                    => 'Должно быть положительным целым числом',
    'Must be a negative number'                                     => 'Должно быть отрицательным числом',
    'Must be a negative integer'                                    => 'Должно быть отрицательным целым числом',
    'Must be a single digit'                                        => 'Должно быть одной цифрой',
    'Must be a single line of no more than 255 chars'               => 'Должно быть одной строкой, не более 255 символов',
    'Must be a non-empty single line of no more than 255 chars'     => 'Должно быть не пустой строкой, не более 255 символов',
    'Must be between 4 and 255 chars'                               => 'Должно быть от 4 до 255 символов',
    'Not a valid state'                                             => 'Не верное состояние',
    'Email is not valid'                                            => 'Адрес электронной почты не корректен',
    'Zip is not valid'                                              => 'Почтовый индекс не корректен',
    'Not a valid IP address'                                        => 'IP адрес не корректен',
    'Must not contain spaces'                                       => 'Не может содержать пробелы',
    'Must be made up of letters, digits, and underscores'           => 'Должно состоять из букв, цифр и подчёркиваний',
    'Must not be all digits'                                        => 'Должно состоять не только из цифр',
    'Field contains non-printable characters'                       => 'Поле содержит непечатаемые символы',
    'Field must contain a single word'                              => 'Поле должно содержать одно слово',
    'Must not be empty'                                             => 'Должно быть не пустым',
    'Must be between 8 and 255 chars, and contain a non-alpha char' => 'Должно быть от 8 до 255 символов, и содержать не-буквенный символ',

    # H::F::Field::Date
    'Date is too early' => 'Слишком ранняя дата',
    'Date is too late'  => 'Слишком поздняя дата',

    # H::F::Field::DateTime
    'Not a valid DateTime' => 'Неверная дата/время',

    # H::F::Field::Duration
    'Invalid value for [_1]: [_2]' => 'Неверное значение для [_1]: [_2]',

    # H::F::Field::Email
    'Email should be of the format [_1]' => 'Адрес электронной почты должен быть в формате [_1]',

    # H::F::Field::Integer
    'Value must be an integer' => 'Значение должно быть целым числом',

    # H::F::Field::Money
    'Value cannot be converted to money' => 'Значение не может быть воспринято как денежное',
    'Value must be a real number'        => 'Значение должно быть вещественным числом',

    # H::F::Field::Password
    'Please enter a password in this field' => 'Пожалуйста, введите пароль',
    'Password must not match [_1]'          => 'Пароль должен не совпадать с [_1]',

    # H::F::Field::PasswordConf
    'Please enter a password confirmation'                  => 'Пожалуйста, введите подтверждение пароля',
    'The password confirmation does not match the password' => 'Подтверждение пароля не совпадает с паролем',

    # H::F::Field::PosInteger
    'Value must be a positive integer' => 'Значение должно быть положительным целым числом',

    # H::F::Field::Select
    'This field does not take multiple values' => 'Это поле не принимает несколько значений',
    '\'[_1]\' is not a valid value'            => '\'[_1]\' не корректное значение',

    # H::F::Field::Text
    'Field should not exceed [quant,_1,character]. You entered [_2]' => 'Символов должно быть не более [_1]. Вы ввели: [_2]',
    'Field must be at least [quant,_1,character]. You entered [_2]'  => 'Символов должно быть не менее [_1]. Вы ввели: [_2]',

    # H::F::Field::Upload
    'File uploaded is empty'           => 'Переданный файл пуст',
    'File is too small (< [_1] bytes)' => 'Файл слишком мал (менее [_1] байт)',
    'File is too big (> [_1] bytes)'   => 'Файл слишком велик (более [_1] байт)',
    'File not found for upload field'  => 'Файл для загрузки не найден',

    # H::F::Model
    'Value must be unique in the database' => 'Значение должно быть уникальным для базы данных',

    # Other
    'Your datetime does not match your pattern.' => 'Введённые дата/время не совпадают с вашим шаблоном.',
);

1;

