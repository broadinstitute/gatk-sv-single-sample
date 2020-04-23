#!/bin/bash

set -eu

# this script does this following:
#
# - create a new branch (requires that you currently have master checked out) with the name dockstore_release_${releaseName}
# - re-write all imports in the wdls with raw.githubusercontent/broadinstitute/gatk-sv-clinical/${releaseName} URLs
# - commits those to the branch, and creates a tag marking ${releaseName}
# - pushes the branch and tag to github
#
# to release to dockstore still requires the following steps after running this script:
#
# - in the github UI, create a release using the tag created by this script (this could eventually be automated by using a github API call)
# - in the Dockstore UI, refresh the repository, switch the default version, and publish the tool
#
# Parameters:
#
# releaseName: name to give this release. a tag will be created with this name and a branch will be created with the name dockstore_release_${releaseName}
# baseUrl: the base URL of the git repository's web-accessible location. Example: https://raw.githubusercontent.com/broadinstitute/gatk-sv-clinical
#
# Author: Chris Whelan (cwhelan at broadinstitute.org)
releaseName=$1
baseUrl=$2

currentBranch=$(git rev-parse --abbrev-ref HEAD)
if [ "${currentBranch}" != "master" ]
then
  echo "Current branch is ${currentBranch}. Please release only from master"
  exit 1
fi

branch=dockstore_release_${releaseName}
git checkout -b "${branch}"

while read -r wdlPath
do
  echo "${wdlPath}"
  wdlName=$(basename "${wdlPath}")
  wdlDir=$(dirname "${wdlPath}")
  importRootUrl=$(echo "${baseUrl}/${releaseName}/$wdlDir" | sed 's|/.$||')
  echo importRootUrl
  sed -i.bak "s|^\(import \"\)\(.*\)\"|\1${importRootUrl}/\2\"|" "${wdlPath}"
  git add "${wdlPath}"
  rm "${wdlPath}.bak"
done < <(find . -name '*.wdl' | sed 's/^\.\///')

git commit -m "Rewrote imports for release ${releaseName} for Dockstore"
git tag -a "${releaseName}" -m "Release ${releaseName} for Dockstore"

git push --set-upstream origin "${branch}"
git push origin "${releaseName}"

