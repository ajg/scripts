#!/bin/bash -eu

#
# Change the name and/or email of the author and/or committer of one or all commits within
# one or all branches in a git repository.
#
# Written by Alvaro J. Genial (http://alva.ro) based on Chris Johnsen's change-author.
#
# git-reattribute.sh [-a] [-c] [-f] [commit [branch [new-name [new-email]]]]
#
#     If -a is supplied the author will be changed.
#
#     If -c is supplied the committer will be changed.
#
#     If -f is supplied it is passed to "git filter-branch".
#
#     If <commit> is not provided or is empty all commits will be used.
#
#     If <branch> is not provided or is empty HEAD will be used.
#     Use "--all" or a space separated list (e.g. "master next") to rewrite
#     multiple branches.
#
#     If <new-name> (or <new-email>) is not provided or is empty, the normal
#     user.name (user.email) Git configuration value will be used.
#
# TODO:
#     - Use proper command option parsing.
#     - Offer -n/--dry-run option.
#     - Offer long option alternatives (longopts.)
#     - Offer --old-name,--old-email filters.
#

function die() {
    printf '%s\n' "$@"
    exit 128
}

if [ "${1-}" = "-a" ]
    then export OPTION_AUTHOR=1; shift
    else export OPTION_AUTHOR=0
fi

if [ "${1-}" = "-c" ]
    then export OPTION_COMMITTER=1; shift
    else export OPTION_COMMITTER=0
fi

if [ "${1-}" = "-f" ]
    then export OPTION_FORCE='-f'; shift
    else export OPTION_FORCE=''
fi

if [ -n "${1-}" ]
    then export OPTION_COMMIT="$(git rev-parse --verify "$1" 2>/dev/null)" || die "$1 is not a commit"; shift
    else export OPTION_COMMIT=''
fi

if [ -n "${1-}" ]
    then export OPTION_BRANCH="$1"; shift
    else export OPTION_BRANCH='HEAD'
fi

if [ -n "${1-}" ]
    then export OPTION_NAME="$1"; shift
    else export OPTION_NAME=''
fi

if [ -n "${1-}" ]
    then export OPTION_EMAIL="$1"; shift
    else export OPTION_EMAIL=''
fi

if (( !OPTION_AUTHOR )) && (( !OPTION_COMMITTER ))
    then die "Either -a or -c must be specified"
fi

ENV_FILTER='
    if [ -z "$OPTION_COMMIT" ] || [ "$GIT_COMMIT" = "$OPTION_COMMIT" ]; then
        if (( OPTION_AUTHOR )); then
            if [ -n "$OPTION_EMAIL" ]
                then export GIT_AUTHOR_EMAIL="$OPTION_EMAIL"
                else unset  GIT_AUTHOR_EMAIL
            fi
            if [ -n "$OPTION_NAME" ]
                then export GIT_AUTHOR_NAME="$OPTION_NAME"
                else unset  GIT_AUTHOR_NAME
            fi
        fi
        if (( OPTION_COMMITTER )); then
            if [ -n "$OPTION_EMAIL" ]
                then export GIT_COMMITTER_EMAIL="$OPTION_EMAIL"
                else unset  GIT_COMMITTER_EMAIL
            fi
            if [ -n "$OPTION_NAME" ]
                then export GIT_COMMITTER_NAME="$OPTION_NAME"
                else unset  GIT_COMMITTER_NAME
            fi
        fi
    fi
'

git filter-branch $OPTION_FORCE --env-filter "$ENV_FILTER" -- $OPTION_BRANCH
