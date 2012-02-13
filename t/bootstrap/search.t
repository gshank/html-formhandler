use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package MyApp::Form::Search::Theme;
    use Moose::Role;

    sub build_form_tags {{
        before => '<h3>Search form</h3><div class="row"><div class="span3"><p>Reflecting default WebKit styles, just add <code>.form-search</code> for extra rounded search fields.</p></div><div class="span9">',
        after => '</div></div>',
        no_form_message_div => 1,
    }}
    # classes for form element
    sub build_form_element_class { ['well', 'form-search'] }
    # field updates
    sub build_update_subfields {{
        searchterm => { widget_wrapper => 'None', element_attr => { class => ['input-medium', 'search-query'] }},
        submitbtn  => { widget => 'ButtonTag', widget_wrapper => 'None', element_attr => { class => ['btn'] } },
    }}
}
{
    package MyApp::Form::Search;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'MyApp::Form::Search::Theme';

    has '+name' => ( default => 'search_form' );
    has '+http_method' => ( default => 'get' );
    has_field 'searchterm' => ( type => 'Text' );
    has_field 'submitbtn' => ( type => 'Submit', value => 'Search' );

}

my $expected =
'<h3>Search form</h3>
  <div class="row">
    <div class="span3">
      <p>Reflecting default WebKit styles, just add <code>.form-search</code> for extra rounded search fields.</p>
    </div>
    <div class="span9">
      <form id="search_form" class="well form-search" method="get">
        <input name="searchterm" id="searchterm" type="text" class="input-medium search-query" value="" />
        <button name="submitbtn" id="submitbtn" type="submit" class="btn">Search</button>
      </form>
    </div>
  </div>';

my $form = MyApp::Form::Search->new;
$form->process;
my $rendered = $form->render;

is_html($rendered, $expected, 'renders correctly' );

done_testing;
