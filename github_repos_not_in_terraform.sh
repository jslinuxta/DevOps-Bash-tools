#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2022-02-25 16:00:24 +0000 (Fri, 25 Feb 2022)
#
#  https://github.com/HariSekhon/DevOps-Bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/HariSekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(dirname "${BASH_SOURCE[0]}")"

# shellcheck disable=SC1090
. "$srcdir/lib/utils.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Finds all non-fork GitHub repos for the current or given user or organization which are not found in the adjacent *.tf code in the current directory

Useful to catch if anyone has created any unmanaged repos

Relies on the GitHub repo name matching the terraform repo identifier, or in cases of repos with a leading dot such as '.github', without the dot prefix


Requires GitHub CLI to be installed and configured
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="[<owner>]"

help_usage "$@"

#min_args 1 "$@"

owner="${1:-}"

repos="$(
    gh repo list ${owner:+"$owner"} \
            -L 99999 \
            --json name,isFork \
            -q '.[] | select(.isFork == false) | .name' |
    sort -f
)"

for repo in $repos; do
    # search without the dot prefix which isn't allowed in Terraform code identifiers
    grep -Eq '^[[:space:]]*resource[[:space:]]+"github_repository"[[:space:]]+"'"${repo#.}"'"' ./*.tf ||
    echo "$repo"
done
