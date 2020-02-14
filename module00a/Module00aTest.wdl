version 1.0

import "https://raw.githubusercontent.com/broadinstitute/gatk-sv-clinical/v0.5-clinical-improvements/module00a/Module00a.wdl" as module
import "https://raw.githubusercontent.com/broadinstitute/gatk-sv-clinical/v0.5-clinical-improvements/module00a/Module00aMetrics.wdl" as metrics
import "https://raw.githubusercontent.com/broadinstitute/gatk-sv-clinical/v0.5-clinical-improvements/module00a/TestUtils.wdl" as utils

workflow Module00aTest {
  input {
    String test_name
    Array[String] samples
    String base_metrics
  }

  call module.Module00a {
    input:
      samples = samples
  }

  call metrics.Module00aMetrics {
    input:
      name = test_name,
      samples = samples,
      coverage_counts = select_first([Module00a.coverage_counts]),
      BAF_out = select_first([Module00a.BAF_out]),
      pesr_disc = select_first([Module00a.pesr_disc]),
      pesr_split = select_first([Module00a.pesr_split]),
      manta_vcf = select_first([Module00a.manta_vcf]),
      melt_vcf = select_first([Module00a.melt_vcf]),
      wham_vcf = select_first([Module00a.wham_vcf])
  }

  call utils.PlotMetrics {
    input:
      name = test_name,
      samples = samples,
      test_metrics = Module00aMetrics.metrics_file,
      base_metrics = base_metrics
  }

  output {
    File metrics = Module00aMetrics.metrics_file
    File metrics_plot_pdf = PlotMetrics.metrics_plot_pdf
    File metrics_plot_tsv = PlotMetrics.metrics_plot_tsv
  }
}
