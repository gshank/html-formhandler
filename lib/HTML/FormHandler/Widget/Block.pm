package HTML::FormHandler::Widget::Block;
# ABSTRACT: base block renderer

=head1 SYNOPSIS

Base block renderer to be used with L<HTML::FormHandler::Blocks>.

    has_block 'my_fieldset' => ( tag => 'fieldset',
        render_list => ['bar'], label => 'My Special Bar' );

=head1 ATTRIBUTES

=over 4

=item process_list

List of names of objects to render (fields and blocks)

=item tag

HTML tag for this block. Default 'div'.

=item class

Arrayref of classes for the HTML element.

=item attr

Other attributes for the HTML element.

=item label_tag

Tag to use for the label. Default: 'span'; default for 'fieldset' is 'legend'.

=item label_class

Classes for the label.

=item label

Label string. Will be localized.

=back 4

=cut

use Moose;
with 'HTML::FormHandler::TraitFor::Types';
use HTML::FormHandler::Render::Util ('process_attrs');
use HTML::FormHandler::Field;

has 'name' => ( is => 'ro', isa => 'Str', required => 1 );
has 'form' => ( is => 'ro', isa => 'HTML::FormHandler', required => 1 );

has 'class' => (
    is      => 'rw',
    isa     => 'HFH::ArrayRefStr',
    traits  => ['Array'],
    builder => 'build_class',
    handles => {
        has_class => 'count',
        add_class => 'push',
    }
);
sub build_class { [] }
has 'attr' => (
    is      => 'rw',
    traits  => ['Hash'],
    builder => 'build_attr',
    handles => {
        has_attr     => 'count',
        set__attr    => 'set',
        delete__attr => 'delete'
    },
);
sub build_attr { {} }
has 'wrapper' => ( is => 'rw', isa => 'Bool', default => 1 );
has 'tag' => ( is => 'rw', isa => 'Str', default => 'div' );
has 'label'     => ( is => 'rw', isa => 'Str', predicate => 'has_label' );
has 'label_tag' => ( is => 'rw', isa => 'Str' );
has 'label_class' => (
    is      => 'rw',
    isa     => 'HFH::ArrayRefStr',
    traits  => ['Array'],
    builder => 'build_label_class',
    handles => {
        has_label_class => 'count',
        add_label_class => 'push',
    }
);
sub build_label_class { [] }

has 'render_list' => (
    is      => 'rw',
    isa     => 'ArrayRef[Str]',
    traits  => ['Array'],
    builder => 'build_render_list',
    handles => {
        has_render_list    => 'count',
        add_to_render_list => 'push',
        all_render_list    => 'elements',
        get_render_list    => 'get',
    }
);
sub build_render_list { [] }

has 'content' => ( is => 'rw' );
has 'after_plist' => ( is => 'rw' );

sub render {
    my ( $self, $result ) = @_;
    $result ||= $self->form->result;

    my $start_wrapper = '';
    my $end_wrapper = '';
    if( $self->wrapper ) {
        my $tag = $self->tag;
        # create attribute string
        my $attr_str = $self->render_attribute_string;
        $start_wrapper = qq{<$tag$attr_str>};
        $end_wrapper = qq{</$tag>};
    }

    # get rendering of contained fields, if any
    my $rendered_fb = $self->render_process_list($result);

    my $content = $self->content || '';
    my $after_plist = $self->after_plist || '';

    # create label
    my $label = $self->render_label;
    my $block = qq{\n$start_wrapper$label$content$rendered_fb$after_plist$end_wrapper};

}

sub render_attribute_string {
    my $self = shift;
    my $attr = { %{ $self->attr } };
    $attr->{class} = $self->class if $self->has_class;
    my $attr_str = process_attrs($attr);
    return $attr_str;
}

sub render_label {
    my $self = shift;
    my $label = '';
    if ( $self->has_label ) {
        my $label_tag = $self->label_tag || 'span';
        $label_tag = 'legend' if lc $self->tag eq 'fieldset';
        my $label_str = $self->form->_localize( $self->label );
        my $attr_str  = '';
        $attr_str = process_attrs( { class => $self->label_class } ) if $self->has_label_class;
        $label = qq{<$label_tag$attr_str>$label_str</$label_tag>};
    }
    return $label;
}

sub render_process_list {
    my ( $self, $result ) = @_;

    my $output = '';
    if ( $self->has_render_list ) {
        foreach my $fb ( @{ $self->render_list } ) {
            # it's a Field
            if ( $self->form->field_in_index($fb) ) {
                # find field result and use that
                my $fld_result = $result->get_result($fb);
                # if no result, then we shouldn't be rendering this field
                next unless $fld_result;
                $output .= $fld_result->render;
            }
            # it's a Block
            else {
                # block can't be called from a field, so this should
                # always be the for result
                my $block = $self->form->block($fb);
                die "found no form field or block named '$fb'\n" unless $block;
                $output .= $block->render($result);
            }
        }
    }
    # else nothing to render from process_list
    return $output;
}

1;
