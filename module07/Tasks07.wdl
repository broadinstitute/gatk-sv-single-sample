version 1.0

import "Structs.wdl"

# Task to concatenate given VCF array into a single indexed vcf.gz

task ConcatVcfs {

  input {
    
    Array[File] vcfs
    String      prefix
    String      sv_mini_docker

    RuntimeAttr? runtime_attr_override
  }
  
  output {
    File concat_vcf     = "${prefix}.vcf.gz"
    File concat_vcf_idx = "${prefix}.vcf.gz.tbi"
  }

  command <<<

    set -euo pipefail
    
    vcf-concat ~{sep=" "  vcfs} \
      | vcf-sort -c \
      | bgzip -c \
      > ~{prefix}.vcf.gz;

    tabix -p vcf -f "~{prefix}.vcf.gz"
  
  >>>

  #########################
  RuntimeAttr default_attr = object {
    cpu_cores:          1, 
    mem_gb:             16, 
    disk_gb:            250,
    boot_disk_gb:       10,
    preemptible_tries:  3,
    max_retries:        0
  }
  RuntimeAttr runtime_attr = select_first([runtime_attr_override, default_attr])
  runtime {
    cpu:                    select_first([runtime_attr.cpu_cores,         default_attr.cpu_cores])
    memory:                 select_first([runtime_attr.mem_gb,            default_attr.mem_gb]) + " GiB"
    disks: "local-disk " +  select_first([runtime_attr.disk_gb,           default_attr.disk_gb]) + " HDD"
    bootDiskSizeGb:         select_first([runtime_attr.boot_disk_gb,      default_attr.boot_disk_gb])
    preemptible:            select_first([runtime_attr.preemptible_tries, default_attr.preemptible_tries])
    maxRetries:             select_first([runtime_attr.max_retries,       default_attr.max_retries])
    docker:                 sv_mini_docker
  }
}