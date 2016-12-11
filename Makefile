test_syntax: snapshot.sh snapshot.py encode.sh ffcat.sh
	# If there is error inside for-cycle make will not fail, because
	# exit status of for will be zero. Enabling exit on error (set -e)
	# will immediately file for cycle and make too.
	set -e; for i in *.sh; do bash -n $$i; done
	python -m py_compile *.py

