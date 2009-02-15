package BookDB::Form::BookAuto;

use Moose;
extends 'HTML::FormHandler::Model::DBIC';

=head1 NAME

Form object for the Book Controller

=head1 SYNOPSIS

Form used for book/add and book/edit actions

=head1 DESCRIPTION

Catalyst Form.

=cut

has '+item_class' => ( default => 'Book' );
has '+name_prefix' => ( default => 'book' );

__PACKAGE__->meta->make_immutable;

sub field_list {
	return {
		auto_required => ['title', 'author', 'isbn', 'publisher'],
        auto_optional => ['genres', 'format', 'year', 'pages'], 
	};
}

# The following subroutine makes the same select list as
# the one that's created by accessing the database
#sub options_format {
#	return (
#        1 => 'Paperback',
#        2 => 'Hardcover',
#		 3 => 'Comic',
#	);
#}


sub validate_book_year {
	my ( $self, $field ) = @_;
	$field->add_error('Invalid year')
	     if (($field->value > 3000) || ($field->value < 1600));
};


=head1 AUTHOR

Gerda Shank

=head1 LICENSE AND COPYRIGHT

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut

1;
