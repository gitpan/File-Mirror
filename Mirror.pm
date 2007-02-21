package File::Mirror;
use base qw(Exporter);
use strict;
use warnings;
use File::Copy;
use File::Find;
use File::Spec;

our @EXPORT = qw(
                    mirror
                    recursive
               );

our $VERSION = '0.03';
our $from;
our $to;

sub recursive(&@) {
    my ($code, $src, $dst) = @_;
    my ($vol, $dir, $file) = File::Spec->splitpath($src);
    my @src = File::Spec->splitdir($dir);
    pop @src unless defined $src[$#src] and $src[$#src] ne '';
    my $src_level = @src;
    find({ wanted => sub {
               my @src = File::Spec->splitdir($File::Find::name);
               my $tgt = File::Spec->catfile($dst, @src[$src_level..$#src]);
               local ($from, $to) = ($File::Find::name, $tgt);
               $code->();
           },
           no_chdir => 1,
         },
         $src,
        );
}

sub mirror {
    recursive { -d $from ? do { mkdir($to) unless -d $to } : copy($from, $to) } @_;
}

1;
__END__

=head1 NAME

File::Mirror - Perl extension for recursive directory copy

=head1 SYNOPSIS

  use File::Mirror;

  # recurvie copy /path/A to /path/B

  mirror '/path/A', '/path/B';

  # or do things you like

  recursive { copy($File::Mirror::a, $File::Mirror::b) } '/path/A', '/path/B';

=head1 DESCRIPTION

C<File::Mirror> provides two helper functions to do recursive
directory operations between source path and destination path. One is
to call C<mirror> which will do recursive copy. The other is to call
C<recursive> with a code block, which will be code for every file
found in the source path.

C<File::Mirror> fills the gap between C<File::Copy::Recursive>, which
only focuses on file copying, and C<File::Find>, which is too obstacal
to use.

=head2 EXPORT

B<mirror>

  mirror $src, $dst

Recursive copy files from $src to $dst. Create new directory is
necessary. Symbol links will not be followed.

B<recursive>

  recursive {...} $src, $dst

Code block will be code with each file and sub-directories found in
$src. Inside the code block, C<$File::Mirror::from> will be set to source
file name, C<$File::Mirror::to> will be set to destination file name.

User need to distinguish directories, file, symbol links, and devices
from C<$File::Mirror::from>.

=head1 AUTHOR

Jianyuan Wu, E<lt>jwu@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2007 by Jianyuan Wu

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
