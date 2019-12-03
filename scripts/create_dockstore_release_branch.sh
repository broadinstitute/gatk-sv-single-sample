#!/bin/bash

set -eu

releaseName=$1

currentBranch=$(git rev-parse --abbrev-ref HEAD)
if [ "${currentBranch}" != "master" ]
then
  echo "Current branch is ${currentBranch}. Please release only from master"
  exit 1
fi

branch=dockstore_release_${releaseName}
git checkout -b "${branch}"

baseUrl="https://raw.githubusercontent.com/broadinstitute/gatk-sv-clinical"

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