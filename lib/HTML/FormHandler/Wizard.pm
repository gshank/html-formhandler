package HTML::FormHandler::Wizard;
# ABSTRACT: create a multi-page form

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';
with ('HTML::FormHandler::BuildPages', 'HTML::FormHandler::Pages' );

=head1 SYNOPSIS

This feature is EXPERIMENTAL. That means that the interface may change,
and that it hasn't been fully implemented.
We are actively looking for input, so if you are interested in this
feature, please show up on the FormHandler mailing list or irc channel
(#formhandler on irc.perl.org) to discuss.

    package Test::Wizard;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Wizard';

    has_field 'foo';
    has_field 'bar';
    has_field 'zed';

    has_page 'one' => ( fields => ['foo'] );
    has_page 'two' => ( fields => ['bar'] );
    has_page 'three' => ( fields => ['zed'] );

    ...

    my $stash = {};
    my $wizard = Test::Wizard->new( stash => $stash );
    $wizard->process( params => $params );

=cut

sub is_wizard {1}

has_field 'page_num' => ( type => 'Hidden', default => 1 );

has 'on_last_page' => ( is => 'rw', isa => 'Bool', default => 0 );
has 'stash' => ( is => 'rw', isa => 'HashRef' );
has 'save_to' => ( is => 'rw', isa => 'Str' ); # 'item', 'stash', 'temp_table'

# temp_table: DBIC row or other object with three columns:
#    form, field, value
#
has 'temp_table' => ( is => 'rw' );

sub validated {
    my $self = shift;
    return $self->next::method && $self->on_last_page;
}

sub page_validated {
    my $self = shift;
    return $self->SUPER::validated;
}

sub build_active {
    my $self = shift;

    my @page_fields;
    foreach my $page ( $self->all_pages ) {
        push @page_fields, $page->all_fields;
    }
    foreach my $field_name ( @page_fields ) {
        $self->field($field_name)->inactive(1);
    }
}


sub set_active {
    my ( $self, $current_page ) = @_;;

    $current_page ||= $self->get_param('page_num') || 1;
    return if $current_page > $self->num_pages;
    $self->on_last_page(1) if $current_page == $self->num_pages;
    my $page = $self->get_page( $current_page - 1 );

    foreach my $fname ( $page->all_fields ) {
        my $field = $self->field($fname);
        if ( $field ) {
            $field->_active(1);
        }
        else {
            warn "field $fname not found for page " . $page->name;
        }
    }
}

after 'validate_form' => sub {
    my $self = shift;
    if( $self->page_validated ) {
        $self->save_page;
        if( $self->field('page_num')->value < $self->num_pages ) {
            my $new_page_num = $self->field('page_num')->value + 1;
            $self->clear_page;
            $self->set_active( $new_page_num );
            $self->_result_from_fields( $self->result );
            $self->field('page_num')->value($new_page_num);
            $self->on_last_page(1) if $new_page_num == $self->num_pages;
        }
        elsif( $self->field('page_num')->value == $self->num_pages ) {
            $self->_set_value( $self->stash );
        }
    }
};

sub clear_page {
    my $self = shift;
    $self->clear_data;
    $self->clear_params;
    $self->processed(0);
#   $self->did_init_obj(0);
    $self->clear_result;
}

sub save_page {
    my $self = shift;

    my $stash = $self->stash;
    while ( my ($key, $value) = each %{$self->value}) {
        $stash->{$key} = $value;
    }
}

1;
