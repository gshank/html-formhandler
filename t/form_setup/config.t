use strict;
use warnings;
use Test::More;
use HTML::TreeBuilder;

BEGIN {
    plan skip_all => 'Template Toolkit required'
       unless eval { require Template };
    plan skip_all => 'Config::Any required'
       unless eval { require Config::Any };
    plan skip_all => 'YAML::Syck required'
       unless eval { require YAML::Syck };
}

use HTML::FormHandler::Foo;
use FindBin;

# test Foo class for loading form info from config

my $expected =
'<form action="/login" id="login_form" method="post">
<div class="text label">
<label>Username</label>
<input name="user" type="text" />
</div>
<div class="password label">
<label>Password</label>
<input name="pass" type="password" />
</div>
<div class="checkbox label">
<label>Opt in?</label>
<input name="opt_in" type="checkbox" value="1" />
</div>
<div class="submit">
<input name="submit" type="submit" value="Login" />
</div>
</form>
';

my $form = HTML::FormHandler::Foo->new( config_file => "$FindBin::Bin/../var/form1.yml" );
$form->process({});
is( $form->num_fields, 4, 'right number of fields');
my $tt_rendered_form = $form->tt_render;
ok($tt_rendered_form, 'form rendered');

my $expected_tree = HTML::TreeBuilder->new_from_content($expected);
my $tt_tree = HTML::TreeBuilder->new_from_content($tt_rendered_form);
is( $tt_tree->as_HTML, $expected_tree->as_HTML,
    "rendering matches expected output" );

done_testing;
