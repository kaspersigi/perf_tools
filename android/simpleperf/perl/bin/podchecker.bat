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
#!perl
#line 30
    eval 'exec perl -S $0 "$@"'
        if 0;
#############################################################################
# podchecker -- command to invoke the podchecker function in Pod::Checker
#
# Copyright (c) 1998-2000 by Bradford Appleton. All rights reserved.
# This is free software; you can redistribute it and/or modify it under the
# same terms as Perl itself.
#############################################################################

use strict;
#use diagnostics;

=head1 NAME

podchecker - check the syntax of POD format documentation files

=head1 SYNOPSIS

B<podchecker> [B<-help>] [B<-man>] [B<-(no)warnings>] [I<file>S< >...]

=head1 OPTIONS AND ARGUMENTS

=over 8

=item B<-help>

Print a brief help message and exit.

=item B<-man>

Print the manual page and exit.

=item B<-quiet>

Do not print a success message.

=item B<-warnings> B<-nowarnings>

Turn on/off printing of warnings. Repeating B<-warnings> increases the
warning level, i.e. more warnings are printed. Currently increasing to
level two causes flagging of unescaped "E<lt>,E<gt>" characters.

=item I<file>

The pathname of a POD file to syntax-check (defaults to standard input).

=back

=head1 DESCRIPTION

B<podchecker> will read the given input files looking for POD
syntax errors in the POD documentation and will print any errors
it find to STDERR. At the end, it will print a status message
indicating the number of errors found.

Directories are ignored, an appropriate warning message is printed.

B<podchecker> invokes the B<podchecker()> function exported by B<Pod::Checker>
Please see L<Pod::Checker/podchecker()> for more details.

=head1 RETURN VALUE

B<podchecker> returns a 0 (zero) exit status if all specified
POD files are ok.

=head1 ERRORS

B<podchecker> returns the exit status 1 if at least one of
the given POD files has syntax errors.

The status 2 indicates that at least one of the specified 
files does not contain I<any> POD commands.

Status 1 overrides status 2. If you want unambiguous
results, call B<podchecker> with one single argument only.

=head1 SEE ALSO

L<Pod::Simple> and L<Pod::Checker>

=head1 AUTHORS

Please report bugs using L<http://rt.cpan.org>.

Brad Appleton E<lt>bradapp@enteract.comE<gt>,
Marek Rouchal E<lt>marekr@cpan.orgE<gt>

Based on code for B<Pod::Text::pod2text(1)> written by
Tom Christiansen E<lt>tchrist@mox.perl.comE<gt>

=cut


use Pod::Checker;
use Pod::Usage;
use Getopt::Long;

## Define options
my %options;

## Parse options
GetOptions(\%options, qw(help man quiet warnings+ nowarnings))  ||  pod2usage(2);
pod2usage(1)  if ($options{help});
pod2usage(-verbose => 2)  if ($options{man});

if($options{nowarnings}) {
  $options{warnings} = 0;
}
elsif(!defined $options{warnings}) {
  $options{warnings} = 1; # default is warnings on
}

## Dont default to STDIN if connected to a terminal
pod2usage(2) if ((@ARGV == 0) && (-t STDIN));

## Invoke podchecker()
my $status = 0;
@ARGV = qw(-) unless(@ARGV);
for my $podfile (@ARGV) {
    if($podfile eq '-') {
      $podfile = '<&STDIN';
    }
    elsif(-d $podfile) {
      warn "podchecker: Warning: Ignoring directory '$podfile'\n";
      next;
    }
    my $errors =
      podchecker($podfile, undef, '-warnings' => $options{warnings});
    if($errors > 0) {
        # errors occurred
        $status = 1;
        printf STDERR ("%s has %d pod syntax %s.\n",
          $podfile, $errors,
          ($errors == 1) ? 'error' : 'errors');
    }
    elsif($errors < 0) {
        # no pod found
        $status = 2 unless($status);
        print STDERR "$podfile does not contain any pod commands.\n";
    }
    else {
        print "$podfile pod syntax OK.\n" unless $options{quiet};
    }
}
exit $status;

__END__
:endofperl
@set "ErrorLevel=" & @goto _undefined_label_ 2>NUL || @"%COMSPEC%" /d/c @exit %ErrorLevel%
