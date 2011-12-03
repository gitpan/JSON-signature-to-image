use lib '.';

$^W = 1;

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..3\n"; }
END {print "not ok 1\n" unless $loaded;}
use GD;
use JSON::Parse;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.
# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

require("./signature-to-image.pl") ?
		print "ok 2\n" : print "not ok 2\n";

my ($img, $err) = &sig2png('[{"lx":93,"ly":27,"mx":93,"my":26},{"lx":95,"ly":26,"mx":93,"my":27},{"lx":101,"ly":24,"mx":95,"my":26},{"lx":102,"ly":24,"mx":101,"my":24}]', multiplier => 2);

($err =~ /success/ && length($img) > 100 && length($img) < 200) ? 
		print "ok 3\n" : print "not ok 3 ($err)\n";

print "..done: 3 tests completed.\n";

__END__
