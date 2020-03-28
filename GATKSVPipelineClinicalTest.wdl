version 1.0

import "https://raw.githubusercontent.com/broadinstitute/gatk-sv-clinical/v0.6.1/GATKSVPipelineClinical.wdl" as module
import "https://raw.githubusercontent.com/broadinstitute/gatk-sv-clinical/v0.6.1/TestUtils.wdl" as utils

workflow GATKSVPipelineClinicalTest {
  input {
    String test_name
    String case_sample
    Array[String] ref_samples
    String base_metrics
  }

  call module.GATKSVPipelineClinical {
    input:
      sample_id = case_sample,
      ref_samples = ref_samples
  }

  Array[String] samples = flatten([[case_sample], ref_samples])

  call utils.PlotMetrics {
    input:
      name = test_name,
      samples = samples,
      test_metrics = GATKSVPipelineClinical.metrics_file,
      base_metrics = base_metrics
  }

  output {
    File metrics = GATKSVPipelineClinical.metrics_file
    File metrics_plot_pdf = PlotMetrics.metrics_plot_pdf
    File metrics_plot_tsv = PlotMetrics.metrics_plot_tsv
  }
}
