# Rule 1: PR should not be too small (less than 50 lines of code)
fail("Your pull request should not be too small (less than 50 LoC).") if git.lines_of_code < 50

# Rule 2: PR should not touch too many files (more than 30 files)
fail("Your pull request should not touch too many files (more than 30 files).") if git.modified_files.size + git.added_files.size > 30