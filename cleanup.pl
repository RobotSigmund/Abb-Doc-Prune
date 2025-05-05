#!C:/Strawberry/perl/bin

use File::Path;
use strict;

$| = 1;



our $COUNT_DELETED = 0;
our $COUNT_FAILED = 0;

# Deleting unneccesary files
process_dir('.');
print 'Deleted: ' . $COUNT_DELETED . ' Failed: ' . $COUNT_FAILED . "\n";

# Patch html file
patch_index();



# Wait and close
sleep(5);
exit;



sub process_dir{
	my($dir) = @_;

	# Loop through folder
	opendir(my $DH, $dir);
	foreach my $de (readdir($DH)) {
		# Ignore ./..
		next if ($de =~ /^\.{1,2}$/);
		
		# Folder?
		if (-d $dir . '/' . $de) {
			
			# English and swedish, we keep these
			if ($de =~ /^(en|sv)$/) {
				# Nop, we keep these
				
			} elsif ($de eq '_htmlresources') {
				# Nop, keep these also
				
			} elsif ($de =~ /^(cz|da|de|es|fi|fr|hu|it|ja|ko|nl|pl|pt|ru|sl|sv|tr|zh)$/) {
				# This is not relevant, so we delete it
				print '  Deleting [' . $dir . '/' . $de . ']...';
				rmtree($dir . '/' . $de);
				if (-e $dir . '/' . $de) {
					print 'failed';
					$COUNT_FAILED++;
				} else {
					print 'ok';
					$COUNT_DELETED++;
				}
				print "\n";
				
			} elsif (length($de) == 2) {
				# Mostly for debugging, Abb might introduce new language files
				print '  Maybe this should be removed: [' . $dir . '/' . $de . "\n";
				
			} else {
				# Any other folder will be called recursively, so that everything is checked
				process_dir($dir . '/' . $de);
				
			}
		}
	}
	closedir($DH);
}



sub patch_index {
	my $FILE;
	unless (open($FILE, '<index.html')) {
		print 'Error, Did not find index.html' . "\n";
		return;
	}
	read($FILE, my $file_content, (-s $FILE));
	close($FILE);

	# Try to remove irrelevant links
	# <li class="list-group-item"><a target="_blank" class="icon_abb_16 icon-abb_right-arrow_16 release-link" href="Safety information/Safety information/ja/3HAC027098-001.pdf">ユーザーマニュアル- 非常時における安全確認について</a></li>
	$file_content =~ s/<li class="[^<>"]*?"><a[^<>]*?href="[^<>"]*?\W(cz|da|de|es|fi|fr|hu|it|ja|ko|nl|pl|pt|ru|sl|sv|tr|zh)\W[^<>"]*?".*?><\/li>//g;

	# Try to remove irrelevant language sections
	# <div class="language"><a class="lang-link" data-toggle="collapse" aria-expanded="false" aria-controls="Gettingstarted-de" href="#Gettingstarted-de">deutsch</a></div>
	$file_content =~ s/<div class="language"><a[^<>]*>(deutsch|français|italiano|español|portugués|dansk|nederlands|中文|hangug-eo|日本語|suomalainen|čeština|polski|русский|türk|slovenščina|magyar|svenska)<\/a><\/div>//g;

	# Write remaining info back to file
	open(my $FILE, '>index_patched.html');
	print $FILE $file_content;
	close($FILE);
}
