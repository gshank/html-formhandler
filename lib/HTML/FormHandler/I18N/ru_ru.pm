package HTML::FormHandler::I18N::ru_ru;
use strict;
use warnings;
use utf8;
use base 'HTML::FormHandler::I18N';

# translator: Oleg Kostyuk
# notify before release: cub@cpan.org

# Auto define lexicon
our %Lexicon = (
    '_AUTO' => 1,

    # H::F::Field::Date
    'Date is too early' => 'Слишком ранняя дата',
    'Date is too late'  => 'Слишком поздняя дата',

    # H::F::Field::DateTime
    'Not a valid DateTime' => 'Неверная дата/время',

    # H::F::Field::Email
    'Email should be of the format [_1]' => 'Адрес электронной почты должен быть в формате [_1]',

    # H::F::Field::Integer
    'Value must be an integer' => 'Значение должно быть целым числом',

    # H::F::Field::Money
    'Value cannot be converted to money' => 'Значение не может быть воспринято как денежное',
    'Value must be a real number'        => 'Значение должно быть вещественным числом',

    # H::F::Field::Password
    'Please enter a password in this field' => 'Пожалуйста, введите пароль',

    # H::F::Field::PasswordConf
    'Please enter a password confirmation' => 'Пожалуйста, введите подтверждение пароля',

    # H::F::Field::PosInteger
    'Value must be a positive integer' => 'Значение должно быть положительным целым числом',

    # H::F::Field::Select
    'This field does not take multiple values' => 'Это поле не принимает несколько значений',

    # H::F::Field::Text
    'Please limit to [quant,_1,character]. You submitted [_2]'        => 'Символов должно быть не более [_1]. Вы ввели: [_2]',
    'Input must be at least [quant,_1,character]. You submitted [_2]' => 'Символов должно быть не менее [_1]. Вы ввели: [_2]',

    # H::F::Field::Upload
    'File uploaded is empty'           => 'Переданный файл пуст',
    'File is too small (< [_1] bytes)' => 'Файл слишком мал (менее [_1] байт)',
    'File is too big (> [_1] bytes)'   => 'Файл слишком велик (более [_1] байт)',

    # H::F::Field
    'field is invalid' => 'Поле неверно',

    # H::F::Model
    'Value must be unique in the database' => 'Значение должно быть уникальным для базы данных',

    # H::F::Types
    'Must be a positive number'                                 => 'Должно быть положительным числом',
    'Must be a positive integer'                                => 'Должно быть положительным целым числом',
    'Must be a negative number'                                 => 'Должно быть отрицательным числом',
    'Must be a negative integer'                                => 'Должно быть отрицательным целым числом',
    'Must be a single digit'                                    => 'Должно быть одной цифрой',
    'Must be a single line of no more than 255 chars'           => 'Должно быть одной строкой, не более 255 символов',
    'Must be a non-empty single line of no more than 255 chars' => 'Должно быть не пустой строкой, не более 255 символов',
    'Must be between 4 and 255 chars'                           => 'Должно быть от 4 до 255 символов',
    'Not a valid state'                                         => 'Не верное состояние',
    'Email is not valid'                                        => 'Адрес электронной почты не корректен',
    'Zip is not valid'                                          => 'Почтовый индекс не корректен',
    'Not a valid IP address'                                    => 'IP адрес не корректен',
    'Cannot contain spaces'                                     => 'Не может содержать пробелы',
    'Must be made up of letters, digits, and underscores'       => 'Должно состоять из букв, цифр и подчёркиваний',
    'Must not be all digits'                                    => 'Должно состоять не только из цифр',
    'Field contains non-printable characters'                   => 'Поле содержит непечатаемые символы',
    'Field must contain a single word'                          => 'Поле должно содержать одно слово',

    # H::F::Validate::Actions
    'Wrong value'         => 'Неверное значение',
    '[_1] does not match' => 'не совпадает с [_1]',
    '[_1] not allowed'    => '[_1] не разрешено',

    # H::F::Validate
    'value must be between [_1] and [_2]'         => 'значение должно быть между [_1] и [_2]',
    'value must be greater than or equal to [_1]' => 'значение должно быть больше или равно [_1]',
    'value must be less than or equal to [_1]'    => 'значение должно быть меньше или равно [_1]',
    '[_1] field is required'                      => 'поле [_1] является обязательным',

    # Other
    'Your datetime does not match your pattern.' => 'Введённые дата/время не совпадают с вашим шаблоном.',
    'error occurred'                             => 'произошла ошибка',
);

1;

