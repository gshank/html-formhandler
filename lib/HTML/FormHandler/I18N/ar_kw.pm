package HTML::FormHandler::I18N::ar_kw;
# ABSTRACT: Arabic message translations

use strict;
use warnings;
use base 'HTML::FormHandler::I18N';

use utf8;

# Auto define lexicon
our %Lexicon = (
    '_AUTO' => 1,

    # H::F
    'There were errors in your form'=> q(هناك أخطاء في مدخلات النموذج),

    # H::F::Field
    'field is invalid' => 'هذه الخانة غير صحيحة',
    'Wrong value' => 'قيمة خاطئة',
    '[_1] does not match' => '[_1] غير مطابق',
    '[_1] not allowed' => 'غير مسموح بـ [_1]',
    '[_1] field is required' => 'خانة [_1] إجبارية',
    'error occurred' => q(حدث خطأ),
    'Value must be between [_1] and [_2]' => 'هذه القيمة يجب أن تكون بين [_1] و [_2]',
    'Value must be greater than or equal to [_1]' => 'هذه القيمة يجب أن تكون أكبر من أو تساوي [_1]',
    'Value must be less than or equal to [_1]'    => 'هذه القيمة يجب أن تكون أصغر من أو تساوي [_1]',

    # H::F::Types
    'Must be a positive number' => 'يجب أن تكون هذه القيمة عددًا موجبًا',
    'Must be a positive integer' => 'يجب أن تكون هذه القيمة عددًا صحيحًا موجبًا',
    'Must be a negative number'  => 'يجب أن تكون هذه القيمة عددًا سالبًا',
    'Must be a negative integer' => 'يجب أن تكون هذه القيمة عددًا صحيحًا سالبًا',
    'Must be a single digit' => 'يجب أن تكون هذه القيمة رقمًا واحدًا فقط',
    'Must be a non-empty single line of no more than 255 chars' => 'يجب أن تكون هذه القيمة سطرًا واحدًا غير فارغ المحتوى ولا يتعدى ٢٥٥ حرفًا',
    'Must be made up of letters, digits, and underscores' => 'يجب أن تكون هذه القيمة مكونة من الأحرف والأرقام وعلامة "_"',
    'Not a valid IP address' => q{عنوان آي بي (IP) غير صحيح},
    'Must not be all digits' => 'يجب ألّا تكون هذه القيمة من الأرقام فقط',
    'Not a valid state' => 'هذه الحالة غير صحيحة',
    'Field contains non-printable characters' => 'تحتوي هذه الخانة على حروف غير قابلة للطباعة',
    'Must be between 4 and 255 chars' => 'عدد الأحرف يجب أن يكون بين ٤ و ٢٥٥',
    'Zip is not valid' => 'الرمز البريدي غير صحيح',
    'Must be a single line of no more than 255 chars' => 'يجب أن تكون هذه القيمة سطرًا واحدًا غير فارغ المحتوى ولا يتعدى ٢٥٥ حرفًا',
    'Email is not valid' => 'البريد الإلكتروني غير صحيح',
    'Must not contain spaces' => 'يجب ألّا تحتوي هذه القيمة على أية مسافات',
    'Field must contain a single word' => 'يجب أن تحتوي هذه الخانة على كلمة واحدة فقط',
    'Must not be empty' => 'لا يمكن ترك هذه الخانة فارغة',
    'Must be between 8 and 255 chars, and contain a non-alpha char' => 'يجب أن تحتوي هذه الخانة على حرف واحد غير أبجدي على الأقل وأن يكون عدد الأحرف بين ٨ و ٢٥٥',


    # H::F::Field::Date
    'Date is too early' => 'هذا التاريخ مبكر',
    'Date is too late'  => 'هذا التاريخ متأخر',
    'Your datetime does not match your pattern.'=>q(التاريخ والوقت المدخلان لا يتطابقان مع الصياغة),

    # H::F::Field::DateTime
    'Not a valid DateTime' => 'التاريخ والوقت غير صحيحان',


    # H::F::Field::Duration
    'Invalid value for [_1]: [_2]' => 'قيمة غير صحيحة لـ [_1]: [_2]',

    # H::F::Field::Email
    'Email should be of the format [_1]' => 'يجب أن يكون البريد الإلكتروني بصيغة [_1]',

    # H::F::Field::Integer
    'Value must be an integer' => 'يجب أن تكون هذه القيمة عددًا صحيحًا',

    # H::F::Field::Money
    'Value cannot be converted to money' => 'لا يمكن تحويل هذه القيمة إلى قيمة مالية',
    'Value must be a real number' => 'يجب أن تكون هذه القيمة عددًا حقيقيًا',

    # H::F::Field::Password
    'Please enter a password in this field' => 'يرجى إدخال كلمة السر في هذه الخانة',
    'Password must not match [_1]' => 'يجب ألّا تتطابق كلمة السر مع [_1]',

    # H::F::Field::PasswordConf
    'Please enter a password confirmation' => 'يجرى إعادة إدخال كلمة السر في خانة التأكيد',
    'The password confirmation does not match the password' => 'تأكيد كلمة السر لا يتطابق مع الخانة الأصلية',

    # H::F::Field::PosInteger
    'Value must be a positive integer' => 'يجب أن تكون هذه القيمة عددًا صحيحًا موجبًا',

    # H::F::Field::Select
    'This field does not take multiple values' => 'هذه الخانة لا تقبل عدة قيم',
    '\'[_1]\' is not a valid value' => '\'[_1]\' قيمة غير صحيحة',

    # H::F::Field::Text
    'Field should not exceed [quant,_1,character]. You entered [_2]' => 'هذه الخانة يجب ألّا تتعدى [quant,_1,حرف/حروف]. العدد المدخل هو [_2]',
    'Field must be at least [quant,_1,character]. You entered [_2]' => 'هذه الخانة يجب أن تحتوي على [quant,_1,حرف/حروف] على الأقل. العدد المدخل هو [_2]',

    # H::F::Field::Upload
    'File uploaded is empty' => 'الملف المرفوع فارغ',
    'File is too small (< [_1] bytes)' => 'الملف صغير جدًا (أقل من [_1] بايت)',
    'File is too big (> [_1] bytes)' => 'الملف كبير جدًا (أكبر من [_1] بايت)',
    'File not found for upload field' => q(لم يتم العثور على ملف خانة الرفع),

    # H::F::Model
    'Value must be unique in the database' => 'يجب أن تكون هذه القيمة فريدة من نوعها في قاعدة البيانات',
    # H::F::Widget::Theme::BootstrapFormMessages
    'There were errors in your form' => q(هناك أخطاء في مدخلات النموذج),
    'Your form was successfully submitted' => q(تم إرسال النموذج بنجاح),
  );

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

HTML::FormHandler::I18N::ar_kw - Arabic message translations

=head1 VERSION

version 0.40056

=head1 NAME

HTML::FormHandler::I18N::ar_kw - Arabic message translations

=head1 VERSION

version 0.40025

=head1 AUTHOR

FormHandler Contributors - see HTML::FormHandler

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Gerda Shank.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 AUTHOR

FormHandler Contributors - see HTML::FormHandler

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Gerda Shank.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
