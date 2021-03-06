use Test::More;
use Test::MockModule;
use File::Temp qw/tempdir/;
use Model::StudyDesign;

sub test_preserve_format {
   my ($tsv, $test_name) = @_;
   $test_name //= do {
      my ($header, @lines) = split "\n", $tsv;
      sprintf("%s + %s lines", $header , 0+@lines);
   };
   my $subject = Model::StudyDesign::from_tsv(\$tsv);
   my $tmp = "";
   $subject->to_tsv(\$tmp);
   is($tmp, $tsv, $test_name) or diag explain $subject;
}

test_preserve_format("Run\tCondition\n");
test_preserve_format("Run\tCondition\torganism part\n");
test_preserve_format("Run\tCondition\torganism part\nSRR3209257\thead\thead\n");
my $tsv = <<EOF;
Run	Condition	organism	developmental stage	sex	organism part
SRR3209257	head	Schistosoma mansoni	adult	female	head
SRR3209258	head	Schistosoma mansoni	adult	female	head
SRR3209259	head	Schistosoma mansoni	adult	female	head
SRR3209260	tail	Schistosoma mansoni	adult	female	tail
SRR3209261	tail	Schistosoma mansoni	adult	female	tail
SRR3209262	tail	Schistosoma mansoni	adult	female	tail
EOF
test_preserve_format($tsv);
(my $tsv_no_factors = $tsv) =~ s/head/tail/g;
test_preserve_format($tsv_no_factors, "same as before, head -> tail ie no factors at all");
(my $tsv_extra_condition = $tsv) =~ s/head/2_head/;
test_preserve_format($tsv_extra_condition, "same, pointless extra condition");
my $tsv_incoherent_per_run = $tsv;
$tsv_ =~ s/head\tSchistosoma mansoni/head\tother wormie/;
test_preserve_format($tsv_incoherent_per_run, "data not assembling by condition");
done_testing;
