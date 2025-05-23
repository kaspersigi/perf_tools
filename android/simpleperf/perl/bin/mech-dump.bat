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
#!/usr/bin/perl
#line 30

# PODNAME: mech-dump
# ABSTRACT: Dumps information about a web page

use warnings;
use strict;
use WWW::Mechanize ();
use Getopt::Long;
use Pod::Usage;

use HTTP::Cookies;
my @actions;
my $absolute;
my $all;

my $user;
my $pass;
my $agent;
my $agent_alias;
my $cookie_filename;

GetOptions(
    'user=s'     => \$user,
    'password=s' => \$pass,
    headers      => sub { push( @actions, \&dump_headers ) },
    forms        => sub { push( @actions, \&dump_forms ) },
    links        => sub { push( @actions, \&dump_links ) },
    images       => sub { push( @actions, \&dump_images ) },
    all          => sub {
        $all++;
        push(
            @actions, \&dump_headers, \&dump_forms, \&dump_links,
            \&dump_images
        );
    },
    text            => sub { push( @actions, \&dump_text ) },
    absolute        => \$absolute,
    'agent=s'       => \$agent,
    'agent-alias=s' => \$agent_alias,
    'cookie-file=s' => \$cookie_filename,
    help            => sub { pod2usage(1); },
    version => sub { print STDERR $WWW::Mechanize::VERSION, "\n"; exit 0; },
) or pod2usage(2);


my @uris = @ARGV
    or die "Must specify a URL or file to check.  See --help for details.\n";

@actions = ( \&dump_forms ) unless @actions;

binmode( STDOUT, ':utf8' );

my $mech = WWW::Mechanize->new( autocheck => 0 );
if ( defined $agent ) {
    $mech->agent($agent);
}
elsif ( defined $agent_alias ) {
    $mech->agent_alias($agent_alias);
}
if ( defined $cookie_filename ) {
    my $cookies = HTTP::Cookies->new(
        file           => $cookie_filename, autosave => 1,
        ignore_discard => 1
    );
    $cookies->load();
    $mech->cookie_jar($cookies);
}
else {
    $mech->cookie_jar(undef);
}

$mech->env_proxy();
foreach my $uri (@uris) {
    my $no_ct_check;
    if ( -e $uri ) {
        require URI::file;
        $uri         = URI::file->new_abs($uri)->as_string;
        $no_ct_check = 1;    # we don't have to check the content type
    }

    my $response = $mech->get($uri);
    if ( !$response->is_success ) {
        if ( defined( $response->www_authenticate ) ) {
            if ( !defined $user or !defined $pass ) {
                die(
                    "Page requires username and password, but none specified.\n"
                );
            }
            $mech->credentials( $user, $pass );
            $response = $mech->get($uri);
            $response->is_success
                or die "Can't fetch $uri with username and password\n",
                $response->status_line, "\n";
        }
        else {
            die "$uri returns status ", $response->code, "\n";
        }
    }

    unless ($no_ct_check) {
        $mech->is_html
            or die qq{$uri returns type "}, $mech->ct,
            qq{", not "text/html"\n};
    }

    foreach my $action (@actions) {
        $action->($mech);
        print "\n" if @actions;
    }
}

sub dump_headers {
    my $mech = shift;
    print "--> Headers:\n" if $all;
    $mech->dump_headers(undef);
    return;
}

sub dump_forms {
    my $mech = shift;
    print "--> Forms:\n" if $all;
    $mech->dump_forms(undef);
    return;
}

sub dump_links {
    my $mech = shift;
    print "--> Links:\n" if $all;
    $mech->dump_links( undef, $absolute );
    return;
}

sub dump_images {
    my $mech = shift;
    print "--> Images:\n" if $all;
    $mech->dump_images( undef, $absolute );
    return;
}

sub dump_text {
    my $mech = shift;
    $mech->dump_text();
    return;
}

__END__

=pod

=encoding UTF-8

=head1 NAME

mech-dump - Dumps information about a web page

=head1 VERSION

version 2.18

=head1 SYNOPSIS

mech-dump [options] [file|url]

Options:

    --headers              Dump HTTP response headers
    --forms                Dump table of forms (default action)
    --links                Dump table of links
    --images               Dump table of images
    --all                  Dump all four of the above, in that order

    --text                 Dumps the textual part of the web page

    --user=user            Set the username
    --password=pass        Set the password
    --cookie-file=filename Set the filename to use for persistent cookies

    --agent=agent          Specify the UserAgent to pass
    --agent-alias=alias
                           Specify the alias for the UserAgent to pass.
                           Pick one of:
                               * Windows IE 6
                               * Windows Mozilla
                               * Mac Safari
                               * Mac Mozilla
                               * Linux Mozilla
                               * Linux Konqueror

    --absolute             Show URLs as absolute, even if relative in the page
    --help                 Show this message

The order of the options specified is relevant.  Repeated options
get repeated dumps.

C<mech-dump> will only work on HTML documents when used on remote URLs, but
will assume any local file you pass it is HTML. If it is not, there won't be
any usable results.

Proxy settings are specified through the environment (e.g. C<http_proxy=http://proxy.my.place/>).
See L<LWP::UserAgent> for details.

=head1 SEE ALSO

L<WWW::Mechanize>

=head1 AUTHOR

Andy Lester <andy at petdance.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2004 by Andy Lester.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
__END__
:endofperl
@set "ErrorLevel=" & @goto _undefined_label_ 2>NUL || @"%COMSPEC%" /d/c @exit %ErrorLevel%
