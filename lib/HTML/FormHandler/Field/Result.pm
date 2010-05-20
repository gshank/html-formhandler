package HTML::FormHandler::Field::Result;

use Moose;
with 'HTML::FormHandler::Result::Role';

=head1 NAME

HTML::FormHandler::Field::Result

=head1 SYNOPSIS

Result class for L<HTML::FormHandler::Field>

=cut

has 'field_def' => (
    is     => 'ro',
    isa    => 'HTML::FormHandler::Field',
    writer => '_set_field_def',
);

sub fif {
    my $self = shift;
    return $self->field_def->fif($self);
}

sub fields_fif {
    my ( $self, $prefix ) = @_;
    return $self->field_def->fields_fif( $self, $prefix );
}

sub render {
    my $self = shift;
    return $self->field_def->render($self);
}


sub peek {
    my ( $self, $indent ) = @_;
    $indent ||= '';
    my $name = $self->field_def ? $self->field_def->full_name : $self->name;
    my $type = $self->field_def ? $self->field_def->type : 'unknown';
    my $string = $indent . "result " . $name . "  type: " . $type . "\n";
    if( $self->has_results ) {
        $indent .= '  ';
        foreach my $res ( $self->results ) {
            $string .= $res->peek( $indent );
        }
    }
    return $string;
}


=head1 AUTHORS

HTML::FormHandler Contributors; see HTML::FormHandler

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
