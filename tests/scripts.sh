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

testdir=$(dirname "${script}")

if [ "$#" -eq 0 ]; then
	printf 'usage: %s dir [run_stack_tests] [generate_tests] [exec args...]\n' "$script"
	exit 1
else
	d="$1"
	shift
fi

if [ "$#" -gt 0 ]; then
	run_stack_tests="$1"
	shift
else
	run_stack_tests=1
fi

if [ "$#" -gt 0 ]; then
	generate="$1"
	shift
else
	generate=1
fi

if [ "$#" -gt 0 ]; then
	exe="$1"
	shift
else
	exe="$testdir/../bin/$d"
fi

out="$testdir/../.log_${d}_test.txt"

if [ "$d" = "bc" ]; then

	if [ "$run_stack_tests" -ne 0 ]; then
		options="-lgq"
	else
		options="-lq"
	fi

	halt="halt"

else
	options="-x"
	halt="q"
fi

scriptdir="$testdir/$d/scripts"

for s in $scriptdir/*.$d; do

	f=$(basename -- "$s")
	name="${f%.*}"

	if [ "$f" = "timeconst.bc" ]; then
		continue
	fi

	if [ "$run_stack_tests" -eq 0 ]; then

		if [ "$f" = "globals.bc" -o "$f" = "references.bc" ]; then
			printf 'Skipping %s script %s\n' "$d" "$s"
			continue
		fi

	fi

	orig="$testdir/$name.txt"
	results="$scriptdir/$name.txt"

	if [ -f "$orig" ]; then
		res="$orig"
	elif [ -f "$results" ]; then
		res="$results"
	elif [ "$generate" -eq 0 ]; then
		printf 'Skipping %s script %s\n' "$d" "$s"
		continue
	else
		printf 'Generating %s results...\n' "$f"
		printf '%s\n' "$halt" | "$d" "$s" > "$results"
		res="$results"
	fi

	printf 'Running %s script: %s\n' "$d" "$f"

	printf '%s\n' "$halt" | "$exe" "$@" $options "$s" > "$out"

	diff "$res" "$out"

done

rm -rf "$out"
