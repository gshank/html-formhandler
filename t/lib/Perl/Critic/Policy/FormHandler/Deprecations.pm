package Perl::Critic::Policy::FormHandler::Deprecations;

our $VERSION = '0.001';

use warnings;
use strict;
use Carp;

use Perl::Critic::Utils qw( :severities :classification first_arg parse_arg_list split_nodes_on_comma );

use base 'Perl::Critic::Policy';

sub supported_parameters { return ();                       }
sub default_severity     { return $SEVERITY_HIGH;           }
sub default_themes       { return qw( bugs formhandler);   }
sub applies_to           { return 'PPI::Token::Word'           }

sub violates {
    my ($self, $elem ) = @_;

    if( is_method_call( $elem ) && $elem->literal eq 'has_error' ){
        return $self->violation('The "has_error" method used.',
            'The "has_error" method is deprecated.',
            $elem
        );
    }
    return if ! is_function_call($elem);
    if( $elem eq 'has' ){
        my $farg = first_arg( $elem );
        return if ! $farg->can( 'string' );
        $farg = $farg->string;
        if( $farg eq '+min_length' ){
            return $self->violation('The "min_length" attribute used.',
                'The "min_length" attribute is deprecated - use minlength instead.',
                $elem);
        }
    }
    elsif( $elem eq 'has_field' ){
        my @args = parse_arg_list( $elem );
        return if ref $args[1][0] ne 'PPI::Structure::List';
        for my $e( $args[1][0]->children ){
            next if ref $e ne 'PPI::Statement::Expression';
            my $i = 0;
            for my $attr ( split_nodes_on_comma( $e->children ) ){
                next if $i++ % 2;
                next if ref $attr ne 'ARRAY';
                for my $a( @$attr ){
                    next if ref $a ne 'PPI::Token::Word';
                    next if $a->literal ne 'min_length';
                    return $self->violation('The "min_length" attribute used.', 
                        'The "min_length" attribute is deprecated - use minlength instead.', 
                        $elem);
                }
            }
        }
    }
    return;
} 

1; # Magic true value required at end of module
__END__

=head1 NAME

Perl::Critic::Policy::FormHandler::Deprecations - Checks if deprecated parts of the HTML::FormHandlers API are used


=head1 VERSION

This document describes Perl::Critic::Policy::FormHandler::Deprecations version 0.0.1


=head1 SYNOPSIS

    perlcritic --theme formhandler lib   # assuming Perl::Critic::Policy::FormHandler::Deprecations is in the path

=head1 DESCRIPTION

This is a L<Perl::Critic> policy for code using HTML::FormHandler - it detects constructs deprecated in latest
HTML::FormHandler version.


=head1 INTERFACE 

=head1 DIAGNOSTICS

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.
  
Perl::Critic::Policy::FormHandler::Deprecations requires no configuration files or environment variables.


=head1 DEPENDENCIES

L<Perl::Critic>

=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-perl-critic-policy-formhandler-deprecations@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Zbigniew Lukasiak  C<< <<zby @ cpan.org >> >>
based on idea from L<http://blog.robin.smidsrod.no/index.php/2009/07/03/deprecated-code-analyzer-for-perl>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009, Zbigniew Lukasiak C<< << zbigniew @ lukasiak.name >> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
