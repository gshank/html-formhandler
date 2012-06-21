use strict;
use warnings;
use Test::More;

{
  package MyApp::Form::SubmitType;
  use HTML::FormHandler::Moose;
  extends 'HTML::FormHandler';

  has_field 'submit' => (
    type => 'Submit', widget => 'ButtonTag',
  );

}

{
  my $form = MyApp::Form::SubmitType->new;
  ok( $form );

  my $rendered = $form->render;
  like($rendered, qr/type="submit"/,
       'Submit button has type "submit"');
}

{
  my $form = MyApp::Form::SubmitType->new(is_html5 => 1);
  ok( $form );

  my $rendered = $form->render;
  like($rendered, qr/type="submit"/,
       'Submit button has type "submit" for html5');
}

done_testing();
