package HTML::FormHandler::I18N::tr_tr;
use strict;
use warnings;
use base 'HTML::FormHandler::I18N';

# Translated by Ozum Eldogan

use utf8;

# Auto define lexicon
our %Lexicon = (
    '_AUTO' => 1,
    
    # H::F::Field::Date
    'Date is too early' => 'Bu tarih izin verilen en küçük tarihten daha önce',
    'Date is too late' => 'Bu tarih izin verilen en büyük tarihten daha sonra',
    
    # H::F::Field::DateTime
    'Not a valid DateTime' => 'Geçersiz tarih/zaman',
      
    # H::F::Field::Email
    'Email should be of the format [_1]' => 'E-Posta [_1] formatında olmalı',
    
    # H::F::Field::Integer
    'Value must be an integer' => 'Tam sayı olmalı',
    
    # H::F::Field::Money
    'Value cannot be converted to money' => 'Değer para birimine çevrilemedi',
    'Value must be a real number' => 'Ondalık sayı olmalı',
    
    # H::F::Field::Password
    'Please enter a password in this field' => 'Lütfen bir şifre girin',
    
    # H::F::Field::PasswordConf
    'Please enter a password confirmation' => 'Lütfen şifre onayı girin',
    
    # H::F::Field::PosInteger
    'Value must be a positive integer' => 'Pozitif tam sayı olmalı',
    
    # H::F::Field::Select
    'This field does not take multiple values' => 'Birden fazla değer seçilemez',
    
    # H::F::Field::Text
    'Please limit to [quant,_1,character]. You submitted [_2]' => 'Girilen verinin uzunluğu en fazla [_1] olabilir. Gönderilen: [_2]',
    'Input must be at least [quant,_1,character]. You submitted [_2]' => 'Girilen verinin uzunluğu en az [_1] olabilir. Gönderilen: [_2]',
    
    # H::F::Field::Upload
    'File uploaded is empty' => 'Gönderilen dosya boş',
    'File is too small (< [_1] bytes)' => 'Dosya çok küçük. (< [_1] bytes)',
    'File is too big (> [_1] bytes)' => 'Dosya çok büyük. (> [_1] bytes)',
    
    # H::F::Field
    'field is invalid' => 'Geçersiz değer',

    # H::F::Model
    'Value must be unique in the database' => 'Daha önceden kullanımda',
    
    # H::F::Types
    'Must be a positive number' => 'Pozitif sayı olmalı',
    'Must be a positive integer' => 'Pozitif tam sayı olmalı',
    'Must be a negative number'  => 'Negatif sayı olmalı',
    'Must be a negative integer' => 'Negatif tam sayı olmalı',
    'Must be a single digit' => 'Tek haneli bir sayı olmalı',
    'Must be a single line of no more than 255 chars' => '255 karakterden kısa ve tek bir satır olmalı',
    'Must be a non-empty single line of no more than 255 chars' => 'Boş bırakılmamalı, 255 karakterden kısa ve tek bir satır olmalı',
    'Must be between 4 and 255 chars' => '4 ile 255 karakter arasında olmalı',
    'Not a valid state' => 'Geçerli bir eyalet değil',
    'Email is not valid' => 'Geçersiz E-Posta',
    'Zip is not valid' => 'Geçersiz posta kodu',
    'Not a valid IP address' => 'Geçersiz IP adresi',
    'Cannot contain spaces' => 'Boşluk içeremez',
    'Must be made up of letters, digits, and underscores' => 'Sadece harf, rakam ya da "_" içerebilir',
    'Must not be all digits' => 'Sadece rakamlardan oluşamaz',
    'Field contains non-printable characters' => 'Basılamayan karakterler içeriyor',
    'Field must contain a single word' => 'Tek bir kelime olmalı',
   
    # H::F::Validate::Actions
    'Wrong value' => 'Hatalı değer',
    ### not translatable: '"$value" does not match' => '',
    ### not translatable: '"$value" not allowed' => '',

    # H::F::Validate
    'value must be between [_1] and [_2]' => 'değer [_1] ile [_2] arasında olmalı',
    'value must be greater than or equal to [_1]' => 'değer [_1] veya daha yüksek olmalı',
    'value must be less than or equal to [_1]' => 'değer [_1] veya daha düşük olmalı',

    # Other
    'Your datetime does not match your pattern.' => 'Tarih formatı hatalı.',
    
    
  );

1;




