
package PublicResources::Resources::Factors;
use List::Util qw(sum all);
use List::MoreUtils qw(uniq);
use parent PublicResources::Resources::LocallyCachedResource;

# Factors for species are a union across studies of:
# - either what ArrayExpress says the factor types are for the study
# - or RNASeq-er characteristic types that vary across runs for the study
# Compare in ArrayExpress: a factor is an "important" sample characteristic

my @blacklist = (
 "synonym",
 "bioproject_id",
  "species",
  "organism",
  "replicate",
  "sample_name",
  "batch",
  "barcode",
  "insdc_center_name",
  "insdc_first_public",
  "insdc_secondary_accession",
  "insdc_status",
  "insdc_last_update",
  "label",
  "model",
  "package",
  "ncbi_submission_model",
  "ncbi_submission_package",
  "sample_comment",
  "sample_title",
  "geo_accession",
  "biological_replicate",
  "block",
  "zone", #schmidtea mediterranea
  "repplicate",
  "in_house_sample_code",
  "collected_by",
  "biomaterial_provider",
  "description_title",
  "treatment_sources",
  "population",
  "sample_name",
  "agarosemigrationtemperature",
  "agarosemigrationttime",
  "baermanntemperature",
  "base_calling_software_version",
  "culturetemperature",
  "culturetime",
  "library_id",
  "library_preparation",
  "wash",
);
sub not_in_blacklist {
  my $arg = shift;
  for (@blacklist){
     return if $arg eq $_;
  }
  return 1;
}
sub _fetch {
  my ( $class, $species, $rnaseqer_metadata, $array_express_metadata ) = @_;
  my %data;
  for my $assembly ( @{ $rnaseqer_metadata->access } ) {
    for my $study_id ( @{ $rnaseqer_metadata->access($assembly) } ) {
      my %rnaseqer_characteristics;
      my @runs = @{ $rnaseqer_metadata->access( $assembly, $study_id ) };
      for my $run (@runs) {
        for my $characteristic_type (
          @{ $rnaseqer_metadata->access( $assembly, $study_id, $run ) } )
        {
          $rnaseqer_characteristics{$characteristic_type}{
            $rnaseqer_metadata->access( $assembly, $study_id, $run,
              $characteristic_type )
          }++;
        }
      }
      my @factors;
      my @ae_factors =
        @{ $array_express_metadata->factor_types($study_id) // [] };
      if (@ae_factors and all { exists $rnaseqer_characteristics{$_} } @ae_factors) {
        @factors = @ae_factors;
      }
      else {
        for ( keys %rnaseqer_characteristics ) {
          my %d      = %{ $rnaseqer_characteristics{$_} };
          my @values = keys %d;
          my @counts = values %d;
          push @factors, $_ if @values > 1 or sum(@counts) == 1;
        }
      }
      $data{$study_id} = \@factors;
    }
  }
  my @result = map { @{$_} } ( values %data );
  @result = grep { not_in_blacklist($_) } @result;
  @result = uniq @result;
  @result = sort @result;
  return \@result;
}


1;
