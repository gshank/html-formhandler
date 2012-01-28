use strict;
use warnings;
use Test::More;
use HTML::FormHandler::Test;

{
    package MyApp::Form::Search;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+name' => ( default => 'search_form' );
    has '+http_method' => ( default => 'get' );
    has_field 'searchterm' => ( type => 'Text', widget_wrapper => 'None',
        html_attr => { class => ['input-medium', 'search-query'] } );
    has_field 'submitbtn' => ( type => 'Submit', widget => 'ButtonTag', widget_wrapper => 'None',
        value => 'Search', html_attr => { class => ['btn'] } );

    sub build_html_attr { { class => ['well', 'form-search'] } }
    sub render_before_form { '<h3>Search form</h3><div class="row"><div class="span3"><p>Reflecting default WebKit styles, just add <code>.form-search</code> for extra rounded search fields.</p></div><div class="span9">' }
    sub render_after_form { '</div></div>' }
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
