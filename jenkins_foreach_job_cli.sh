#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#  args: echo "job='{job}'"
#
#  Author: Hari Sekhon
#  Date: 2022-06-28 18:34:34 +0100 (Tue, 28 Jun 2022)
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
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
. "$srcdir/lib/utils.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Run a command for each Jenkins Job obtained via the Jenkins CLI

All arguments become the command template

Tested on Jenkins 2.319

Uses the adjacent jenkins_cli.sh - see there for authentication details


The command template replaces the following for convenience in each iteration:

{job}    => the job name


Example:

    ${0##*/} echo \"job='{job}'\"
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="<command> <args>"

help_usage "$@"

min_args 1 "$@"

cmd_template="$*"

"$srcdir/jenkins_cli.sh" list-jobs |
while read -r job; do
    echo "# ============================================================================ #" >&2
    echo "# $job" >&2
    echo "# ============================================================================ #" >&2
    cmd="$cmd_template"
    cmd="${cmd//\{job\}/$job}"
    eval "$cmd"
    echo >&2
done
