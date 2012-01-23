package HTML::FormHandler::I18N::tr_tr;
# ABSTRACT: Turkish message file

use strict;
use warnings;
use base 'HTML::FormHandler::I18N';

# Translated by Ozum Eldogan

use utf8;

# Auto define lexicon
our %Lexicon = (
    '_AUTO' => 1,

    # H::F::Field
    'field is invalid'                                          => 'Geçersiz değer',
    'Wrong value'                                               => 'Hatalı değer',
    '[_1] does not match'                                       => '[_1] formatı uymuyor',
    '[_1] not allowed'                                          => '[_1] izinli değil',
    'Value must be between [_1] and [_2]'                       => 'Değer [_1] ile [_2] arasında olmalı',
    'Value must be greater than or equal to [_1]'               => 'Değer [_1] veya daha yüksek olmalı',
    'Value must be less than or equal to [_1]'                  => 'Değer [_1] veya daha düşük olmalı',
    '[_1] field is required'                                    => '[_1] alanı boş bırakılamaz',
    'error occurred'                                            => 'Hata oluştu',

    # H::F::Types
    'Must be a positive number'                                 => 'Pozitif sayı olmalı',
    'Must be a positive integer'                                => 'Pozitif tam sayı olmalı',
    'Must be a negative number'                                 => 'Negatif sayı olmalı',
    'Must be a negative integer'                                => 'Negatif tam sayı olmalı',
    'Must be a single digit'                                    => 'Tek haneli bir sayı olmalı',
    'Must be a single line of no more than 255 chars'           => '255 karakterden kısa ve tek bir satır olmalı',
    'Must be a non-empty single line of no more than 255 chars' => 'Boş bırakılmamalı, 255 karakterden kısa ve tek bir satır olmalı',
    'Must be between 4 and 255 chars'                           => '4 ile 255 karakter arasında olmalı',
    'Not a valid state'                                         => 'Geçerli bir eyalet değil',
    'Email is not valid'                                        => 'Geçersiz E-Posta',
    'Zip is not valid'                                          => 'Geçersiz posta kodu',
    'Not a valid IP address'                                    => 'Geçersiz IP adresi',
    'Must not contain spaces'                                   => 'Boşluk içeremez',
    'Must be made up of letters, digits, and underscores'       => 'Sadece harf, rakam ya da "_" içerebilir',
    'Must not be all digits'                                    => 'Sadece rakamlardan oluşamaz',
    'Field contains non-printable characters'                   => 'Basılamayan karakterler içeriyor',
    'Field must contain a single word'                          => 'Tek bir kelime olmalı',
    'Must not be empty'                                         => 'Boş olmamalı',
    'Must be between 8 and 255 chars, and contain a non-alpha char' => 'Harf olmayan karakter içermeli ve 8-255 karakter arasında olmalı',

    # H::F::Field::Date
    'Date is too early'                                         => 'Bu tarih izin verilen en küçük tarihten daha önce',
    'Date is too late'                                          => 'Bu tarih izin verilen en büyük tarihten daha sonra',

    # H::F::Field::DateTime
    'Not a valid DateTime'                                      => 'Geçersiz tarih/zaman',

    # H::F::Field::Duration
    'Invalid value for [_1]: [_2]'                              => '[_1] için geçersiz değer: [_2]',

    # H::F::Field::Email
    'Email should be of the format [_1]'                        => 'E-Posta [_1] formatında olmalı',

    # H::F::Field::FloatNumber
    'Must be a number. May contain numbers, +, - and decimal separator \'[_1]\'', => 'Bir sayı olmalı. Rakamlar, +, -, ve ondalık ayırıcı \'[_1]\' içerebilir',
    'Total size of number must be less than or equal to [_1], but is [_2]', => 'Maksimum [_1] rakam içerebilir ama [_2] rakam içeriyor',
    'May have a maximum of [quant,_1,digit] after the decimal point, but has [_2]',  => 'Ayraçtan sonra maksimum [_1] rakam içerebilir ama [_2] rakam içeriyor',


    # H::F::Field::Integer
    'Value must be an integer'                                  => 'Tam sayı olmalı',

    # H::F::Field::Money
    'Value cannot be converted to money'                        => 'Değer para birimine çevrilemedi',
    'Value must be a real number'                               => 'Ondalık sayı olmalı',

    # H::F::Field::Password
    'Please enter a password in this field'                     => 'Lütfen bir şifre girin',
    'Password must not match [_1]'                              => 'Şifre [_1] ile aynı olmamalı',

    # H::F::Field::PasswordConf
    'Please enter a password confirmation'                      => 'Lütfen şifre onayı girin',
    'The password confirmation does not match the password'     => 'Şifre onayı ile şifre aynı değil',

    # H::F::Field::PosInteger
    'Value must be a positive integer'                          => 'Pozitif tam sayı olmalı',

    # H::F::Field::Select
    'This field does not take multiple values'                  => 'Birden fazla değer seçilemez',
    '\'[_1]\' is not a valid value'                             => '\'[_1]\' geçerli bir değer değil',

    # H::F::Field::Text
    'Field should not exceed [quant,_1,character]. You entered [_2]'  => 'Girilen verinin uzunluğu en fazla [_1] olabilir. Gönderilen: [_2]',
    'Field must be at least [quant,_1,character]. You entered [_2]'   => 'Girilen verinin uzunluğu en az [_1] olabilir. Gönderilen: [_2]',

    # H::F::Field::Upload
    'File uploaded is empty'                                    => 'Gönderilen dosya boş',
    'File is too small (< [_1] bytes)'                          => 'Dosya çok küçük. (< [_1] bytes)',
    'File is too big (> [_1] bytes)'                            => 'Dosya çok büyük. (> [_1] bytes)',
    'File not found for upload field'                           => 'Dosya bulunamadı',

    # H::F::Model
    'Value must be unique in the database'                      => 'Daha önceden kullanımda',

    # Other
    'Your datetime does not match your pattern.'                => 'Tarih formatı hatalı.',

  );

1;

__END__
=pod

=head1 NAME

HTML::FormHandler::I18N::tr_tr - Turkish message file

=head1 VERSION

version 0.35005

=head1 AUTHOR

FormHandler Contributors - see HTML::FormHandler

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Gerda Shank.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

