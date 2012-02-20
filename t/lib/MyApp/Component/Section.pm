package MyApp::Component::Section;

sub new {
    my ( $class, %args ) = @_;
    return bless \%args, $class;
}

sub form {
    my $self = shift;
    return $self->{form};
}

sub render {
    return
'<div class="intro">
  <h3>Please enter the relevant details</h3>
</div>';
}

1;
