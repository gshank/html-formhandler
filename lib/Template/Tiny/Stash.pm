package Template::Tiny::Stash;

use Moose;

has vars => (is => 'rw', isa => 'HashRef', default => sub { {} });
has _sections => (is => 'rw', isa => 'HashRef[ArrayRef]', default => sub { {} });

sub BUILDARGS { return { vars => ($_[1]||{}) }; }

sub sections { @{ $_[0]->_sections->{$_[1]} || [] }; }
sub add_section {
    my ($self,$sec,@stashes) = @_;
    $self->_sections->{$sec} ||= [];
    push @{ $self->_sections->{$sec} }, (@stashes ? @stashes : undef); 
}

# XXX - add ability to deal with filters here
sub get { 
    # All values return are always strings
    "" . ( $_[0]->vars->{$_[1]} || '' ); 
}

__PACKAGE__->meta->make_immutable();
1;
