package HTML::FormHandler::I18N::ua_ua;
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
    'Date is too early' => 'Дата занадто рання',
    'Date is too late'  => 'Дата занадто піздня',

    # H::F::Field::DateTime
    'Not a valid DateTime' => 'Невірна дата/час',

    # H::F::Field::Email
    'Email should be of the format [_1]' => 'Адреса электроної пошти має бути у форматі [_1]',

    # H::F::Field::Integer
    'Value must be an integer' => 'Значення має бути цілим числом',

    # H::F::Field::Money
    'Value cannot be converted to money' => 'Значення не може бути сприйнято як грошове',
    'Value must be a real number'        => 'Значення має бути речовим числом',

    # H::F::Field::Password
    'Please enter a password in this field' => 'Будь ласка, введіть пароль',

    # H::F::Field::PasswordConf
    'Please enter a password confirmation' => 'Будь ласка, введіть підтвердження паролю',

    # H::F::Field::PosInteger
    'Value must be a positive integer' => 'Значення має бути позитивним цілим числом',

    # H::F::Field::Select
    'This field does not take multiple values' => 'Це поле не приймає кілька значень',

    # H::F::Field::Text
    'Please limit to [quant,_1,character]. You submitted [_2]'        => 'Символів має бути не більше [_1]. Ви ввели: [_2]',
    'Input must be at least [quant,_1,character]. You submitted [_2]' => 'Символів має бути не менше [_1]. Ви ввели: [_2]',

    # H:: F:: Field:: Upload
    'File uploaded is empty'          => 'Переданий файл порожній',
    'File is too small (<[_1] bytes)' => 'Файл занадто малий (менше [_1] байт)',
    'File is too big (> [_1] bytes)'  => 'Файл занадто великий (більше [_1] байт)',

    # H:: F:: Field
    'field is invalid' => 'Поле невірне',

    # H:: F:: Model
    'Value must be unique in the database' => 'Значення має бути унікальним для бази даних',

    # H:: F:: Types
    'Must be a positive number'                                 => 'Має бути позитивним числом',
    'Must be a positive integer'                                => 'Має бути позитивним цілим числом',
    'Must be a negative number'                                 => 'Має бути негативним числом',
    'Must be a negative integer'                                => 'Має бути негативним цілим числом',
    'Must be a single digit'                                    => 'Має бути однією цифрою',
    'Must be a single line of no more than 255 chars'           => 'Має бути одним рядком, не більше 255 символів',
    'Must be a non-empty single line of no more than 255 chars' => 'Має бути не пустим рядком, не більше 255 символів',
    'Must be between 4 and 255 chars'                           => 'Має бути від 4 до 255 символів',
    'Not a valid state'                                         => 'Не вірний стан',
    'Email is not valid'                                        => 'Адреса електронної пошти не коректна',
    'Zip is not valid'                                          => 'Поштовий індекс не коректний',
    'Not a valid IP address'                                    => 'IP адреса не коректна',
    'Cannot contain spaces'                                     => 'Не може мати пробіли',
    'Must be made up of letters, digits, and underscores'       => 'Має складатися з букв, цифр та підкреслень',
    'Must not be all digits'                                    => 'Має бути не тільки з цифр',
    'Field contains non-printable characters'                   => 'Поле містить недруковані символи',
    'Field must contain a single word'                          => 'Поле має містити одне слово',

    # H:: F:: Validate:: Actions
    'Wrong value'         => 'Неправильне значення',
    '[_1] does not match' => 'не співпадає з [_1]',
    '[_1] not allowed'    => '[_1] не дозволяється',

    # H:: F:: Validate
    'value must be between [_1] and [_2]'         => 'значення повинне бути між [_1] та [_2]',
    'value must be greater than or equal to [_1]' => 'значення повинне бути більше або дорівнювати [_1]',
    'value must be less than or equal to [_1]'    => 'значення повинне бути менше або дорівнювати [_1]',
    '[_1] field is required'                      => 'поле [_1] є обов\x{02BC}язковим',

    # Other
    'Your datetime does not match your pattern.' => 'Введені дата/час не співпадають з вашим шаблоном.',
    'error occurred'                             => 'трапилась помилка',
);

1;

