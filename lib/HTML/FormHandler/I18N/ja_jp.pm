package HTML::FormHandler::I18N::ja_jp;
# ABSTRACT: Japanese message file

use strict;
use warnings;
use utf8;
use base 'HTML::FormHandler::I18N';

# translator: Tomohiro Hosaka
# もっと良い訳に直してください！！

# Auto define lexicon
our %Lexicon = (
    '_AUTO' => 1,

    # H::F::Field
    'field is invalid' => 'フィールドが無効です。',
    'Wrong value' => '不正な値です。',
    '[_1] does not match' => '[_1]は一致しません。',
    '[_1] not allowed' => '[_1]は許可されません。',
    '[_1] field is required' => '[_1]を入力してください。',
    'error occurred' => 'エラーが起こりました。',
    'Value must be between [_1] and [_2]' => '値を[_1]から[_2]の間にしてください。',
    'Value must be greater than or equal to [_1]' => '値を[_1]以上にしてください。',
    'Value must be less than or equal to [_1]' => '値を[_1]以下にしてください。',

    # H::F::Types
    'Must be a positive number' => '数字を正の数にしてください。',
    'Must be a positive integer' => '数字を正の整数にしてください。',
    'Must be a negative number'  => '数字を負の数にしてください。',
    'Must be a negative integer' => '数字を負の整数にしてください。',
    'Must be a single digit' => '数字を一桁にしてください。',
    'Must be a non-empty single line of no more than 255 chars' => '空でない255字以下の文字列にしてください。',
    'Must be made up of letters, digits, and underscores' => '数字とハイフンとアンダースコアで構成してください。',
    'Not a valid IP address' => 'IPアドレスとして正しくありません。',
    'Must not be all digits' => '全て数字にすることはできません。',
    'Not a valid state' => '州として正しくありません。',
    'Field contains non-printable characters' => '表示できない文字を含んでいます。',
    'Must be between 4 and 255 chars' => '4字以上255字以下にしてください。',
    'Zip is not valid' => 'ZIP codeが正しくありません。',
    'Must be a single line of no more than 255 chars' => '255字以下の文字列にしてください。改行を含めることはできません。',
    'Email is not valid' => 'メールアドレスが正しくありません。',
    'Must not contain spaces' => 'スペースを含めることはできません。',
    'Field must contain a single word' => '単語を含めてください。',
    'Must not be empty' => '空にすることはできません。',
    'Must be between 8 and 255 chars, and contain a non-alpha char' => '8字以上255字以下の文字列で、アルファベット以外の文字を含めてください。',


    # H::F::Field::Date
    'Date is too early' => '日付が早すぎます。',
    'Date is too late'  => '日付が遅すぎます。',

    # H::F::Field::DateTime
    'Not a valid DateTime' => '日時が正しくありません。',

    # H::F::Field::Duration
    'Invalid value for [_1]: [_2]' => '無効な値です。[_1]([_2])',

    # H::F::Field::Email
    'Email should be of the format [_1]' => 'メールアドレスは次のようにしてください。[_1]',

    # H::F::Field::Integer
    'Value must be an integer' => '整数にしてください。',

    # H::F::Field::Money
    'Value cannot be converted to money' => '金額として認識できません。',
    'Value must be a real number' => '実数にしてください。l',

    # H::F::Field::Password
    'Please enter a password in this field' => 'パスワードを入力してください。',
    'Password must not match [_1]' => 'パスワードが「[_1]」と一致しています。',

    # H::F::Field::PasswordConf
    'Please enter a password confirmation' => 'パスワードの確認を入力してください。',
    'The password confirmation does not match the password' => 'パスワードの確認が入力されたパスワードと一致しません。',

    # H::F::Field::PosInteger
    'Value must be a positive integer' => '正の整数にしてください。',

    # H::F::Field::Select
    'This field does not take multiple values' => '複数選択することはできません。',
    '\'[_1]\' is not a valid value' => '「[_1]」は正しくありません。',

    # H::F::Field::Text
    'Field should not exceed [quant,_1,character]. You entered [_2]' => '[_1]字以下にしてください。[_2]字入力されています。',
    'Field must be at least [quant,_1,character]. You entered [_2]' => '[_1]字以上にしてください。[_2]字入力されています。',

    # H::F::Field::Upload
    'File uploaded is empty' => 'アップロードされたファイルは空でした。',
    'File is too small (< [_1] bytes)' => 'ファイルが小さすぎます。(< [_1] bytes)',
    'File is too big (> [_1] bytes)' => 'ファイルが大きすぎます。 (> [_1] bytes)',
    'File not found for upload field' => 'ファイルが見付かりません。',

    # H::F::Model
    'Value must be unique in the database' => 'データベース内でユニークな値にしてください。',
);

1;
