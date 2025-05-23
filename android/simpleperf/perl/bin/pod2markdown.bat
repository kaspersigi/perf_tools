@rem = '--*-Perl-*--
@set "ErrorLevel="
@if "%OS%" == "Windows_NT" @goto WinNT
@perl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
@set ErrorLevel=%ErrorLevel%
@goto endofperl
:WinNT
@perl -x -S %0 %*
@set ErrorLevel=%ErrorLevel%
@if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" @goto endofperl
@if %ErrorLevel% == 9009 @echo You do not have Perl in your PATH.
@goto endofperl
@rem ';
#!/usr/local/bin/perl
#line 30
#
# This file is part of Pod-Markdown
#
# This software is copyright (c) 2011 by Randy Stauner.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
use 5.008;
use strict;
use warnings;
# PODNAME: pod2markdown
# ABSTRACT: Convert POD text to Markdown

use Pod::Markdown;
use Getopt::Long;
use Pod::Usage;

my %opts = (
  # Since we're writing to a file the module needs to know that it has to do
  # some kind of encoding.  Default to UTF-8.
  output_encoding => 'UTF-8',
);

GetOptions(\%opts, qw(
  help|h
  html_encode_chars|html-encode-chars=s
  local_module_url_prefix|local-module-url-prefix=s
  match_encoding|match-encoding|m
  man_url_prefix|man-url-prefix=s
  perldoc_url_prefix|perldoc-url-prefix=s
  output_encoding|output-encoding|e=s
  utf8|utf-8|u
)) or pod2usage(2);
pod2usage(1) if $opts{help};

# TODO: Test PERL_UNICODE and/or layers on the handle?

# Expand alias (-u is an alias for -e UTF-8).
$opts{output_encoding} = 'UTF-8' if delete $opts{utf8};

# TODO: Pod::Simple::parse_from_file(@ARGV[0,1]);

my $in_fh  = get_handle(shift(@ARGV), '<', \*STDIN);
my $out_fh = get_handle(shift(@ARGV), '>', \*STDOUT);

# Undo any PERL_UNICODE effects.
# Pod::Simple expects to receive bytes, and we're going to return bytes.
binmode($_, ':bytes') for ($in_fh, $out_fh);

convert($in_fh, $out_fh);

sub convert {
    my ($in_file, $out_file) = @_;
    my $parser = Pod::Markdown->new(%opts);
    $parser->output_fh($out_file);
    $parser->parse_file($in_file);
}

sub get_handle {
  my ($path, $op, $default) = @_;
  (!defined($path) || $path eq '-') ? $default : do {
    open(my $fh, $op, $path)
      or die "Failed to open '$path': $!\n";
    $fh;
  };
}

__END__

=pod

=encoding UTF-8

=for :stopwords Marcel Gruenauer Victor Moral Ryan C. Thompson <rct at thompsonclan d0t
org> Aristotle Pagaltzis Randy Stauner ACKNOWLEDGEMENTS html

=head1 NAME

pod2markdown - Convert POD text to Markdown

=head1 VERSION

version 3.400

=head1 SYNOPSIS

    # parse STDIN, print to STDOUT
    $ pod2markdown < POD_File > Markdown_File

    # parse file, print to STDOUT
    $ pod2markdown input.pod

    # parse file, print to file
    $ pod2markdown input.pod output.mkdn

    # parse STDIN, print to file
    $ pod2markdown - output.mkdn

=head1 DESCRIPTION

This program uses L<Pod::Markdown> to convert POD into Markdown sources.

UTF-8 is the default output encoding
if no encoding options are specified (see L</OPTIONS>).

It accepts two optional arguments:

=over 4

=item *

input pod file (defaults to C<STDIN>)

=item *

output markdown file (defaults to C<STDOUT>)

=back

=head1 OPTIONS

=over

=item --html-encode-chars

A list of characters to encode as HTML entities.
Pass a regexp character class, or C<1> to mean control chars, high-bit chars, and C<< <&>"' >>.

See L<Pod::Markdown/html_encode_chars> for more information.

=item --match-encoding (-m)

Use the same C<< =encoding >> as the input pod for the output file.

=item --local-module-url-prefix

Alters the perldoc urls that are created from C<< LE<lt>E<gt> >> codes
when the module is a "local" module (C<"Local::*"> or C<"Foo_Corp::*"> (see L<perlmodlib>)).

The default is to use C<perldoc_url_prefix>.

See L<Pod::Markdown/local_module_url_prefix> for more information.

=item --man-url-prefix

Alters the man page urls that are created from C<< LE<lt>E<gt> >> codes.

The default is C<http://man.he.net/man>.

See L<Pod::Markdown/man_url_prefix> for more information.

=item --perldoc-url-prefix

Alters the perldoc urls that are created from C<< LE<lt>E<gt> >> codes.
Can be:

=over 4

=item *

C<metacpan> (shortcut for C<https://metacpan.org/pod/>)

=item *

C<sco> (shortcut for C<http://search.cpan.org/perldoc?>)

=item *

any url

=back

The default is C<metacpan>.

See L<Pod::Markdown/perldoc_url_prefix> for more information.

=item --output-encoding (-e)

Specify the encoding for the output file.

=item --utf8 (-u)

Alias for C<< -e UTF-8 >>.

=back

=head1 SEE ALSO

This program is strongly based on C<pod2mdwn> from L<Module::Build::IkiWiki>.

=head1 AUTHORS

=over 4

=item *

Marcel Gruenauer <marcel@cpan.org>

=item *

Victor Moral <victor@taquiones.net>

=item *

Ryan C. Thompson <rct at thompsonclan d0t org>

=item *

Aristotle Pagaltzis <pagaltzis@gmx.de>

=item *

Randy Stauner <rwstauner@cpan.org>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Randy Stauner.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
__END__
:endofperl
@set "ErrorLevel=" & @goto _undefined_label_ 2>NUL || @"%COMSPEC%" /d/c @exit %ErrorLevel%
