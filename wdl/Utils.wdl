version 1.0

import "Structs.wdl"

task StringArrayToListFile {
  input {
    Array[String] strings
    String sv_base_mini_docker
    RuntimeAttr? runtime_attr_override
  }

  RuntimeAttr default_attr = object {
    cpu_cores: 1,
    mem_gb: 3.75,
    disk_gb: 10,
    boot_disk_gb: 10,
    preemptible_tries: 3,
    max_retries: 1
  }
  RuntimeAttr runtime_attr = select_first([runtime_attr_override, default_attr])

  output {
    File list_file = "list_file.list"
  }

  command <<<
    set -euo pipefail
    cat ~{write_lines(strings)} > list_file.list
  >>>

  runtime {
    cpu: select_first([runtime_attr.cpu_cores, default_attr.cpu_cores])
    memory: select_first([runtime_attr.mem_gb, default_attr.mem_gb]) + " GiB"
    disks: "local-disk " + select_first([runtime_attr.disk_gb, default_attr.disk_gb]) + " HDD"
    bootDiskSizeGb: select_first([runtime_attr.boot_disk_gb, default_attr.boot_disk_gb])
    docker: sv_base_mini_docker
    preemptible: select_first([runtime_attr.preemptible_tries, default_attr.preemptible_tries])
    maxRetries: select_first([runtime_attr.max_retries, default_attr.max_retries])
  }
}


task RunQC {
  input {
    String name
    File metrics
    File qc_definitions
    String sv_pipeline_base_docker
    Float mem_gib = 1
    Int disk_gb = 10
    Int preemptible_attempts = 3
  }

  output {
    File out = "sv_qc.~{name}.tsv"
  }
  command <<<

    set -eu
    svqc ~{metrics} ~{qc_definitions} raw_qc.tsv
    grep -vw "NA" raw_qc.tsv > sv_qc.~{name}.tsv

  >>>
  runtime {
    cpu: 1
    memory: "~{mem_gib} GiB"
    disks: "local-disk ~{disk_gb} HDD"
    bootDiskSizeGb: 10
    docker: sv_pipeline_base_docker
    preemptible: preemptible_attempts
    maxRetries: 1
  }

}
