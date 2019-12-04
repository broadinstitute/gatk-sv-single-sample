##########################################################################################

## Base script:   https://portal.firecloud.org/#methods/Talkowski-SV/00_pesr_preprocessing_MMDLW/15/wdl

## Github commit: talkowski-lab/gatk-sv-v1:<ENTER HASH HERE IN FIRECLOUD>

##########################################################################################

version 1.0

import "https://raw.githubusercontent.com/broadinstitute/gatk-sv-clinical/v0.3-dockstore_release/module00c/Structs.wdl"
# Does perlim translocation resolve from raw manta calls
workflow TinyResolve {
  input {
    Array[String]+ samples         # Sample ID
    Array[File]+ manta_vcfs        # Manta VCF
    File cytoband
    File cytoband_idx
    Array[File]+ discfile
    Array[File]+ discfile_idx
    File mei_bed
    String sv_pipeline_docker
    RuntimeAttr? runtime_attr
  }

  call ResolveManta {
    input:
      raw_vcfs=manta_vcfs,
      samples=samples,
      sv_pipeline_docker = sv_pipeline_docker,
      cytoband=cytoband,
      cytoband_idx=cytoband_idx,
      discfile=discfile,
      discfile_idx=discfile_idx,
      mei_bed=mei_bed,
      runtime_attr_override=runtime_attr
  }

  output {
    Array[File]+ tloc_manta_vcf = ResolveManta.tloc_vcf
  }
}

task ResolveManta {
  input {
    Array[File]+ raw_vcfs
    Array[String]+ samples
    File cytoband_idx
    Array[File]+ discfile
    Array[File]+ discfile_idx
    File cytoband
    File mei_bed
    String sv_pipeline_docker
    RuntimeAttr? runtime_attr_override
  }

  Int num_samples = length(samples)
  Float input_size = size(discfile,"GiB")
  RuntimeAttr default_attr = object {
    cpu_cores: 1, 
    mem_gb: 3.75, 
    disk_gb: ceil(10+input_size),
    boot_disk_gb: 10,
    preemptible_tries: 3,
    max_retries: 3
  }
  RuntimeAttr runtime_attr = select_first([runtime_attr_override, default_attr])

  command <<<
    set -euo pipefail
    vcfs=(~{sep=" " raw_vcfs})
    sample_ids=(~{sep=" " samples})
    discfiles=(~{sep=" " discfile})
    for (( i=0; i<~{num_samples}; i++ ));
    do
      vcf=${vcfs[$i]}
      tabix -p vcf $vcf
      sample_id=${sample_ids[$i]}
      pe=${discfiles[$i]}
      sample_no=`printf %03d $i`
      bash /opt/sv-pipeline/00_preprocessing/scripts/mantatloccheck.sh $vcf $pe ${sample_id} ~{mei_bed} ~{cytoband}
      mv ${sample_id}.manta.complex.vcf.gz tloc_${sample_no}.${sample_id}.manta.complex.vcf.gz
    done
  >>>

  output {
    Array[File]+ tloc_vcf = glob("tloc_*.vcf.gz")
  }
  
  runtime {
    cpu: select_first([runtime_attr.cpu_cores, default_attr.cpu_cores])
    memory: select_first([runtime_attr.mem_gb, default_attr.mem_gb]) + " GiB"
    disks: "local-disk " + select_first([runtime_attr.disk_gb, default_attr.disk_gb]) + " HDD"
    bootDiskSizeGb: select_first([runtime_attr.boot_disk_gb, default_attr.boot_disk_gb])
    docker: sv_pipeline_docker
    preemptible: select_first([runtime_attr.preemptible_tries, default_attr.preemptible_tries])
    maxRetries: select_first([runtime_attr.max_retries, default_attr.max_retries])
  }
}
