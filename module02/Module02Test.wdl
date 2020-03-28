version 1.0

import "https://raw.githubusercontent.com/broadinstitute/gatk-sv-clinical/v0.6.1/module02/Module02.wdl" as module
import "https://raw.githubusercontent.com/broadinstitute/gatk-sv-clinical/v0.6.1/module02/Module02Metrics.wdl" as metrics
import "https://raw.githubusercontent.com/broadinstitute/gatk-sv-clinical/v0.6.1/module02/TestUtils.wdl" as utils

workflow Module02Test {
  input {
    String test_name
    Array[String] samples
    String base_metrics
  }

  call module.Module02 {
    input:
      samples = samples
  }

  call metrics.Module02Metrics {
    input:
      name = test_name,
      metrics = Module02.metrics
  }

  call utils.PlotMetrics {
    input:
      name = test_name,
      samples = samples,
      test_metrics = Module02Metrics.metrics_file,
      base_metrics = base_metrics
  }

  output {
    File metrics = Module02Metrics.metrics_file
    File metrics_plot_pdf = PlotMetrics.metrics_plot_pdf
    File metrics_plot_tsv = PlotMetrics.metrics_plot_tsv
  }
}
