package HTML::FormHandler::Result::Role;
# ABSTRACT: role with common code for form & field results

use Moose::Role;

=head1 NAME

HTML::FormHandler::Result::Role - common code for form & field results

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
        all_error_results => 'elements',
    }
);

has 'errors' => (
    traits     => ['Array'],
    is         => 'rw',
    isa        => 'ArrayRef[Str]',
    default    => sub { [] },
    handles   => {
        all_errors  => 'elements',
        _push_errors => 'push',
        num_errors => 'count',
        has_errors => 'count',
        clear_errors => 'clear',
    }
);

has 'warnings' => (
    traits     => ['Array'],
    is         => 'rw',
    isa        => 'ArrayRef[Str]',
    default    => sub { [] },
    handles   => {
        all_warnings  => 'elements',
        add_warning => 'push',
        num_warnings => 'count',
        has_warnings => 'count',
        clear_warnings => 'clear',
    }
);

sub validated { !$_[0]->has_error_results && $_[0]->has_input }
sub is_valid { shift->validated }

# this ought to be named 'result' for consistency,
# but the result objects are named 'result'.
# also providing 'field' method for compatibility
sub get_result {
    my ( $self, $name, $die ) = @_;

    my $index;
    # if this is a full_name for a compound field
    # walk through the fields to get to it
    if ( $name =~ /\./ ) {
        my @names = split /\./, $name;
        my $result = $self;
        foreach my $rname (@names) {
            $result = $result->get_result($rname);
            return unless $result
        }
        return $result;
    }
    else    # not a compound name
    {
        for my $result ( $self->results ) {
            return $result if ( $result->name eq $name );
        }
    }
    return unless $die;
    die "Field '$name' not found in '$self'";
}
sub field { shift->get_result(@_) }

use namespace::autoclean;
1;
