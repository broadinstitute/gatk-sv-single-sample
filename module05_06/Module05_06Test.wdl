version 1.0

import "https://raw.githubusercontent.com/broadinstitute/gatk-sv-clinical/v0.4-dockstore_release2/module05_06/Module05_06.wdl" as module
import "https://raw.githubusercontent.com/broadinstitute/gatk-sv-clinical/v0.4-dockstore_release2/module05_06/Module05_06Metrics.wdl" as metrics
import "https://raw.githubusercontent.com/broadinstitute/gatk-sv-clinical/v0.4-dockstore_release2/module05_06/TestUtils.wdl" as utils

workflow Module05_06Test {
  input {
    String test_name
    Array[String] samples
    String base_metrics
  }

  call module.Module05_06 {
    input:
      samples = samples
  }

  call metrics.Module05_06Metrics {
    input:
      name = test_name,
      samples = samples,
      final_vcf = Module05_06.final_04b_vcf,
      cleaned_vcf = Module05_06.cleaned_vcf
  }

  call utils.PlotMetrics {
    input:
      name = test_name,
      samples = samples,
      test_metrics = Module05_06Metrics.metrics_file,
      base_metrics = base_metrics
  }

  output {
    File metrics = Module05_06Metrics.metrics_file
    File metrics_plot_pdf = PlotMetrics.metrics_plot_pdf
    File metrics_plot_tsv = PlotMetrics.metrics_plot_tsv
  }
}
