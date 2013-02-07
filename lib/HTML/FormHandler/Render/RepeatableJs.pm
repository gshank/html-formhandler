package HTML::FormHandler::Render::RepeatableJs;
use Moose::Role;

use JSON ('encode_json');

=head1 NAME

HTML::FormHandler::Render::RepeatableJs

=head1 SYNOPSIS

Creates jQuery javascript to add and delete repeatable
elements.

Note: This is still EXPERIMENTAL.
This is an EXAMPLE.
Changes are very likely to occur.
Javascript is not guaranteed to be best practice.
It will not work on all rendered repeatables (requires wrapper with id).
It is strongly suggested that you make your own role if you use it.
Then you can modify it as needed.
Or just write out the rep_ data to javascript variables, and write the
function in javascript.
This function uses a plain javascript confirmation dialog.
You almost certainly want to do something else.
This javascript depends on the Bootstrap 'controls' div class
in order to position the new elements. You will have to modify
it to work if you don't use Bootstrap rendering.

A role to be used in a Form Class:

    package MyApp::Form::Test;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'HTML::FormHandler::Render::RepeatableJs';
    ...

=head2 DESCRIPTION

This contains one method, 'render_repeatable_js'. It's designed to be
used in a template, something like:

    [% WRAPPER "wrapper.tt" %]
    [% form.render_repeatable_js %]
    <h1>Editing Object .... </h1>
    [% form.render %]
    [% END -%]

It will render javascript which can be used with the AddElement field,
and setting the 'setup_for_js' flag in the Repeatable field to add
the ability to dynamically add a new repeatable element in a form.

Note: this code is provided as an example. You may need to write your
own javascript function if your situation is different.

Some of the extra information (level) in this function is in preparation for
handling nested repeatables, but it's not supported yet.

This function operates on HTML elements that have the id of the
repeatable element. That requires that the wrapper have the repeatable
instance ID (now rendered by default). If you don't have wrappers around
your repeatable elements, this won't work.

See HTML::FormHandler::Field::AddElement for an example of rendering
an HTML element that can be used to provide the AddElement button.
See that field for the requirements for the add HTML.

There is no example of a remove button because it's very basic
and there are too many different places to put it and ways to do it.
The main requirements are that the button have a 'data-rep-elem-id'
attribute that contains the id of the repeatable element to remove,
and a class of 'rm_element'. It should be a child field of the
repeatable.

This one works:

    has_field 'elements.rm_element' => (
        type => 'Display', render_method => \&render_rm_element );
    sub render_rm_element {
        my $self = shift;
        my $id = $self->parent->id;
        return qq{<span class="btn rm_element" data-rep-elem-id="$id">Remove</span>};
    }

=cut

sub render_repeatable_js {
    my $self = shift;
    return '' unless $self->has_for_js;

    my $for_js = $self->for_js;
    my %index;
    my %html;
    my %level;
    foreach my $key ( keys %$for_js ) {
        $index{$key} = $for_js->{$key}->{index};
        $html{$key} = $for_js->{$key}->{html};
        $level{$key} = $for_js->{$key}->{level};
    }
    my $index_str = encode_json( \%index );
    my $html_str = encode_json( \%html );
    my $level_str = encode_json( \%level );
    my $js = <<EOS;
<script>
\$(document).ready(function() {
  var rep_index = $index_str;
  var rep_html = $html_str;
  var rep_level = $level_str;
  \$('.add_element').click(function() {
    // get the repeatable id
    var data_rep_id = \$(this).attr('data-rep-id');
    // create a regex out of index placeholder
    var level = rep_level[data_rep_id]
    var re = new RegExp('\{index-' + level + '\}',"g");
    // replace the placeholder in the html with the index
    var index = rep_index[data_rep_id];
    var html = rep_html[data_rep_id];
    html = html.replace(re, index);
    // escape dots in element id
    var esc_rep_id = data_rep_id.replace(/[.]/g, '\\\\.');
    // append new element in the 'controls' div of the repeatable
    var rep_controls = \$('#' + esc_rep_id + ' > .controls');
    rep_controls.append(html);
    // increment index of repeatable fields
    index++;
    rep_index[data_rep_id] = index;
  });

  \$(document).on('click', '.rm_element', function() {
    cont = confirm('Remove?');
    if (cont) {
      var id = \$(this).attr('data-rep-elem-id');
      var esc_id = id.replace(/[.]/g, '\\\\.');
      var rm_elem = \$('#' + esc_id);
      rm_elem.remove();
    }
    event.preventDefault();
  });

});
</script>
EOS
    return $js;
}


1;
