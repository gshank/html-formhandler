package HTML::FormHandler::Result::Role;

use Moose::Role;

=head1 NAME

HTML::FormHandler::Role::Result

=head1 SYNOPSIS

Role to hold common result attributes for L<HTML::FormHandler::Result>
and L<HTML::FormHandler::Result::Field>.

=cut

has 'name' => ( isa => 'Str', is => 'rw', required => 1 );

# do we need 'accessor' ?
has 'parent' => ( is => 'rw', weak_ref => 1 );

has 'input' => (
    is        => 'ro',
    clearer   => '_clear_input',
    writer    => '_set_input',
    predicate => 'has_input',
);

has 'value' => (
    is        => 'ro',
    writer    => '_set_value',
    clearer   => '_clear_value',
    predicate => 'has_value',
);

has '_results' => (
    traits    => ['Array'],
    isa        => 'ArrayRef[HTML::FormHandler::Field::Result]',
    is         => 'rw',
    default    => sub { [] },
    handles   => {
        results => 'elements', 
        add_result => 'push',
        num_results => 'count',
        has_results => 'count',
        clear_results => 'clear',
    }
);

has 'error_results' => (
    traits    => ['Array'],
    isa       => 'ArrayRef',            # for HFH::Result and HFH::Field::Result
    is        => 'rw',
    default   => sub { [] },
    handles  => {
        has_error_results => 'count',
        num_error_results => 'count',
        clear_error_results => 'clear',
        add_error_result => 'push',
    }
);

has 'errors' => (
    traits     => ['Array'],
    is         => 'rw',
    isa        => 'ArrayRef[Str]',
    default    => sub { [] },
    handles   => {
        all_errors  => 'elements',
        push_errors => 'push',
        num_errors => 'count',
        has_errors => 'count',
        clear_errors => 'clear',
    }
);

sub validated { !$_[0]->has_error_results && $_[0]->has_input }
sub is_valid { shift->validated }

sub field {
    my ( $self, $name, $die ) = @_;

    my $index;
    # if this is a full_name for a compound field
    # walk through the fields to get to it
    if ( $name =~ /\./ ) {
        my @names = split /\./, $name;
        my $f = $self;
        foreach my $fname (@names) {
            $f = $f->field($fname);
            return unless $f;
        }
        return $f;
    }
    else    # not a compound name
    {
        for my $field ( $self->results ) {
            return $field if ( $field->name eq $name );
        }
    }
    return unless $die;
    die "Field '$name' not found in '$self'";
}

=head1 AUTHORS

HTML::FormHandler Contributors; see HTML::FormHandler

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

use namespace::autoclean;
1;
