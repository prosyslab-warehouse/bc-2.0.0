#! /bin/sh
#
# Copyright (c) 2018-2019 Gavin D. Howard and contributors.
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#

set -e

script="$0"

testdir=$(dirname "$script")

if [ "$#" -lt 2 ]; then
	printf 'usage: %s dir test [generate_tests] [exe [args...]]\n' "$0"
	printf 'valid dirs are:\n'
	printf '\n'
	cat "$testdir/all.txt"
	printf '\n'
	exit 1
fi

d="$1"
shift

t="$1"
name="$testdir/$d/$t.txt"
results="$testdir/$d/${t}_results.txt"
shift

if [ "$#" -gt 0 ]; then
	generate_tests="$1"
	shift
else
	generate_tests=1
fi

if [ "$#" -gt 0 ]; then
	exe="$1"
	shift
else
	exe="$testdir/../bin/$d"
fi

out="$testdir/../.log_${d}_test.txt"

if [ "$d" = "bc" ]; then
	options="-lq"
	var="BC_LINE_LENGTH"
	halt="halt"
else
	options=""
	var="DC_LINE_LENGTH"
	halt="q"
fi

if [ ! -f "$name" ]; then

	if [ "$generate_tests" -eq 0 ]; then
		printf 'Skipping %s %s test\n' "$d" "$t"
		exit 0
	fi

	printf 'Generating %s %s...\n' "$d" "$t"
	"$testdir/$d/scripts/$t.$d" > "$name"
fi

if [ ! -f "$results" ]; then
	printf 'Generating %s %s results...\n' "$d" "$t"
	printf '%s\n' "$halt" | "$d" $options "$name" > "$results"
fi

if [ "$d" = "dc" ]; then
	options="-x"
fi

export $var=string

printf 'Running %s %s...\n' "$d" "$t"

printf '%s\n' "$halt" | "$exe" "$@" $options "$name" > "$out"

diff "$results" "$out"

rm -rf "$out"
