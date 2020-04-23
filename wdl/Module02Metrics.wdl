version 1.0

import "TestUtils.wdl" as tu

workflow Module02Metrics {
  input {
    String name
    File metrics
    File contig_list
    String sv_pipeline_base_docker
  }

  call tu.MetricsFileMetrics {
    input:
      metrics_file = metrics,
      contig_list = contig_list,
      prefix = "module02." + name,
      sv_pipeline_base_docker = sv_pipeline_base_docker
  }

  output {
    File metrics_file = MetricsFileMetrics.out
  }
}
