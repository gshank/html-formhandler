package BookDB::Form::BookCDBI;

use strict;
use warnings;
use base 'HTML::FormHandler::Model::CDBI';

#==============================================================================

=head1 NAME

Form object for the Book Controller

=head1 SYNOPSIS

/book/add

=head1 DESCRIPTION

Catalyst Form.

Revision: $Id: BookCDBI.pm,v 1.1 2008/11/13 21:48:29 gshank Exp $

=head1 METHODS

=cut

#==============================================================================

has '+item_class' => ( default => 'BookDB::Model::DB::Book' );

# To loop through fields in order
sub field_list {
	my @fields = ('title', 'author', 'genre', 'publisher', 'isbn', 'format', 'pages', 'year');
	
    return wantarray ? @fields : \@fields;
}

sub profile {
	my $self = shift;

	return {
		required => {
			title        => 'Text',
			author       => 'Text',
		},
		optional => {
			genre        => 'Select',
			isbn         => 'Text',
			publisher    => 'Text',
			format       => 'Select',
			year         => 'Integer',
			pages        => 'Integer',
		},
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


sub validate_year {
	my ( $self, $field ) = @_;
	$field->add_error('Invalid year')
	     if (($field->value > 3000) || ($field->value < 1600));
};


=head1 AUTHOR

Gerda Shank

Created 01/10/2008 04:07:43 PM EST 

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2007 arxiv.org <www-admin@arXiv.org>

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut

1;
